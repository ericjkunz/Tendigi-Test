//
//  TDTwitterFeedTableViewDataSource.m
//  Tendigi Test
//
//  Created by Eric Kunz on 2/20/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//
//  Data source for UITableView stores tweets and makes appropriate requests through TDTwitterCommunicator

#import "TDTwitterFeedTableViewDataSource.h"
#import <TwitterKit/TwitterKit.h>
#import "UIColor+TDColor.h"
#import "TDTwitterCommunicator.h"

@interface TDTwitterFeedTableViewDataSource ()

@property (nonatomic) TDTwitterCommunicator *communicator;
@property (nonatomic) NSString *TweetTableReuseIdentifier;
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
    return [self.currentTweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.TweetTableReuseIdentifier forIndexPath:indexPath];
    
    // If user reaches end of currently loaded tweets, load more
    if (indexPath.item == self.currentTweets.count-1 || !self.currentTweets) {
        [self getTweetsWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"successful loading tweets");
            } else {
                NSLog(@"failure loading tweets:%@", error);
            }
        }];
    }
    // Configure the cell...
    TWTRTweet *tweet = self.currentTweets[indexPath.row];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self.tweetDelegate;
    
    // put estimated cell height in cache if needed
    if (![self.estimatedRowHeightCache isEstimatedRowHeightInCache:indexPath]) {
        CGSize cellSize = [cell systemLayoutSizeFittingSize:CGSizeMake(self.cellWidth, 0) withHorizontalFittingPriority:1000.0 verticalFittingPriority:50.0];
        [self.estimatedRowHeightCache putEstimatedCellHeightToCache:indexPath height:cellSize.height];
    }
    
    return cell;
}

- (void)getTweetsWithCompletion:(void(^)(BOOL success, NSError *error))completionHandler {
    if (!self.currentTweets) {
        self.currentTweets = [[NSMutableArray alloc] init];
    }
    
    if (self.local) {
        [self.communicator getTweetsNearTendigiWithCompletion:^(NSArray *tweets, NSError *error) {
            if (tweets) {
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
    self.estimatedRowHeightCache = [[TDTableViewHeightCache alloc] init];
    
    [self.communicator getNewTweetsWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            [self.currentTweets addObjectsFromArray:tweets];
            completionHandler(YES, nil);
        } else {
            completionHandler(NO, error);
        }
    }];
}

@end