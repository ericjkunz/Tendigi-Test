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
#import "TDTwitterCommunicator.h"

@interface TDTwitterFeedTableViewDataSource ()

@property (nonatomic) TDTwitterCommunicator *communicator;
@property (nonatomic) NSString *TweetTableReuseIdentifier;
@property (nonatomic, strong) NSMutableArray *downloadedTweets; // Holds all loaded tweets
@property (nonatomic, strong) NSMutableArray *currentTweets;
@property (nonatomic) int cellWidth;

@property (nonatomic) BOOL local; // Get Dumbo based tweets or Tendigi's tweets

@end


@implementation TDTwitterFeedTableViewDataSource

- (instancetype)initLocationBased:(BOOL)local {
    self = [super init];
    
    self.local = local;
    
    // Setup tableview
    self.TweetTableReuseIdentifier = @"tweetCell";
    self.cellWidth = [UIScreen mainScreen].bounds.size.width;
    
    // Use custom colors
    [TWTRTweetView appearance].primaryTextColor = [UIColor blackColor];
    [TWTRTweetView appearance].backgroundColor = [UIColor whiteColor];
    [TWTRTweetView appearance].linkTextColor = [UIColor tendigiPurple];
    
    self.communicator = [[TDTwitterCommunicator alloc] init];
    [self getTweetsWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"success getting tweets");
        } else {
            NSLog(@"error getting tweets:%@", error);
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
    return [self.currentTweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.TweetTableReuseIdentifier forIndexPath:indexPath];
    
    // If user reaches end of currently loaded tweets, load more
    NSLog(@"%ld", (long)indexPath.item);
    NSLog(@"%lu", (unsigned long)self.currentTweets.count);
    if (indexPath.item == self.currentTweets.count-1 || !self.currentTweets) {
        NSLog(@"match");
        [self getTweetsWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"successful loading tweets");
            } else {
                NSLog(@"failure loading tweets");
            }
        }];
    }
    // Configure the cell...
    TWTRTweet *tweet = self.currentTweets[indexPath.row];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self.tweetDelegate;
    
    return cell;
}

- (void)getTweetsWithCompletion:(void(^)(BOOL success, NSError *error))completionHandler {
    if (!self.currentTweets) {
        self.currentTweets = [[NSMutableArray alloc] init];
    }
    
    if (self.local) {
        [self.communicator getTweetsNearTendigiWithCompletion:^(NSArray *tweets, NSError *error) {
            if (tweets) {
                if (!self.downloadedTweets) {
                    self.downloadedTweets = [[NSMutableArray alloc] init];
                }
                [self.downloadedTweets addObjectsFromArray:tweets];
                // Add tweets to table
                [self insertNewTweets:tweets];
                completionHandler(YES, nil);
            } else {
                completionHandler(NO, error);
            }

        }];
    } else {
        [self.communicator getTweetsWithCompletion:^(NSArray *tweets, NSError *error) {
            if (tweets) {
                if (!self.downloadedTweets) {
                    self.downloadedTweets = [[NSMutableArray alloc] init];
                }
                // Add tweets to table
                [self insertNewTweets:tweets];
                completionHandler(YES, nil);
            } else {
                completionHandler(NO, error);
            }
        }];
    }
    
}

- (void)insertNewTweets:(NSArray *)tweets {
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger currentCount = self.currentTweets.count;
    for (int i = 0; i < tweets.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
    }
    
    // do the insertion
    [self.currentTweets addObjectsFromArray:tweets];
    
    // tell the table view to update (at all of the inserted index paths)
    [self.tweetDelegate.tableView beginUpdates];
    [self.tweetDelegate.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tweetDelegate.tableView endUpdates];
}

- (void)refreshTweetsCompletion:(void (^)(BOOL success, NSError *error))completionHandler {
    // Dump tweets array and start over loading from top
    self.currentTweets = [[NSMutableArray alloc] init];
    self.downloadedTweets = [[NSMutableArray alloc] init];
    
    [self.communicator getNewTweetsWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            [self.currentTweets addObjectsFromArray:tweets];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotMoreTweets" object:self];
            completionHandler(YES, nil);
        } else {
            completionHandler(NO, error);
        }
    }];
    
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.currentTweets[indexPath.row];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:self.cellWidth];
}


@end