//
//  TDTwitterFeedTableViewDataSource.m
//  Tendigi Test
//
//  Created by Eric Kunz on 2/20/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//


// TIMELINE REQUESTS
// Load first page of tweets with only a count
// The lowest ID recieved set as max_ID
// the next request should only return tweets with IDs less than max_ID
// Actually subtract 1 from max_ID to avoid redundant tweets

// Use since_ID to store the highest tweet ID requested


#import "TDTwitterFeedTableViewDataSource.h"
#import <TwitterKit/TwitterKit.h>
#import "UIColor+TDColor.h"

@interface TDTwitterFeedTableViewDataSource ()

@property (nonatomic) NSString *TweetTableReuseIdentifier;

// Timeline
@property (nonatomic) NSNumber *max_id;
@property (nonatomic) NSString *urlString;
@property (nonatomic, strong) NSMutableArray *tweets; // Holds all loaded tweets

@end


@implementation TDTwitterFeedTableViewDataSource

- (instancetype)initWithCompletion:(void(^)(bool success, NSError *error))completionHandler {
    self = [super init];
    
    self.urlString = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
    
    // Setup tableview
    self.TweetTableReuseIdentifier = @"tweetCell";
    
    // Guest authentication
    [[Twitter sharedInstance] logInGuestWithCompletion:^
     (TWTRGuestSession *session, NSError *error) {
         if (session) {
             // make API calls that do not require user auth
             NSLog(@"-guest logged in-");
             [self loadTweetsWithCompletion:^(bool success, NSError *error) {
                 completionHandler(success, error);
             }];
         } else {
             NSLog(@"-Authentication Error-\n %@", [error localizedDescription]);
         }
     }];
    
    
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"-checking number of rows-");
    return [self.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.TweetTableReuseIdentifier forIndexPath:indexPath];
    
    // If user reaches end of currently loaded tweets, load more
    NSLog(@"%ld", (long)indexPath.item);
    NSLog(@"%lu", (unsigned long)self.tweets.count);
    if (indexPath.item == self.tweets.count-1 || !self.tweets) {
        NSLog(@"match");
        [self loadTweetsWithCompletion:^(bool success, NSError *error) {
            if (success) {
                NSLog(@"successful loading tweets");
                // Table view can reload
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gotMoreTweets" object:self];
            } else {
                NSLog(@"failure loading tweets");
            }
        }];
    }
    
    // Configure the cell...
    TWTRTweet *tweet = self.tweets[indexPath.row];
    [cell configureWithTweet:tweet];
    
    return cell;
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:[UIScreen mainScreen].bounds.size.width];
}


#pragma mark - Twitter API Requests

- (void)loadTweetsWithCompletion:(void(^)(bool success, NSError *error))completionHandler{
    // Request parameters
    NSDictionary *params;
    if (self.max_id) { // If there has already been one request, use max_id to get next batch of tweets
        params = @{@"screen_name":@"tendigi", @"count":[NSString stringWithFormat:@"%@", @20], @"max_id": [self.max_id stringValue]};
        NSLog(@"-request with max_id");
    } else {
        params = @{@"screen_name":@"tendigi", @"count":[NSString stringWithFormat:@"%@", @20]};
    }
    
    // Create request
    NSError *__autoreleasing error;
    NSURLRequest *twitRequest = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:self.urlString parameters:params error:&error];
    if (error) {
        NSLog(@"error creating request: %@", error);
    }
    
    if (!self.tweets) {
        self.tweets = [[NSMutableArray alloc] init];
    }
    
    // Send request
    [[[Twitter sharedInstance] APIClient] sendTwitterRequest:twitRequest completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            //NSLog(@"-response: %@-\n -data:%@", response, data);
            NSError *error;
            NSArray *jsonTweets = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"-Json reading error: %@-", error);
            }
            for (NSDictionary *d in jsonTweets) {
                // Add tweets to my tweets array
                [self.tweets addObject:[[TWTRTweet alloc] initWithJSONDictionary:d]];
            }

            // Set max_id as oldest tweet's id
            long oldestID = [[[self.tweets lastObject] tweetID] longLongValue] - 1;
            self.max_id = [NSNumber numberWithLong:oldestID];
            NSLog(@"successful request");
            completionHandler(YES, nil);
            
        } else {
            NSLog(@"request error:%@", connectionError);
            completionHandler(NO, connectionError);
        }
    }];
    
}

- (void)refreshTableWithCompletion:(void (^)(bool, NSError *))completionHandler {
    // Dump tweets array and start over loading from top
    self.max_id = nil;
    
    [self loadTweetsWithCompletion:^(bool success, NSError *error) {
        completionHandler(success, error);
    }];
}


@end
