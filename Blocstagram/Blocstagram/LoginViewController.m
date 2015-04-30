//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Tim on 2015-04-14.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end


@implementation LoginViewController

// make string equal to name: convention, not necessary
NSString *const LoginViewControllerDidGetAccessTokenNotification =
                    @"LoginViewControllerDidGetAccessTokenNotification";

- (NSString *)redirectURI
{
    return @"http://bloc.io";
}

- (void)viewDidLoad {
    [super viewDidLoad];
   // [self clearInstagramCookies];
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    [[self view] addSubview:webView];
    self.webView = webView;
    
    self.title = NSLocalizedString(@"Login", @"Login");
    
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }

}

- (void)viewWillLayoutSubviews
{
    self.webView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// When the login controller gets deallocated, do two things:
// 1. Set the web view's delegate to nil (a quirk of UIWebView, most objects don't require this).
// 2. Clear cookies set by the Instagram website

- (void)dealloc
{
    // Removing this line can cause a flickering effect when you relaunch the app after logging in,
    // as the web view is briefly displayed, automatically authenticates with cookies,
    // returns the access token and dismisses the login view, sometimes in less than a second
    [self clearInstagramCookies];
    
    self.webView.delegate = nil;
}
    /*
     Clears Instagram cookies. This prevents caching the credentials in the cookie jar
     NSHTTPCookieStorage (aka 'the cookie jar') stores and manages web site cookies,
     which are represented by NSHTTPCookie objects
     */
- (void)clearInstagramCookies
{

    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram"];
        if (domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }

}

// check in one of the view's navigation delegate methods for a redirection
// beginning with our redirect URI
// if it's there extract the access token and stop the web view from loading

// search for a URL containing the redirect URI, then set the access token to everything after access_token;

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    
    // grab the token, starts after =
    // http://your-redirect-uri#access_token=ACCESS-TOKEN
    
    if ([urlString hasPrefix:[self redirectURI]]) {
        // This contains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location +
        rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter]
                    postNotificationName:LoginViewControllerDidGetAccessTokenNotification
                                  object:accessToken];
        
        return NO;
    }
    
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
