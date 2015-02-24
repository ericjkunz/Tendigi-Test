//
//  TDTwitterFeedTableViewController.m
//  Tendigi Test
//
//  Created by Eric Kunz on 2/18/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//
//  This class controls the main table view with the Tendigi Twitter feed

#import "TDTwitterFeedTableViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TDTwitterFeedTableViewDataSource.h"
#import "TDGeoTwitterFeedTableViewController.h"
#import "UIColor+TDColor.h"

@interface TDTwitterFeedTableViewController () <TWTRTweetViewDelegate, UITableViewDelegate>

{
    TDTwitterFeedTableViewDataSource *_dataSource;
}

@property (nonatomic) NSURL *viewingURL;

@end


@implementation TDTwitterFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Data source
    _dataSource = [[TDTwitterFeedTableViewDataSource alloc] initLocationBased:NO];
    _dataSource.tweetDelegate = self;
    self.tableView.dataSource = _dataSource;
    
    self.tableView.allowsSelection = NO;
    
    // Navigation bar buttons
    UIBarButtonItem *mentionButton = [[UIBarButtonItem alloc] initWithTitle:@"@" style:UIBarButtonItemStylePlain target:self action:@selector(mentionButtonHit:)];
    mentionButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = mentionButton;
    
    UIBarButtonItem *localTweetsButton = [[UIBarButtonItem alloc] initWithTitle:@"Local" style:UIBarButtonItemStylePlain target:self action:@selector(localTweetsButton:)];
    self.navigationItem.leftBarButtonItem = localTweetsButton;
    
    // Pull to refresh
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor tendigiPurple];
    
    self.tableView.delegate = self;
    self.estimatedRowHeightCache = [[TDTableViewHeightCache alloc] init];
    _dataSource.estimatedRowHeightCache = self.estimatedRowHeightCache;
}

- (void)refreshTable:(id)sender {
    [_dataSource refreshTweetsCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self.tableView reloadData];
            [(UIRefreshControl *)sender endRefreshing];
        } else {
            [self showErrorAlert:error];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showErrorAlert:(NSError *)error {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error Laoding Tweets" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.estimatedRowHeightCache getEstimatedCellHeightFromCache:indexPath defaultHeight:41.5];
}

#pragma mark - TWTRTweetViewDelegate

- (void)tweetView:(TWTRTweetView *)tweetView didSelectTweet:(TWTRTweet *)tweet {
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
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.viewingURL] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
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
