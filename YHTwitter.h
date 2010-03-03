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

@class YHOAuthTwitterEngine;
@class YHTwitterDelegate;

@interface YHTwitter : NSObject {

	YHOAuthTwitterEngine	*_twitterEngine;
	NSString				*_username;
	NSString				*_password;
	NSArray					*_statuses;
	
	IBOutlet NSWindow		*aboutBox;
	IBOutlet NSTextField	*postTextField;
}

- (IBAction)signIn:(id)sender;
- (IBAction)signOut:(id)sender;

- (IBAction)update:(id)sender;
- (IBAction)post:(id)sender;

- (IBAction)openAbout:(id)sender;

@property (retain)		YHOAuthTwitterEngine	*twitterEngine;
@property (retain)		NSString				*username;
@property (retain)		NSString				*password;
@property (retain)		NSArray					*statuses;

@property (readonly)	BOOL					isSignedIn;

@end
