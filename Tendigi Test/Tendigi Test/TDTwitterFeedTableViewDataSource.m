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
@property (nonatomic, strong) NSMutableArray *tweets; // Holds all loaded tweets
@property (nonatomic) int cellWidth;

@end


@implementation TDTwitterFeedTableViewDataSource

- (instancetype)init {
    self = [super init];
    
    // setup communicator, get tweets, profit
    
    // Setup tableview
    self.TweetTableReuseIdentifier = @"tweetCell";
    self.cellWidth = [UIScreen mainScreen].bounds.size.width;
    
    // Use custom colors
    [TWTRTweetView appearance].primaryTextColor = [UIColor blackColor];
    [TWTRTweetView appearance].backgroundColor = [UIColor whiteColor];
    [TWTRTweetView appearance].linkTextColor = [UIColor tendigiPurple];
    
    self.communicator = [[TDTwitterCommunicator alloc] init];
    [self.communicator getTweetsWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweets = [[NSMutableArray alloc] initWithArray:tweets];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotMoreTweets" object:self];
        } else {
            
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
    if (indexPath.item == self.tweets.count-10 || !self.tweets) {
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
    TWTRTweet *tweet = self.tweets[indexPath.row];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self.tweetDelegate;
    
    return cell;
}

- (void)getTweetsWithCompletion:(void(^)(BOOL success, NSError *error))completionHandler {
    [self.communicator getTweetsWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            if (!self.tweets) {
                self.tweets = [[NSMutableArray alloc] init];
            }
            [self.tweets addObjectsFromArray:tweets];
            // Table view can reload
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotMoreTweets" object:self];
            completionHandler(YES, nil);
        } else {
            completionHandler(NO, error);
        }
    }];
}

- (void)refreshTweetsCompletion:(void (^)(BOOL success, NSError *error))completionHandler {
    // Dump tweets array and start over loading from top
    self.tweets = [[NSMutableArray alloc] init];
    
    [self.communicator getNewTweetsWithCompletion:^(bool success, NSError *error) {
        if (success) {
            completionHandler(YES, nil);
        } else {
            completionHandler(NO, error);
        }
    }];
    
    
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:self.cellWidth];
}


@end