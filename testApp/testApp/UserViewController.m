//
//  UserViewController.m
//  testApp
//
//  Created by Aaron Burke on 8/8/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import "UserViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface UserViewController ()

@end

@implementation UserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uses the authenticated account we have created in TableViewController
    //   to pull user specific data from twitter
    //NSLog(@"%@",[self.userAccount username]);
    if (self.userAccount) {
        NSString *username = [self.userAccount username];
        NSString *userCallUrl = @"https://api.twitter.com/1.1/users/show.json?screen_name=";
        NSString *userTimeString = [[NSString alloc] initWithFormat: @"%@%@", userCallUrl, username];
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:userTimeString] parameters:nil];
        if (request) {
            // Twitter 1.1
            [request setAccount:self.userAccount];
            
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                NSInteger responseCode = [urlResponse statusCode];
                if (responseCode == 200) {
                    self.userInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                    if (self.userInfo) {
                        //NSLog(@"%@", self.userInfo);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.user.text = self.userInfo[@"name"];
                            self.userDescr.text = self.userInfo[@"description"];
                            self.followersNum.text = [NSString stringWithFormat:@"%@",self.userInfo[@"followers_count"]];
                            self.friendsNum.text = [NSString stringWithFormat:@"%@",self.userInfo[@"friends_count"]];
                        });
                        
                        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue1", 0);
                        dispatch_async(backgroundQueue, ^{
                            
                            NSError *error = nil;
                            NSURL *url = [NSURL URLWithString:self.userInfo[@"profile_image_url"]];
                            NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                            
                            NSError *error2 = nil;
                            NSURL *url2 = [NSURL URLWithString:self.userInfo[@"profile_background_image_url"]];
                            NSData *data2 = [NSData dataWithContentsOfURL:url2 options:NSDataReadingUncached error:&error2];
                            if (data) {
                        
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (error) {
                                        NSLog(@"Data could not be downloaded");
                                    } else {
                                        
                                        UIImage *img = [[UIImage alloc] initWithData:data];
                                        self.userAvatar.image = img;
                                    }
                                });
                            }
                            if (data2) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (error2) {
                                        NSLog(@"Data could not be downloaded");
                                    } else {
                                        
                                        UIImage *img2 = [[UIImage alloc] initWithData:data2];
                                        self.userbgImg.image = img2;
                                    }
                                });
                            }
                        });
                        
                    }
                }
            }];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
