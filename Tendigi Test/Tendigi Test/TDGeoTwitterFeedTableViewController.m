//
//  TDGeoTwitterFeedTableViewController.m
//  Tendigi Test
//
//  Created by Eric Kunz on 2/23/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//

#import "TDGeoTwitterFeedTableViewController.h"
#import "TDTwitterFeedTableViewDataSource.h"
#import "UIColor+TDColor.h"

@interface TDGeoTwitterFeedTableViewController () <TWTRTweetViewDelegate>

{
    TDTwitterFeedTableViewDataSource *_dataSource;
}

@property (nonatomic) NSURL *viewingURL;

@end

@implementation TDGeoTwitterFeedTableViewController

- (void)viewDidLoad {
    // Data source
    _dataSource = [[TDTwitterFeedTableViewDataSource alloc] initLocationBased:YES];
    _dataSource.tweetDelegate = self;
    self.tableView.dataSource = _dataSource;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"tweetCell"];
    
    // Navigation Bar
    self.navigationItem.title = @"Tweets Near Tendigi";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonHit:)];
    
    self.tableView.delegate = self;
    self.estimatedRowHeightCache = [[TDTableViewHeightCache alloc] init];
    _dataSource.estimatedRowHeightCache = self.estimatedRowHeightCache;
}

- (void)doneButtonHit:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TWTRTweetViewDelegate

- (void)tweetView:(TWTRTweetView *)tweetView didSelectTweet:(TWTRTweet *)tweet {
    NSLog(@"user selected tweet");
    
    // Get link from tweet's text
    NSError *error;
    NSDataDetector *dataDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
    
    NSString *tweetText = tweet.text;
    NSArray *matches = [dataDetector matchesInString:tweetText options:0 range:NSMakeRange(0, [tweetText length])];
    
    NSURL *url = [[matches firstObject] URL];
    
    if (url) {
        // Open a webview
        UIViewController *webViewController = [[UIViewController alloc] init];
        webViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareSite:)];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:webViewController.view.bounds];
        self.viewingURL = url;
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        webViewController.view = webView;
        
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    
}

- (void)shareSite:(id)sender {
    UIActivityViewController *acitivtyVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.viewingURL] applicationActivities:nil];
    [self presentViewController:acitivtyVC animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.estimatedRowHeightCache getEstimatedCellHeightFromCache:indexPath defaultHeight:41.5];
}


#pragma mark - Button Actions

- (void)mentionButtonHit:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"@Tendigi You are Awesome!"];
        [self.navigationController presentViewController:tweetSheet animated:YES completion:nil];
    }
}

- (void)localTweetsButton:(id)sender {
    TDGeoTwitterFeedTableViewController *geoVC = [[TDGeoTwitterFeedTableViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:geoVC];
    
    [self presentViewController:navVC animated:YES completion:nil];
}
@end
