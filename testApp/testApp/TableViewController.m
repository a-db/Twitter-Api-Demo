//
//  TableViewController.m
//  testApp
//
//  Created by Aaron Burke on 8/7/13.
//  Copyright (c) 2013 Aaron Burke. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "TableDetailViewController.h"
#import "UserViewController.h"
#import "StatusViewController.h"
#import <Social/Social.h>

@interface TableViewController ()

// Values to keep up with the need to load data
@property(nonatomic, assign) BOOL hasLoaded;
@property(nonatomic, assign) BOOL refresh;

// Follow Account and Internet check Progress between StatusViewController
@property(nonatomic, assign) BOOL checkInProgress;

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    // Keep up with loading
    self.hasLoaded = false;
    self.refresh = false;
    
    // Creates a button to create a tweet in the right nav button position
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(pushTweet)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Event notification - tried out checking for internet drops and account errors with a notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStatus)
                                                 name:@"AccountStatus"
                                               object: nil];
    

    
    // Capture device current time zone and find the hour difference of GMT to include DST
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    NSInteger tst = [localTime secondsFromGMT];
    self.hoursFromGMT = tst/-3600;
    //NSLog(@"Current local timezone  is  %@",[localTime name]);
    //NSLog(@"%d - seconds from GMT, %d - hrs from GMT",tst,self.hoursFromGMT);
    
    
    // Setup the pull to refresh on the tableview
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    //[self connectionStatus];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self connectionStatus];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.followingFeed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    if (cell) {
        NSDictionary *tweetDict = [self.followingFeed objectAtIndex:indexPath.row];
        
        cell.tweetArea.text = tweetDict[@"text"];
        cell.nameLabel.text = tweetDict[@"user"][@"name"];
        
        // Tweet Date creation
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        //"created_at": "Tue Jul 09 07:45:01 +0000 2013",
        [df setDateFormat:@"EEE MMM d HH:mm:ss ZZZZ yyyy"];
        NSDate *date = [df dateFromString:tweetDict[@"created_at"]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *dateStr = [df stringFromDate:date];
        //NSLog(@"%@ date string", dateStr);
        cell.tweetDate.text = dateStr;
        
        // Check to see if imgArray has valid img pointer at the index that correspondes to indexPath.row
        if (![self.imgArray[indexPath.row] isEqual:[NSNull null]]) {
            
            // If the image was available at this index in imgArray load it for the cell
            cell.imageView.image = self.imgArray[indexPath.row];
        }
        return cell;
    }
    return nil;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        //for example [activityIndicator stopAnimating];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%d", indexPath.row);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
        // Check for reaching the bottom of the tableview
        NSLog(@"Bottom Reached");
    }
}

#pragma mark - Custom methods

// Checks status of Singleton data (internet availability and account status) and acts accordingly
// This method gets fired off by the notification subscribed to in viewDidLoad
// I realize this might not be the best implementation but I wanted to learn the workings of NSNotificationCenter
// If internet is not active on first launch it will pause for a second and then popup the connection error view (StatusViewController)
- (void)connectionStatus
{
    if (self.checkInProgress == false) {
        self.checkInProgress = true;
        // Check our singleton if there is an authenticated Twitter account
        if (self.accountManager.internetStatus == false || (self.accountManager.twitterAccount == nil)) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            StatusViewController *vc = [sb instantiateViewControllerWithIdentifier:@"statusView"];
            if (vc) {
                vc.handler = ^(BOOL result)
                {
                    self.checkInProgress = result;
                    [self connectionStatus];
                };
                [self presentViewController:vc animated:NO completion:nil];
            }
            
        } else {
            [self timeLineDownload];
            self.checkInProgress = false;
        }
    }
}

