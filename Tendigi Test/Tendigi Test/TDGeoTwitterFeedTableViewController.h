//
//  TDGeoTwitterFeedTableViewController.h
//  Tendigi Test
//
//  Created by Eric Kunz on 2/23/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TDTwitterFeedTableViewController.h"
#import "TDTableViewHeightCache.h"

@interface TDGeoTwitterFeedTableViewController : UITableViewController

@property (nonatomic) TDTableViewHeightCache *estimatedRowHeightCache;

@end
