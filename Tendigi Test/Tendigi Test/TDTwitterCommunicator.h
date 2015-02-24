//
//  TDTwitterCommunicator.h
//  Tendigi Test
//
//  Created by Eric Kunz on 2/22/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//
//  Makes Twitter REST API requests

#import <Foundation/Foundation.h>

@interface TDTwitterCommunicator : NSObject

- (void)getTweetsWithCompletion:(void(^)(NSArray *tweets, NSError *error))completionHandler;
- (void)getNewTweetsWithCompletion:(void (^)(NSArray *tweets, NSError *error))completionHandler; // For table refresh
- (void)getTweetsNearTendigiWithCompletion:(void(^)(NSArray *tweets, NSError *error))completionHandler;

@end
