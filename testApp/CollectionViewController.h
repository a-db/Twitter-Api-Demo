//
//  CollectionViewController.h
//  testApp
//
//  Created by Aaron Burke on 8/7/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountManager.h"

@interface CollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,strong) AccountManager *accountManager;

@property(nonatomic,strong) NSMutableDictionary *friendsList;
@property(nonatomic,strong) NSMutableArray *followerArray;
@property(nonatomic,strong) UIAlertView *alert;

@end
