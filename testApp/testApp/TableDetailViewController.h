//
//  TableDetailViewController.h
//  testApp
//
//  Created by Aaron Burke on 8/8/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableDetailViewController : UIViewController

@property (strong, nonatomic) NSDictionary *tweetInfo;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) UIImage *img;
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *descriptionText;
@property (strong, nonatomic) IBOutlet UILabel *tweetTxt;
@property (strong, nonatomic) IBOutlet UILabel *tweetDate;

@end
