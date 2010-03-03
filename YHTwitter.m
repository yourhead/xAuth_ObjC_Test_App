//
//  YHTwitter.m
//
//  Created by Isaiah Carew on 2 March 2010.
//  Copyright 2010. YourHead Software.
//
//  Some code and concepts taken from examples provided by 
//  Matt Gemmell and Chris Kimpton
//  See ReadMe for further attributions, copyrights and license info.
//

#import "YHOAuthTwitterEngine.h"
#import "YHTwitterDelegate.h"

#import "YHTwitter.h"

@implementation YHTwitter

@synthesize twitterEngine = _twitterEngine;
@synthesize username = _username;
@synthesize password = _password;

@synthesize statuses = _statuses;


#pragma mark Constructor Destructor
// --------------------------------------------------------------------------------


- (YHTwitter *)init;
{
    if (self = [super init]) {
		
		self.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
		self.twitterEngine = [YHOAuthTwitterEngine oAuthTwitterEngineWithDelegate:self];
		[self.twitterEngine setUsername:self.username password:self.password];
		[self update:self];
    }
    return self;
}




#pragma mark Accessors
// --------------------------------------------------------------------------------


- (IBAction)signIn:(id)sender;
{
	NSLog (@"Signing in.");
	[[NSUserDefaults standardUserDefaults] setValue:self.username forKey:@"username"];
	
	if ((!self.username) && ([self.username isEqualToString:@""]))
		return;

	self.twitterEngine = [YHOAuthTwitterEngine oAuthTwitterEngineWithDelegate:self];
	[self.twitterEngine setUsername:self.username password:self.password];
	[self.twitterEngine requestAccessToken];
}


- (IBAction)signOut:(id)sender;
{
	NSLog (@"Signing out.");
	
	[self willChangeValueForKey:@"isSignedIn"];
	[self.twitterEngine clearAccessToken];

	self.username = @"";
	self.password = @"";	
	[[NSUserDefaults standardUserDefaults] setValue:self.username forKey:@""];
	
	self.twitterEngine = [YHOAuthTwitterEngine oAuthTwitterEngineWithDelegate:self];
	self.statuses = [NSArray array];
	[self didChangeValueForKey:@"isSignedIn"];

}


- (IBAction)update:(id)sender;
{
	if (![self isSignedIn])
		return;
	
	NSLog (@"Requesting home timeline from Twitter.");
	[self.twitterEngine getFollowedTimelineFor:self.username since:nil startingAtPage:0];
}


- (IBAction)post:(id)sender;
{
	if (![self isSignedIn])
		return;

	[self.twitterEngine sendUpdate:postTextField.stringValue];
	postTextField.stringValue = @"";

	NSLog (@"Posting to Twitter.");
	[self update:self];
}


- (IBAction)openAbout:(id)sender;
{
	[aboutBox makeKeyAndOrderFront:self];
}


- (BOOL)isSignedIn;
{
	return [self.twitterEngine isAuthorized];
}


#pragma mark xAuth delegate
// --------------------------------------------------------------------------------


- (void)receivedAccessToken:(id)sender;
{
	NSLog (@"Received an access token.");
	
	[self willChangeValueForKey:@"isSignedIn"];
	[self didChangeValueForKey:@"isSignedIn"];
	[self update:self];
}


@end
