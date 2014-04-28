//
//  TableViewController.h
//  testApp
//
//  Created by Aaron Burke on 8/7/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Accounts/Accounts.h>
#import "AccountManager.h"

@interface TableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

// Singleton holder of account info
@property(nonatomic,strong) AccountManager *accountManager;

@property(nonatomic,strong) NSMutableArray *followingFeed;
@property(nonatomic,strong) NSMutableArray *imgArray;
@property(nonatomic,assign) NSInteger hoursFromGMT;
@property(nonatomic,strong) UIAlertView *alert;

@end
