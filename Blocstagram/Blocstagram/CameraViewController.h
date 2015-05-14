//
//  CameraViewController.h
//
//
//  Created by Tim on 2015-05-06.
//
//





#import <UIKit/UIKit.h>

@class CameraViewController;

// A delegate property and accompanying protocol will inform the present view controller when the view controller is done
// ImagesTableViewController is the presenting view controller
@protocol CameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *) image;

@end

@interface CameraViewController : UIViewController

@property (nonatomic, weak) NSObject <CameraViewControllerDelegate> *delegate;

@end
