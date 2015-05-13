//
//  CameraViewController.h
//
//
//  Created by Tim on 2015-05-06.
//
//

#import <UIKit/UIKit.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *) image;

@end

@interface CameraViewController : UIViewController

@property (nonatomic, weak) NSObject <CameraViewControllerDelegate> *delegate;

@end
