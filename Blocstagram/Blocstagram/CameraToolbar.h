//
//  CameraToolbar.h
//  Blocstagram
//
//  Created by Tim on 2015-05-06.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

// The toolbar will have three buttons: customizable left and right buttons, and a center button that looks like a camera

#import <UIKit/UIKit.h>

@class CameraToolbar;

// The view will know nothing about the function of these buttons
// The delegate will be informed when the buttons are pressed
@protocol CameraToolbarDelegate <NSObject>

- (void)leftButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void)rightButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void)cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar;

@end

@interface CameraToolbar : UIView

// the image names for the icons on the side buttons will be passed to initWithImageNames:
- (instancetype)initWithImageNames:(NSArray *)imageNames;

@property (nonatomic, weak)NSObject <CameraToolbarDelegate> *delegate;

@end
