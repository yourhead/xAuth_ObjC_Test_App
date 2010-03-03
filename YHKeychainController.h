//
//  YHTwitter.h
//
//  Created by Isaiah Carew on 2 March 2010.
//  Copyright 2010. YourHead Software.
//

@interface YHKeychainController : NSObject {

}

+ (YHKeychainController *)sharedKeychainController;

- (NSString *)passwordForUsername:(NSString *)username;
- (void)setPassword:(NSString *)password forUserName:(NSString *)username;

@end

