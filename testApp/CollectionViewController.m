//
//  CollectionViewController.m
//  testApp
//
//  Created by Aaron Burke on 8/7/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "CvDetailViewController.h"
#import "StatusViewController.h"
#import <Social/Social.h>

@interface CollectionViewController ()

@property(nonatomic, assign) BOOL hasLoaded;
@property(nonatomic,strong) UIRefreshControl *refreshControl;

@end

@implementation CollectionViewController

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
    
    // Create singleton for access
    self.accountManager = [AccountManager sharedInstance];
    
    // Setup the pull to refresh on the tableview
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blueColor];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshCV) forControlEvents:UIControlEventValueChanged];

    
    [self getUserList];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Check our singleton if there is an authenticated Twitter account
    if (self.accountManager.internetStatus == false || !(self.accountManager.twitterAccount)) {
        if (self.accountManager.internetStatus == false) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            StatusViewController *vc = [sb instantiateViewControllerWithIdentifier:@"statusView"];
            if (vc) {
                [self presentViewController:vc animated:YES completion:nil];
            }
            
        }
    } else if (self.hasLoaded == false) {
        [self getUserList];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Collection View Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return [self.friendsList[@"users"] count];
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCell";
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.nameLabel.text = self.friendsList[@"users"][indexPath.row][@"screen_name"];
    
    // Check to see if imgArray has valid img pointer at the index that correspondes to indexPath.row
    if (![self.followerArray[indexPath.row] isEqual:[NSNull null]]) {
        
        cell.cvImg.image = self.followerArray[indexPath.row][@"img"];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Segue Control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Segue setup for table detail view and user settings
    if ([segue.identifier isEqualToString:@"showCollectionDetail"]) {
        NSArray *indexPath = [self.collectionView indexPathsForSelectedItems];
        CvDetailViewController *destViewController = segue.destinationViewController;
        destViewController.followerInfo = [self.followerArray objectAtIndex:[indexPath[0] row]];
        NSLog(@"%@", [self.followerArray objectAtIndex:[indexPath[0] row]] );
    }
}


#pragma Custom Methods

- (void)refreshCV
{
    [self.accountManager checkAccountStatus];
    self.alert = [[UIAlertView alloc] initWithTitle:@"Patience is a Virtue!" message:@"Refreshing View" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [self.alert show];
    [self getUserList];
    
    [self performSelector:@selector(updateRefreshControl) withObject:nil afterDelay:1.0f];
}

// Cleans up the refresh control and alertview
- (void)updateRefreshControl
{
    [self.refreshControl endRefreshing];
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)getUserList
{
    if (self.accountManager.twitterAccount) {
        NSString *userTimeString = @"https://api.twitter.com/1.1/friends/list.json";
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:userTimeString] parameters:nil];
        if (request) {
            // Twitter 1.1
            [request setAccount:self.accountManager.twitterAccount];
            
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                NSInteger responseCode = [urlResponse statusCode];
                if (responseCode == 200) {
                    self.friendsList = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                    
                    if (self.friendsList) {
                        //NSLog(@"%@", self.followingFeed);
                        //NSLog(@"%d", [[self.friendsList objectForKey:@"users"] count]);
                        //NSLog(@"%@", self.friendsList[@"users"][0]);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.collectionView reloadData];
                        });
                        
                        // Create Array to hold downloaded images or clear and restart on refresh
                        if (!self.followerArray) {
                            self.followerArray = [[NSMutableArray alloc] initWithCapacity:[self.friendsList[@"users"] count] ];
                        } else {
                            [self.followerArray removeAllObjects];
                        }
                        for(int i=0, j = [self.friendsList[@"users"] count] ; i<j ; i++) {
                            [self.followerArray addObject:[NSNull null]];
                        }
                        
                        // Created a queue off the main thread to download icons and then updated the ui on the main queue thread
                        for (int i = 0, j = [self.friendsList[@"users"] count]; i<j; i++) {
                        
                            dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
                            dispatch_async(backgroundQueue, ^{
                                
                                NSError *error = nil;
                                NSURL *url = [NSURL URLWithString:self.friendsList[@"users"][i][@"profile_image_url"]];
                                NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                                if (data) {
                                 
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (error) {
                                            NSLog(@"Data could not be downloaded");
                                        } else {
                                            // Pushes the image into the imgArray at the index of the corresponding cell
                                            
                                            UIImage *img = [[UIImage alloc] initWithData:data];
                                            if (img) {
                                                NSMutableDictionary *followerDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                                                        img,@"img",
                                                                                        self.friendsList[@"users"][i][@"screen_name"],@"name",
                                                                                        nil];
                                                if (followerDic) {
                                                    [self.followerArray replaceObjectAtIndex:i withObject:followerDic];
                                                }
                                            }
                            
                                            
                                            // Reload cell at that index when the image is ready
                                            NSInteger num = i;
                                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:num inSection:0];
                                            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                                            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
                                        }
                                    });
                                }
                            });
                        }
                        
                    self.hasLoaded = true;
                
                    }
                }
            }];
        }
    }
}

@end
