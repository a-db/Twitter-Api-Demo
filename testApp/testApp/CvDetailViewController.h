//
//  CvDetailViewController.h
//  testApp
//
//  Created by Aaron Burke on 8/11/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CvDetailViewController : UIViewController

@property(nonatomic,strong) NSDictionary *followerInfo;

@property (strong, nonatomic) IBOutlet UIImageView *userImg;
@property (strong, nonatomic) IBOutlet UILabel *nameLbl;

@end
