//
//  StatusViewController.m
//  testApp
//
//  Created by Aaron Burke on 8/14/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import "StatusViewController.h"
#import "AccountManager.h"
#import "TableViewController.h"

@interface StatusViewController ()

@property(nonatomic,strong) AccountManager *accountCheck;

@end

@implementation StatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.handler = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.accountCheck = [AccountManager sharedInstance];
    [self viewStatusUpdate];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onClick:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if (button) {
        if (button.tag == 0) {
            NSLog(@"Check Network Status Pressed");
            
            [self viewStatusUpdate];
            
        }
    }
}

// This method gets called by the button and checks for both an active twitter account and network availability
// This view will be launched if there is no availability on launch or if connection is lost while the app is active
- (void)viewStatusUpdate
{
    [self.accountCheck checkNetworkStatus];
    [self.accountCheck checkAccountStatus];
    if (self.accountCheck.internetStatus == false && self.accountCheck.twitterAccount == nil) {
        self.settingsBtn.backgroundColor = [UIColor redColor];
        self.errorLabel.text = @"Internet Access Down & Twitter Account Settings Error.";
        self.errorLabel.numberOfLines = 2;
    } else if (self.accountCheck.twitterAccount == nil && self.accountCheck.internetStatus == true) {
        self.settingsBtn.backgroundColor = [UIColor redColor];
        self.errorLabel.text = @"Please check your Twitter Account Settings";
    } else if (self.accountCheck.twitterAccount && self.accountCheck.internetStatus == false) {
        self.settingsBtn.backgroundColor = [UIColor redColor];
        self.errorLabel.text = @"Internet Access is Down!";
    } else {
        self.settingsBtn.backgroundColor = [UIColor greenColor];
        self.errorLabel.text = @"All Access Restored!";
        [self performSelector:@selector(closeWindow) withObject:nil afterDelay:1.0f];
    }
    
}

// Instead of closing automatically with a notification I tried out the block implementation as show in the video
// This sends a BOOL value back to the TableViewController method to reload if it has not loaded yet
- (void)closeWindow
{
    if (self.handler != nil) {
        self.handler(false);
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}
                           

@end
