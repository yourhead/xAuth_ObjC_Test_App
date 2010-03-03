//
//  YHOAuthTwitterEngine.m
//
//  Created by Isaiah Carew on 2 March 2010.
//  Copyright 2010. YourHead Software.
//
//  Some code and concepts taken from examples provided by 
//  Matt Gemmell and Chris Kimpton
//  See ReadMe for further attributions, copyrights and license info.
//

#import "MGTwitterHTTPURLConnection.h"

#import "YHKeychainController.h"

#import <OAuthConsumer/OAConsumer.h>
#import <OAuthConsumer/OAMutableURLRequest.h>
#import <OAuthConsumer/OADataFetcher.h>

#import "YHOAuthTwitterEngine.h"


#define kOAuthAccessTokenKey			@"kOAuthAccessTokenKey"
#define kOAuthAccessTokenSecret			@"kOAuthAccessTokenSecret"

#define kYHOAuthClientName				@"YHOAuthTester"
#define kYHOAuthClientVersion			@"0.1"
#define kYHOAuthClientURL				@"http://www.yourURL.com/"
#define kYHOAuthClientToken				@"YHOAuthTester"

//
// You will need to change these!
// These should be your Key and Secret that you obtain from the
// Twitter app registration page:
//
// http://twitter.com/oauth_clients/new
// 
// Your info should look like this, but different (these are not valid keys).
#define kOAuthConsumerKey				@"WGMqSPuYgphhTXRTwp14XQ"
#define kOAuthConsumerSecret			@"OwzIslOmftD9smtZZuqs345XRtmsPeRzdKKYZo5h0U"

#define kYHOAuthTwitterAccessTokenURL	@"https://api.twitter.com/oauth/access_token"



@interface YHOAuthTwitterEngine (private)

- (void)_fail:(OAServiceTicket *)ticket data:(NSData *)data;
- (void)_setAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data;
- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed;

@end



@implementation YHOAuthTwitterEngine

@synthesize accessToken =	_accessToken;
@synthesize consumer =		_consumer;



#pragma mark Constructors
// --------------------------------------------------------------------------------

+ (YHOAuthTwitterEngine *)oAuthTwitterEngineWithDelegate:(NSObject *)theDelegate;
{
    return [[[YHOAuthTwitterEngine alloc] initOAuthWithDelegate:theDelegate] autorelease];
}


- (YHOAuthTwitterEngine *)initOAuthWithDelegate:(NSObject *)newDelegate;
{
    if (self = (YHOAuthTwitterEngine *)[super initWithDelegate:newDelegate]) {
		self.consumer = [[[OAConsumer alloc] initWithKey:kOAuthConsumerKey secret:kOAuthConsumerSecret] autorelease];
		[self setClientName:kYHOAuthClientName 
					 version:kYHOAuthClientVersion 
						 URL:kYHOAuthClientURL 
					   token:kYHOAuthClientToken];
	}
    return self;
}

#pragma mark OAuth
// --------------------------------------------------------------------------------


//
// This looks locally and on the keychain for an access tokean
//
- (BOOL)isAuthorized;
{	
	// if we already have an access token with a complete key and secret
	// then we can assume we're good to go.
	if ((self.accessToken.key) && (self.accessToken.secret)) {
		return YES;
	}
		
	// otherwise we should check the users keychain to see if we stored it
	NSString *accessTokenString = [[YHKeychainController sharedKeychainController] passwordForUsername:_username];
	if ((accessTokenString) && (![accessTokenString isEqualToString:@""])) {
		self.accessToken = [[[OAToken alloc] initWithHTTPResponseBody:accessTokenString] autorelease];
		if ((self.accessToken.key) && (self.accessToken.secret)) {
			return YES;
		}
	}
	
	// no access token found.  create a new empty one
	self.accessToken = [[[OAToken alloc] initWithKey:nil secret:nil] autorelease];
	return NO;
}


- (void)requestAccessToken;
{
	
	//
	// xAuth doesn't require the request token, so we're just going to pass nil in for the token.  
	//
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kYHOAuthTwitterAccessTokenURL] consumer:self.consumer token:nil realm:nil signatureProvider:nil] autorelease];
	if (!request)
		return;
	
    [request setHTTPMethod:@"POST"];
	
	//
	// Here's the parameters for xAuth
	// we're just going to add the extra parameters to the access token request
	//
	[request setParameters:[NSArray arrayWithObjects:
							[OARequestParameter requestParameterWithName:@"x_auth_mode" value:@"client_auth"],
							[OARequestParameter requestParameterWithName:@"x_auth_username" value:_username],
							[OARequestParameter requestParameterWithName:@"x_auth_password" value:_password],
							nil]];
	
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];	
    [fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(_setAccessToken:withData:) didFailSelector:@selector(_fail:data:)];
}


