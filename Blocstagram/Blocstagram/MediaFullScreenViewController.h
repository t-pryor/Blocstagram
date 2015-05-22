//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Tim on 2015-04-22.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) Media *media;

- (instancetype)initWithMedia:(Media *)media;

- (void)centerScrollView;
- (void)recalculateZoomScale;

@end
