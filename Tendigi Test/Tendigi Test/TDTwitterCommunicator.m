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
    
    NSMutableArray *tweets = [[NSMutableArray alloc] init];
    
    // Send request
    [[[Twitter sharedInstance] APIClient] sendTwitterRequest:twitRequest completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error;
            NSArray *jsonTweets = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"-Json reading error: %@-", error);
            }
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

- (void)sendTwitterRequest:(NSURLRequest *)request {
    
}

- (void)getTweetsNearTendigiWithCompletion:(void(^)(NSArray *tweets, NSError *error))completionHandler{
    
}

- (void)getNewTweetsWithCompletion:(void (^)(bool success, NSError *error))completionHandler {
    self.max_id = nil;
    
    [self getTweetsWithCompletion:^(NSArray *tweets, NSError *error) {
        completionHandler(tweets, error);
    }];
    
}

@end
