//
//  CvDetailViewController.m
//  testApp
//
//  Created by Aaron Burke on 8/11/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import "CvDetailViewController.h"

@interface CvDetailViewController ()

@end

@implementation CvDetailViewController

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
    
    if (self.followerInfo) {
        self.userImg.image = self.followerInfo[@"img"];
        self.nameLbl.text = self.followerInfo[@"name"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