// Downloads the 20 most recent twitter posts the home timeline
- (void)timeLineDownload
{
    if (self.hasLoaded == false || self.refresh == true) {
   
        if (self.accountManager.twitterAccount) {
            NSString *userTimeString = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
            
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:userTimeString] parameters:nil];
            if (request) {
                // Twitter 1.1
                [request setAccount:self.accountManager.twitterAccount];
                
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSInteger responseCode = [urlResponse statusCode];
                    if (responseCode == 200) {
                        self.followingFeed = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                        //NSLog(@"%@", self.followingFeed);
                        if (self.followingFeed) {
                            //NSLog(@"%@", [self.followingFeed description]);
                            
                            // Create Array to hold downloaded images or clear and restart on refresh
                            if (!self.imgArray) {
                                self.imgArray = [[NSMutableArray alloc] initWithCapacity:self.followingFeed.count];
                            } else {
                                [self.imgArray removeAllObjects];
                            }
                            for(int i=0, j = (int)self.followingFeed.count ; i<j ; i++) {
                                [self.imgArray addObject:[NSNull null]];
                            }
                            
                            //NSLog(@"%@", self.followingFeed[1]);
                            //NSLog(@"%@", [self.followingFeed[1] objectForKey:@"users"]);
                            
                            // Reset loading variables
                            self.hasLoaded = true;
                            self.refresh = false;
                            
                            // Created a queue off the main thread to download icons and then updated the ui on the main queue thread
                            for (int i = 0, j = (int)self.followingFeed.count; i<j; i++) {
                                
                                dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
                                dispatch_async(backgroundQueue, ^{
                                    //NSLog(@"%@", [self.followingFeed[i] objectForKey:@"profile_image_url"]);
                                    NSError *error = nil;
                                    //NSURL *url = [NSURL URLWithString:[[self.followingFeed[i] objectForKey:@"user"] objectForKey:@"profile_image_url"]];
                                    NSURL *url = [NSURL URLWithString:self.followingFeed[i][@"user"][@"profile_image_url"]];
                                    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                                    if (data) {
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (error) {
                                                NSLog(@"Data could not be downloaded");
                                            } else {
                                                // Pushes the image into the imgArray at the index of the corresponding cell
                                                UIImage *img = [[UIImage alloc] initWithData:data];
                                                [self.imgArray replaceObjectAtIndex:i withObject:img];
                                                
                                                // Reload cell at that index when the image is ready
                                                NSInteger num = i;
                                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:num inSection:0];
                                                NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                                                [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                            }
                                        });
                                    }
                                });
                            }
                            
                            // Tell the main que to reload the table since it has already loaded at this point
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                            
                        }
                    }
                }];
            }
        }
    }
}


// Method for refreshing the table with new data
- (void)refreshTable
{
    self.refresh = true;
    [self connectionStatus];
    [self.accountManager checkAccountStatus];
    self.alert = [[UIAlertView alloc] initWithTitle:@"Patience is a Virtue!" message:@"Refreshing table" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [self.alert show];
    [self timeLineDownload];
    
    [self performSelector:@selector(updateRefreshControl) withObject:nil afterDelay:1.0f];
}

// Cleans up the refresh control and alertview
- (void)updateRefreshControl
{
    [self.refreshControl endRefreshing];
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
}

// Method for creating a tweet and pushing it to your twitter account
- (void)pushTweet
{
    SLComposeViewController *slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    if (slComposeViewController) {
        [slComposeViewController setInitialText:@"Posted from: "];
        [self presentViewController:slComposeViewController animated:true completion:nil];
    }
}

#pragma mark - Segue Control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Segue setup for table detail view and user settings
    if ([segue.identifier isEqualToString:@"showTableDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //NSLog(@"%d", indexPath.row);
        TableDetailViewController *destViewController = segue.destinationViewController;
        destViewController.tweetInfo = self.followingFeed[indexPath.row];
        destViewController.img = self.imgArray[indexPath.row];
    } else if ([segue.identifier isEqualToString:@"showUserSetting"]) {
        UserViewController *destViewController = segue.destinationViewController;
        destViewController.userAccount = self.accountManager.twitterAccount;
    }
}

@end
