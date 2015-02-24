//
//  TDTableViewHeightCache.m
//  Tendigi Test
//
//  Created by Eric Kunz on 2/24/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//
// This solution from: http://stackoverflow.com/questions/25221031/uitableview-layout-messing-up-on-push-segue-and-return-ios-8-xcode-beta-5-sw

#import "TDTableViewHeightCache.h"

@implementation TDTableViewHeightCache

// put height to cache
- (void) putEstimatedCellHeightToCache:(NSIndexPath *) indexPath height:(CGFloat) height {
    [self initEstimatedRowHeightCacheIfNeeded];
    [self.estimatedRowHeightCache setValue:[[NSNumber alloc] initWithFloat:height] forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
}

// get height from cache
- (CGFloat) getEstimatedCellHeightFromCache:(NSIndexPath *) indexPath defaultHeight:(CGFloat) defaultHeight {
    [self initEstimatedRowHeightCacheIfNeeded];
    NSNumber *estimatedHeight = [self.estimatedRowHeightCache valueForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    if (estimatedHeight != nil) {
        //NSLog(@"cached: %f", [estimatedHeight floatValue]);
        return [estimatedHeight floatValue];
    }
    //NSLog(@"not cached: %f", defaultHeight);
    return defaultHeight;
}

// check if height is on cache
- (BOOL) isEstimatedRowHeightInCache:(NSIndexPath *) indexPath {
    if ([self getEstimatedCellHeightFromCache:indexPath defaultHeight:0] > 0) {
        return YES;
    }
    return NO;
}

// init cache
-(void) initEstimatedRowHeightCacheIfNeeded {
    if (self.estimatedRowHeightCache == nil) {
        self.estimatedRowHeightCache = [[NSMutableDictionary alloc] init];
    }
}

/*
// custom [self.tableView reloadData]
-(void) tableViewReloadData {
    // clear cache on reload
    self.estimatedRowHeightCache = [[NSMutableDictionary alloc] init];
    [self.tableView reloadData];
}
*/

@end
