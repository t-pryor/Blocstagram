//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Tim on 2015-04-22.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"

@interface MediaFullScreenViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation MediaFullScreenViewController

- (instancetype)initWithMedia:(Media *)media
{
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // create and configure a scroll view and add as the only subview of self.view
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    // create an image view, set the image and add it as a subview of the scroll view
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview:self.imageView];
    
    // this represents the size of the content view, which is the content being scrolled around
    // we are scrolling around an image, so we pass in its size
    // 640 x 640
    self.scrollView.contentSize = self.media.image.size;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    // allows one gesture recognizer to wait for another gesture recognizer to fail before it succeeds
    // without this, it would be impossible to double-tap because the single-tap gesture recognizer
    // would fire before the user had a chance to tap twice
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // scroll view's frame is set to the view's bounds
    self.scrollView.frame = self.view.bounds;
    
    // Examine two ratios:
    // 1. ratio of the scroll view's width to the image's width
    // 2. ratio of the scroll view's height to the image's height
    // Whichever is smaller will become our minimumZoomScale.
    // This prevents the user from pinching the image so small that there's wasted screen space
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    //CGFloat minScale = 0.2;
    
    //A floating-point value that specifies the minimum scale factor that
    // can be applied to the scroll view’s content.
    self.scrollView.minimumZoomScale = minScale;
    // maximumZoomScale will always be 1 (100%)
    // if bigger, image would get pixelated if user zooms too much
    self.scrollView.maximumZoomScale = 1;
}

- (void)centerScrollView
{
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self centerScrollView];
}


#pragma mark - UIScrollViewDelegate

// tells the scroll view which view to zoom in and out on
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

// call centerScrollView after the user has changed the zoom level
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollView];
}


#pragma mark - Gesture Recognizers

- (void)tapFired:(UITapGestureRecognizer *)sender
{
    // Dismisses the view controller that was presented modally by the receiver
    // The presenting view controller is responsible for dismissing the view controller it presented.
    // If you call this method on the presented view controller itself, it automatically forwards
    // the message to the presenting view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doubleTapFired:(UITapGestureRecognizer *)sender
{
    // if the current zoom scale is already as small as it can be, double-tapping will zoom in
    // this works by calculating a rectangle using the finger as a center point and telling the
    // scroll view to zoom in on that rectangle
    
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        // if the current zoom scale is larger then zoom out to the minimum scale
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
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