//
// Clear our access token and removing it from the keychain
//
- (void)clearAccessToken;
{
	[[YHKeychainController sharedKeychainController] setPassword:@"" forUserName:_username];
	self.accessToken = nil;
}


#pragma mark OAuth private
// --------------------------------------------------------------------------------


//
// if the fetch fails this is what will happen
// you'll want to add your own error handling here.
//
- (void)_fail:(OAServiceTicket *)ticket data:(NSData *)data;
{
	NSLog(@"fail: '%@'", data);
}



//
// access token callback
// when twitter sends us an access token this callback will fire
// we store it in our ivar as well as writing it to the keychain
// 
- (void)_setAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data;
{
	NSLog (@"setting access token");
	
	if (!ticket.didSucceed) {
		NSLog (@"access token exchange failed");
		return;
	}
	
	if (!data) {
		NSLog (@"access token said it succeeded but no data was returned");
		return;
	}

	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (!dataString)
		return;

	[[YHKeychainController sharedKeychainController] setPassword:dataString forUserName:_username];
	
	self.accessToken = [[[OAToken alloc] initWithHTTPResponseBody:dataString] autorelease];
	[dataString release];
	dataString = nil;
	if ([_delegate respondsToSelector:@selector(receivedAccessToken:)])
		[_delegate performSelector:@selector(receivedAccessToken:) withObject:self];	
}


#pragma mark MGTwitterEngine Changes
// --------------------------------------------------------------------------------
//
// these method overrides were created from the work that Chris Kimpton
// did.  i've chosen to subclass instead of directly modifying the
// MGTwitterEngine as it makes integrating MGTwitterEngine changes a bit
// easier.
// 
// i've modified the Chris Kipton code a bit to properly include parameters
//
// --------------------------------------------------------------------------------

#define SET_AUTHORIZATION_IN_HEADER 1

- (NSString *)_sendRequestWithMethod:(NSString *)method 
                                path:(NSString *)path 
                     queryParameters:(NSDictionary *)params 
                                body:(NSString *)body 
                         requestType:(MGTwitterRequestType)requestType 
                        responseType:(MGTwitterResponseType)responseType
{
    NSString *fullPath = path;

    BOOL isPOST = (method && [method isEqualToString:@"POST"]);
    if ((!isPOST) && (params))
		fullPath = [self _queryStringWithBase:fullPath parameters:params prefixed:YES];
	
	
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@", 
                           (_secureConnection) ? @"https" : @"http",
                           _APIDomain, fullPath];
    NSURL *finalURL = [NSURL URLWithString:urlString];
    if (!finalURL) {
        return nil;
    }
	
	OAMutableURLRequest *theRequest = [[[OAMutableURLRequest alloc] initWithURL:finalURL
																	   consumer:self.consumer token:self.accessToken realm:nil
															  signatureProvider:nil] autorelease];
    if (method) {
        [theRequest setHTTPMethod:method];
    }
    [theRequest setHTTPShouldHandleCookies:NO];
    [theRequest setValue:_clientName    forHTTPHeaderField:@"X-Twitter-Client"];
    [theRequest setValue:_clientVersion forHTTPHeaderField:@"X-Twitter-Client-Version"];
    [theRequest setValue:_clientURL     forHTTPHeaderField:@"X-Twitter-Client-URL"];
    
    if (isPOST) {
        NSString *finalBody = @"";
		if (body) {
			finalBody = [finalBody stringByAppendingString:body];
		}
        if (_clientSourceToken) {
            finalBody = [finalBody stringByAppendingString:[NSString stringWithFormat:@"%@source=%@", 
                                                            (body) ? @"&" : @"?" , 
                                                            _clientSourceToken]];
        }
        
        if (finalBody) {
            [theRequest setHTTPBody:[finalBody dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

	
	[theRequest prepare];
    
    MGTwitterHTTPURLConnection *connection;
    connection = [[MGTwitterHTTPURLConnection alloc] initWithRequest:theRequest 
                                                            delegate:self 
                                                         requestType:requestType 
                                                        responseType:responseType];
    
    if (!connection) {
        return nil;
    } else {
        [_connections setObject:connection forKey:[connection identifier]];
        [connection release];
    }
    
    return [connection identifier];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	
	// --------------------------------------------------------------------------------
	// modificaiton from the base clase
	// instead of answering the authentication challenge, we just ignore it.
	// --------------------------------------------------------------------------------

	[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
	return;
	
}

@end
