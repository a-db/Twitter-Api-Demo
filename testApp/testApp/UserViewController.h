//
//  UserViewController.h
//  testApp
//
//  Created by Aaron Burke on 8/8/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface UserViewController : UIViewController

@property(nonatomic,strong) ACAccount *userAccount;
@property(nonatomic,strong) NSDictionary *userInfo;
@property (strong, nonatomic) IBOutlet UIImageView *userAvatar;
@property (strong, nonatomic) IBOutlet UIImageView *userbgImg;
@property (strong, nonatomic) IBOutlet UILabel *user;
@property (strong, nonatomic) IBOutlet UILabel *userDescr;
@property (strong, nonatomic) IBOutlet UILabel *followersNum;
@property (strong, nonatomic) IBOutlet UILabel *friendsNum;

@end
