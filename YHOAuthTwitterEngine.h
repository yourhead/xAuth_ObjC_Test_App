//
//  YHTwitter.h
//
//  Created by Isaiah Carew on 2 March 2010.
//  Copyright 2010. YourHead Software.
//
//  Some code and concepts taken from examples provided by 
//  Matt Gemmell and Chris Kimpton
//  See ReadMe for further attributions, copyrights and license info.
//

#import "MGTwitterEngine.h"

@class OAToken;
@class OAConsumer;

@interface YHOAuthTwitterEngine : MGTwitterEngine {
	
	OAConsumer	*_consumer;
	OAToken		*_accessToken;
	
}

+ (YHOAuthTwitterEngine *)oAuthTwitterEngineWithDelegate:(NSObject *)theDelegate;
- (YHOAuthTwitterEngine *)initOAuthWithDelegate:(NSObject *)newDelegate;

- (BOOL)isAuthorized;
- (void)requestAccessToken ;
- (void)clearAccessToken;

@property (retain)	OAConsumer	*consumer;
@property (retain)	OAToken		*accessToken;

@end


@protocol YHOAuthTwitterEngineDelegate 

- (void)receivedAccessToken:(id)sender;

@end
