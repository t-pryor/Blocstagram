//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Tim on 2015-05-09.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

- (UIImage *)imageWithFixedOrientation;
- (UIImage *)imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *)imageCroppedToRect:(CGRect)cropRect;

// assignment
- (UIImage *)imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)cropRect;


@end
