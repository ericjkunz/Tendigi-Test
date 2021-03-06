//
//  TDTwitterFeedTableViewController.h
//  Tendigi Test
//
//  Created by Eric Kunz on 2/18/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//
//  This class can show any tweets

#import <UIKit/UIKit.h>
#import "TDTableViewHeightCache.h"

@interface TDTwitterFeedTableViewController : UITableViewController

@property (nonatomic) TDTableViewHeightCache *estimatedRowHeightCache;

@end
