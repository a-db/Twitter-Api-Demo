//
//  AccountManager.m
//  testApp
//
//  Created by Aaron Burke on 8/9/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import "AccountManager.h"
#import <Accounts/Accounts.h>
#import "Reachability.h"

@interface AccountManager ();

// Used to keep up with race case in notification from the checkNetworkStatus and checkAccountStatus 
@property(nonatomic,assign) BOOL notificationStatus;

@end

@implementation AccountManager

// dispatch_once creates a thread safe singleton
// Used to pass the created account across the application
+(AccountManager*)sharedInstance;
{
    static AccountManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AccountManager alloc] init];
        
    });
    return _instance;
}

-(id)init
{
    if (self = [super init])
    {
        self.twitterAccount = nil;
        self.accountStore = nil;
        self.internetStatus = false;
        self.notificationStatus = false;
    }
    return self;
}

// Checks Internet Connection Status
-(void)checkNetworkStatus
{
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"REACHABLE!");
        self.internetStatus = true;
        if (self.notificationStatus != false) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountStatus" object:self];
        } else {
            self.notificationStatus = true;
        }
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
        self.internetStatus = false;
        if (self.notificationStatus != false) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountStatus" object:self];
        } else {
            self.notificationStatus = true;
        }
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
}

// Checks for twitter account availability
-(void)checkAccountStatus
{
    // Find and verify current twitter account credentials - then store for future calls
    self.accountStore = [[ACAccountStore alloc] init];
    if (self.accountStore) {
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        if (accountType) {
            [self.accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:accountType];
                    if (twitterAccounts.count != 0) {
                        //NSLog(@"%@", [twitterAccounts description]);
                        
                        // Set twitter singleton from AccountManager
                        self.twitterAccount = [twitterAccounts objectAtIndex:0];
                        if (self.twitterAccount) {
                            NSLog(@"%@", self.twitterAccount);
                            if (self.notificationStatus != false) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountStatus" object:self];
                            } else {
                                self.notificationStatus = true;
                            }
                        }
                    }
                } else {
                    NSLog(@"Access not granted - %@", error);
                    //[self setAccountStore:nil];
                    self.twitterAccount = nil;
                }
            }];
        }
    }
}

@end
