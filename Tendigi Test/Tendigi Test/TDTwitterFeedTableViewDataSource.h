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

@interface TDTwitterFeedTableViewDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithCompletion:(void(^)(bool success, NSError *error))completionHandler;
- (void)loadTweetsWithCompletion:(void(^)(bool success, NSError *error))completionHandler;
- (void)refreshTableWithCompletion:(void(^)(bool success, NSError *error))completionHandler;

@end
