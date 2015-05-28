//
//  CropImageViewController.m
//  Blocstagram
//
//  Created by Tim on 2015-05-20.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropBox.h"
#import "Media.h"
#import "UIImage+ImageUtilities.h"

@interface CropImageViewController ()

@property (nonatomic, strong) CropBox *cropBox;
@property (nonatomic, assign) BOOL hasLoadedOnce;

// Assignment
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@end

@implementation CropImageViewController


- (instancetype)initWithImage:(UIImage *)sourceImage
{
    self = [super init];
    
    if (self) {
        self.media = [[Media alloc] init];
        self.media.image = sourceImage;
        self.topView = [UIToolbar new]; // Assignment
        self.cropBox = [CropBox new];
        self.bottomView = [UIToolbar new]; // Assignment
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    
    // Assignment
    [self.view addSubview:self.cropBox];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:NSLocalizedString(@"Crop", @"Crop command") style:UIBarButtonItemStyleDone target:self action:@selector(cropPressed:)];
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    // Assignment
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
    
    
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    
    
    CGRect cropRect = CGRectZero;
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    cropRect.size = CGSizeMake(edgeSize, edgeSize);
    
    CGSize size = self.view.frame.size;
    
    self.cropBox.frame = cropRect;
    self.cropBox.center = CGPointMake(size.width / 2, size.height / 2);
    self.scrollView.frame = self.cropBox.frame;
    self.scrollView.clipsToBounds = NO;
    
    [self recalculateZoomScale];
    
    if (self.hasLoadedOnce == NO) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }

    
}

- (void)cropPressed:(UIBarButtonItem *)sender
{
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.delegate cropControllerFinishedWithImage:scrollViewCrop];
    
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
