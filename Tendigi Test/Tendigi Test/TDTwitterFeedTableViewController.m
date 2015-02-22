//
//  TDTwitterFeedTableViewController.m
//  Tendigi Test
//
//  Created by Eric Kunz on 2/18/15.
//  Copyright (c) 2015 Eric J Kunz. All rights reserved.
//
// This class controls the main table view with the Tendigi Twitter feed

#import "TDTwitterFeedTableViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TDTwitterFeedTableViewDataSource.h"

@interface TDTwitterFeedTableViewController () <TWTRTweetViewDelegate>

{
    TDTwitterFeedTableViewDataSource *_dataSource;
}

@end


@implementation TDTwitterFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [[TDTwitterFeedTableViewDataSource alloc] initWithCompletion:^(bool success, NSError *error) {
        self.tableView.dataSource = _dataSource;

        if (success) {
            [self.tableView reloadData];
        } else {
            [self showErrorAlert:error];
        }
    }];
    
    // Navigation bar buttons
    UIBarButtonItem *mentionButton = [[UIBarButtonItem alloc] initWithTitle:@"@" style:UIBarButtonItemStylePlain target:self action:@selector(mentionButtonHit:)];
    mentionButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = mentionButton;
    
    // Pull to refresh
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotMoreTweets) name:@"gotMoreTweets" object:nil];
    
    
}

- (void)refreshTable:(id)sender {
    NSLog(@"Refreshing");
    
    [_dataSource refreshTableWithCompletion:^(bool success, NSError *error) {
        if (success) {
            [self.tableView reloadData];
            [(UIRefreshControl *)sender endRefreshing];
        } else {
            [self showErrorAlert:error];
        }
    }];
    
}

- (void)gotMoreTweets {
    [self.tableView reloadData];
    NSLog(@"-got more tweets, reloading table-");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTweetsWithCompletion {
    [_dataSource loadTweetsWithCompletion:^(bool success, NSError *error) {
        if (success) {
            [self.tableView reloadData];
        } else {
            [self showErrorAlert:error];
        }
    }];
}

- (void)showErrorAlert:(NSError *)error {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error Laoding Tweets" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Twitter Delgate

- (void)tweetView:(TWTRTweetView *)tweetView didTapURL:(NSURL *)url {
    // Open a webview
    UIViewController *webViewController = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webViewController.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    webViewController.view = webView;
    
    [self.navigationController pushViewController:webViewController animated:YES];
}


#pragma mark - Button Actions

- (void)mentionButtonHit:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"@Tendigi You are Awesome!"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

@end
