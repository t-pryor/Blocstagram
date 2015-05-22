//
//  CropImageViewController.h
//  Blocstagram
//
//  Created by Tim on 2015-05-20.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "MediaFullScreenViewController.h"

@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

- (void)cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end



@interface CropImageViewController : MediaFullScreenViewController

- (instancetype)initWithImage:(UIImage *)sourceImage;

@property (nonatomic, weak) NSObject <CropImageViewControllerDelegate> *delegate;

@end
