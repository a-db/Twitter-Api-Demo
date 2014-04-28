//
//  StatusViewController.h
//  testApp
//
//  Created by Aaron Burke on 8/14/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

// StatusView close block definition
typedef void (^CloseHandler)(BOOL);

@interface StatusViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *settingsBtn;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

@property(nonatomic,strong) CloseHandler handler;

-(IBAction)onClick:(id)sender;

@end
