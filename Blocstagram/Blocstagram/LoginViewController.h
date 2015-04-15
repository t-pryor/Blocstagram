//
//  LoginViewController.h
//  Blocstagram
//
//  Created by Tim on 2015-04-14.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

// declare a constant string; any object that needs to be notified when
// an access token is obtained will use this string
extern NSString *const LoginViewControllerDidGetAccessTokenNotification;

@end
