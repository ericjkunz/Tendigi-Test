//
//  TDTableViewHeightCache.h
//  Tendigi Test
//
//  Created by Eric Kunz on 2/24/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TDTableViewHeightCache : NSObject

@property NSMutableDictionary *estimatedRowHeightCache;

- (void) putEstimatedCellHeightToCache:(NSIndexPath *) indexPath height:(CGFloat) height;
- (CGFloat) getEstimatedCellHeightFromCache:(NSIndexPath *) indexPath defaultHeight:(CGFloat) defaultHeight;
- (BOOL) isEstimatedRowHeightInCache:(NSIndexPath *) indexPath;
- (void) initEstimatedRowHeightCacheIfNeeded;


@end
