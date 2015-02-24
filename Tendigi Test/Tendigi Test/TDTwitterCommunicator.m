//
//  TDTwitterCommunicator.m
//  Tendigi Test
//
//  Created by Eric Kunz on 2/22/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//


// brookly WOEID 28751217

#import "TDTwitterCommunicator.h"
#import <TwitterKit/TwitterKit.h>

@interface TDTwitterCommunicator ()

@property (nonatomic) NSNumber *max_id;
@property (nonatomic) NSString *urlString;

@end

@implementation TDTwitterCommunicator

- (instancetype)init {
    self = [super init];
    
    // Endpoint
    self.urlString = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
    
    // Check for guest session
    if (![[Twitter sharedInstance] guestSession]) {
        [self loginGuestWithCompletion:^(bool success, NSError *error) {
            
        }];
    }
    
    return self;
}

- (void)loginGuestWithCompletion:(void(^)(bool success, NSError *error))completionHandler{
    [[Twitter sharedInstance] logInGuestWithCompletion:^
     (TWTRGuestSession *session, NSError *error) {
         if (session) {
             completionHandler(YES, nil);
             NSLog(@"-guest logged in-");
         } else {
             completionHandler(NO, error);
             NSLog(@"-Authentication Error-\n %@", [error localizedDescription]);
         }
     }];
}

- (void)getTweetsWithCompletion:(void(^)(NSArray *tweets, NSError *error))completionHandler{
    if (![[Twitter sharedInstance] guestSession]) {
        [self loginGuestWithCompletion:^(bool success, NSError *error) {
            if (error) {
                completionHandler(nil, error);
            }
        }];
    }
    
    // Request parameters
    NSDictionary *params;
    if (self.max_id) { // If there has already been one request, use max_id to get next batch of tweets
        params = @{@"screen_name":@"tendigi", @"count":[NSString stringWithFormat:@"%@", @100], @"max_id": [self.max_id stringValue]};
        NSLog(@"-request with max_id");
    } else {
        params = @{@"screen_name":@"tendigi", @"count":[NSString stringWithFormat:@"%@", @100]};
    }
    
    // Create request
    NSError *__autoreleasing error;
    NSURLRequest *twitRequest = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:self.urlString parameters:params error:&error];
    if (error) {
        NSLog(@"error creating request: %@", error);
    }
    
    [self sendTwitterRequest:twitRequest completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            completionHandler(tweets, nil);
        } else {
            completionHandler(nil, error);
        }
    }];
    
}

- (void)getTweetsNearTendigiWithCompletion:(void(^)(NSArray *tweets, NSError *error))completionHandler {
    // Tendigi location
    // latitude: 40.703236
    // longitude: -73.990691
    
    NSString *searchURL = @"https://api.twitter.com/1.1/search/tweets.json";
    
    NSDictionary *params = @{@"q":@"dumbo", @"count":@"50", @"geocode":@"40.703236,-73.990691,1mi"};
    
    NSError *error;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:searchURL parameters:params error:&error];
    
    [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSError *error;
            NSArray *jsonTweets = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error] objectForKey:@"statuses"];
            
            NSMutableArray *tweets = [[NSMutableArray alloc] init];
            for (NSDictionary *d in jsonTweets) {
                // Add tweets to my tweets array
                [tweets addObject:[[TWTRTweet alloc] initWithJSONDictionary:d]];
            }
            // Set max_id as oldest tweet's id
            long oldestID = [[[tweets lastObject] tweetID] longLongValue] - 1;
            self.max_id = [NSNumber numberWithLong:oldestID];
            completionHandler(tweets, nil);
        } else {
            NSLog(@"request error:%@", connectionError);
            completionHandler(nil, connectionError);
        }
    }];
}

- (void)sendTwitterRequest:(NSURLRequest *)request completion:(void(^)(NSArray *tweets, NSError *error))completionHandler {
    [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error;
            NSArray *jsonTweets = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (error) {
                NSLog(@"-Json reading error: %@-", error);
            }
            NSMutableArray *tweets = [[NSMutableArray alloc] init];
            for (NSDictionary *d in jsonTweets) {
                // Add tweets to my tweets array
                [tweets addObject:[[TWTRTweet alloc] initWithJSONDictionary:d]];
            }
            
            // Set max_id as oldest tweet's id
            long oldestID = [[[tweets lastObject] tweetID] longLongValue] - 1;
            self.max_id = [NSNumber numberWithLong:oldestID];
            NSLog(@"successful request");
            completionHandler(tweets, nil);
            
        } else {
            NSLog(@"request error:%@", connectionError);
            completionHandler(nil, connectionError);
        }
    }];
}

- (void)getNewTweetsWithCompletion:(void (^)(NSArray *tweets, NSError *error))completionHandler {
    self.max_id = nil;
    
    [self getTweetsWithCompletion:^(NSArray *tweets, NSError *error) {
        completionHandler(tweets, error);
    }];
    
}

@end
