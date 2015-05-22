//
//  ImageLibraryCollectionViewController.h
//  Blocstagram
//
//  Created by Tim on 2015-05-20.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageLibraryViewController;


@protocol ImageLibraryViewControllerDelegate <NSObject>

- (void)imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;

@end


@interface ImageLibraryViewController : UICollectionViewController

@property (nonatomic, weak)NSObject <ImageLibraryViewControllerDelegate> *delegate;

@end