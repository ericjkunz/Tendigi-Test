//
//  TDTwitterFeedTableViewDataSource.h
//  Tendigi Test
//
//  Created by Eric Kunz on 2/20/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//
//  This class is the table view's data source


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>

@interface TDTwitterFeedTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak) UITableViewController <TWTRTweetViewDelegate> *tweetDelegate;

- (instancetype)initLocationBased:(BOOL)local;
- (void)refreshTweetsCompletion:(void (^)(BOOL success, NSError *error))completionHandler;

@end
