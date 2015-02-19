//
//  TDTwitterFeedTableViewController.m
//  Tendigi Test
//
//  Created by Eric Kunz on 2/18/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//

#import "TDTwitterFeedTableViewController.h"
#import <TwitterKit/TwitterKit.h>

@interface TDTwitterFeedTableViewController () <TWTRTweetViewDelegate>

{
    NSString *_TweetTableReuseIdentifier;
    
    // Timeline
    NSUInteger *max_id;
    NSUInteger *since_id;
    
}

@property (nonatomic, strong) NSMutableArray *tweets; // Holds all loaded tweets

@end


@implementation TDTwitterFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Tendigi User ID: 293034645
    // Consumer key: kUeHcCm4xzXOlSFSk2mjetsvS
    // Consumer secret: IcLK2666L6UWaBWiBM5XZz03SPrsGzTEbLWNfoEbxWpClGbHnb
    
    NSURL *resourceURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
    NSString *urlString = @"https://api.twitter.com/1.1/statuses/user_timeline.json?";
    NSDictionary *params = @{@"screen_name":@"tendigi", @"count":[NSString stringWithFormat:@"%@", @10]};
    
    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:resourceURL];
    request.HTTPMethod = @"GET";
    [request addValue:@"tendigi" forHTTPHeaderField:@"screen_name"];
    //[request addValue:[NSString stringWithFormat:@"%ul", since_id] forHTTPHeaderField:@"since_id"];
    [request addValue:[NSString stringWithFormat:@"%@", @10] forHTTPHeaderField:@"count"];
    //[request addValue:[NSString stringWithFormat:@"%ul", max_id] forHTTPHeaderField:@"max_id"];
    
    self.tweets = [[NSMutableArray alloc] init];
    
    
    // Guest authentication    
    [[Twitter sharedInstance] logInGuestWithCompletion:^
     (TWTRGuestSession *session, NSError *error) {
         if (session) {
             // make API calls that do not require user auth
             NSLog(@"YESSSSS");
             
             
             NSURLRequest *twitRequest = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:urlString parameters:params error:nil];
             
             
             [[[Twitter sharedInstance] APIClient] sendTwitterRequest:twitRequest completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if (data) {
                     //NSLog(@"Data! %@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]);
                     NSArray *jsonTweets = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                     for (NSDictionary *d in jsonTweets) {
                         [self.tweets addObject:[[TWTRTweet alloc] initWithJSONDictionary:d]];
                     }
                     [self.tableView reloadData];

                 } else {
                     NSLog(@"request errrrrror:%@", connectionError);
                 }
             }];
         } else {
             NSLog(@"-Authentication Error-\n %@", [error localizedDescription]);
         }
     }];


    

    
    
    
    
    
    
    
    // Setup tableview
    _TweetTableReuseIdentifier = @"tweetCell";
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:_TweetTableReuseIdentifier];
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];

    
    // TIMELINE REQUESTS
    // Load first page of tweets with only a count
    // The lowest ID recieved set as max_ID
    // the next request should only return tweets with IDs less than max_ID
    // Actually subtract 1 from max_ID to avoid redundant tweets
    
    // Use since_ID to store the highest tweet ID requested
    
    
}

- (void)refreshTable:(id)sender {
    NSLog(@"Refreshing");
    
    [self.tableView reloadData];
    
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tweets count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:_TweetTableReuseIdentifier forIndexPath:indexPath];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self;
    
    return cell;
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
