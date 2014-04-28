//
//  AccountManager.h
//  testApp
//
//  Created by Aaron Burke on 8/9/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface AccountManager : NSObject

@property(nonatomic, strong) ACAccount *twitterAccount;
@property(nonatomic, strong) ACAccountStore *accountStore;
@property(nonatomic, assign) BOOL internetStatus;

+(AccountManager*)sharedInstance;
-(void)checkAccountStatus;
-(void)checkNetworkStatus;

@end
