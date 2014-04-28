//
//  TableDetailViewController.m
//  testApp
//
//  Created by Aaron Burke on 8/8/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import "TableDetailViewController.h"

@interface TableDetailViewController ()

@end

@implementation TableDetailViewController

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
	// Do any additional setup after loading the view.
    //self.row.text = self.test;
    //NSLog(@"%@", self.tweetInfo);
    
    // Downloads the background image off the main que and updates when completed
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        NSError *error = nil;
        NSURL *url = [NSURL URLWithString:self.tweetInfo[@"user"][@"profile_background_image_url"]];
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];

        if (data) {
    
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data && !error) {
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    self.bgImg.image = img;
                }
            });
        }
    });
    
    self.avatar.image = self.img;
    self.userName.text = [NSString stringWithFormat:@"%@   ",self.tweetInfo[@"user"][@"name"]];
    self.descriptionText.text = self.tweetInfo[@"user"][@"description"];
    self.tweetTxt.text = self.tweetInfo[@"text"];
    
    // Tweet Date creation
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //"created_at": "Tue Jul 09 07:45:01 +0000 2013",
    [df setDateFormat:@"EEE MMM d HH:mm:ss ZZZZ yyyy"];
    NSDate *date = [df dateFromString:self.tweetInfo[@"created_at"]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr = [df stringFromDate:date];
    //NSLog(@"%@ date string", dateStr);
    self.tweetDate.text = dateStr;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
