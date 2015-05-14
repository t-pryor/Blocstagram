//
//  CameraViewController.m
//
//
//  Created by Tim on 2015-05-06.
//
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CameraToolbar.h"
#import "UIImage+ImageUtilities.h"

@interface CameraViewController () <CameraToolbarDelegate>

// shows the user the image from the camera
@property (nonatomic, strong) UIView *imagePreview;
// session coordinates data from inputs (cameras and microphones) to the outputs (movie files and still images)
@property (nonatomic, strong) AVCaptureSession *session;
// special type of CALayer that displays video from a camera
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
// horizontalLines and verticalLines will contain thin, white UIViews that will compose a 3x3 photo grid over the photo capture area
@property (nonatomic, strong) NSArray *horizontalLines;
@property (nonatomic, strong) NSArray *verticalLines;
// topView and bottomView are UIToolbars
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@property (nonatomic, strong) CameraToolbar *cameraToolbar;

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createViews];
    [self addViewsToViewHierarchy];
    [self setupImageCapture];
    [self createCancelButton];
    
}

- (void)createViews
{
    self.imagePreview = [UIView new];
    self.topView = [UIToolbar new];
    self.bottomView = [UIToolbar new];
    self.cameraToolbar = [[CameraToolbar alloc] initWithImageNames:@[@"rotate", @"road"]];
    self.cameraToolbar.delegate = self;
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
}

- (void)addViewsToViewHierarchy
{
    NSMutableArray *views = [@[self.imagePreview, self.topView, self.bottomView] mutableCopy];
    [views addObjectsFromArray:self.horizontalLines];
    [views addObjectsFromArray:self.verticalLines];
    [views addObject:self.cameraToolbar];
    
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
}

- (void)setupImageCapture
{
    // create a capture session, which mediaes between the camera and output layer
    self.session = [[AVCaptureSession alloc] init];
    
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.masksToBounds = YES;
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    
    // request permission from th user to access the camera
    // Because user may not respond immediately, response is handled asynchronously in a completion block
    [AVCaptureDevice
     requestAccessForMediaType:AVMediaTypeVideo
     completionHandler:^(BOOL granted)
     {
     dispatch_async(dispatch_get_main_queue(), ^
                    {
                    if (granted) {
                        //create a device which represents the camera
                        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                        
                        NSError *error = nil;
                        // provide data to the AVCaptureSession through an AVDeviceInput object
                        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                                            error:&error];
                        if (!input) {
                            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                                             message:error.localizedRecoverySuggestion
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                            [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OKButton")
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:^(UIAlertAction *action)
                                                                      {
                                                                          [self.delegate cameraViewController:self didCompleteWithImage:nil];
                                                                      }
                                                ]
                            ];
                        
                        } else { //#7  add the input to our capture session
                            
                            [self.session addInput:input];
                            
                            // create a still image output that saves JPEG files
                            self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                            
                            self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
                            
                            [self.session addOutput:self.stillImageOutput];
                            
                            [self.session startRunning];
                            
                        }
                        
                    } else {
                        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera Permission Denied", @"camera permission denied title") message:NSLocalizedString(@"This app doesn't have permission to use the camera; please update your privacy settings.", @"camera permission denied recovery suggestion") preferredStyle:UIAlertControllerStyleAlert];
                        
                        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                            {
                                            [self.delegate cameraViewController:self didCompleteWithImage:nil];
                                            
                                            
                                            }]];
                        
                        [self presentViewController:alertVC animated:YES completion:nil];
                    }
                    
                    });
     
     }];
    
}

- (void)createCancelButton
{
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}


- (NSArray *)horizontalLines
{
    if (!_horizontalLines) {
        _horizontalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _horizontalLines;
}

- (NSArray *)verticalLines
{
    if (!_verticalLines) {
        _verticalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _verticalLines;
}

- (NSArray *)newArrayOfFourWhiteViews
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [array addObject:view];
    }
    
    return array;
}

- (void)setUpImageCapture
{
    // create a capture session, which mediates between the camera and output layer
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // create captureVideoPreviewLayer to display the camera content
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    // Specifies that the player should preserve the video’s aspect ratio and fill the layer’s bounds
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.captureVideoPreviewLayer.masksToBounds = YES;
    // addSublayer: analogous to calling addSubview: on a UIView
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    [AVCaptureDevice
     requestAccessForMediaType:AVMediaTypeVideo
     completionHandler:^(BOOL granted)
     {
     dispatch_async(dispatch_get_main_queue(), ^
                    {
                    if (granted) {
                        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                        
                        NSError *error = nil;
                        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                        if (!input) {
                            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                                             message:error.localizedRecoverySuggestion
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                            [alertVC addAction:[UIAlertAction
                                                actionWithTitle:NSLocalizedString(@"OK", @"OK button")
                                                style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action)
                                                {
                                                    [self.delegate cameraViewController:self
                                                                   didCompleteWithImage:nil];
                                                }
                                                ]
                             ];
                            
                            [self presentViewController:alertVC animated:YES completion:nil];
                            
                            
                        } else {
                            [self.session addInput:input];
                            self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                            self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
                            [self.session addOutput:self.stillImageOutput];
                            [self.session startRunning];
                            
                        }
                        
                    } else {
                        UIAlertController *alertVC =
                        [UIAlertController
                         alertControllerWithTitle:NSLocalizedString(@"Camera Permission Denied", @"camera permission denied title")
                         message:NSLocalizedString(@"This app doesn't have permission to use the camera; please update your privacy settings.", @"camera permission denied recovery suggestion")
                         preferredStyle:UIAlertControllerStyleAlert
                         ];
                        
                        [self presentViewController:alertVC animated:YES completion:nil];
                    }
                    });
     
     }];
    
}

#pragma mark - Event Handling

- (void)cancelPressed:(UIBarButtonItem *)sender
{
    [self.delegate cameraViewController:self didCompleteWithImage:nil];
}


#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    
    CGFloat thirdOfWidth = width / 3;
    
    for (int i = 0; i < 4; i++) {
        UIView *horizontalLine = self.horizontalLines[i];
        UIView * verticalLine = self.verticalLines[i];
        
        horizontalLine.frame = CGRectMake(0, (i * thirdOfWidth) + CGRectGetMaxY(self.topView.frame), width, 0.5);
        
        CGRect verticalFrame = CGRectMake(i * thirdOfWidth, CGRectGetMaxY(self.topView.frame), 0.5, width);
        
        
        if (i == 3) {
            verticalFrame.origin.x -= 0.5;
        }
        
        verticalLine.frame = verticalFrame;
        
    }
    
    self.imagePreview.frame = self.view.bounds;
    self.captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    
    CGFloat cameraToolbarHeight = 100;
    self.cameraToolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - cameraToolbarHeight, width, cameraToolbarHeight);
    
}

#pragma mark - CameraToolbarDelegate

- (void)leftButtonPressedOnToolbar:(CameraToolbar *)toolbar
{
    // get the current input and an array of all possible video devices
    AVCaptureDeviceInput *currentCameraInput = self.session.inputs.firstObject;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 1) {
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1) {
            newIndex = currentIndex + 1;
        }
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        
        if (newVideoInput) {
            UIView *fakeView = [self.imagePreview snapshotViewAfterScreenUpdates:YES];
            
            fakeView.frame = self.imagePreview.frame;
            [self.view insertSubview:fakeView aboveSubview:self.imagePreview];
            
            [self.session beginConfiguration];
            [self.session removeInput:currentCameraInput];
            [self.session addInput:newVideoInput];
            [self.session commitConfiguration];
            
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
                                         {
                                            fakeView.alpha = 0;
                                         }
                                                         completion:^(BOOL finished)
                                         {
                                            [fakeView removeFromSuperview];
                                         }
             ];
        }
    }
}


- (void)rightButtonPressedOnToolbar:(CameraToolbar *)toolbar
{
    NSLog(@"Photo library button pressed.");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar
{
    AVCaptureConnection *videoConnection;
    
    // #8
    // Find the connection object
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    
    }
    
    [self.stillImageOutput
     captureStillImageAsynchronouslyFromConnection:videoConnection
     completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
                        {
                        if (imageSampleBuffer) {
                            //#10
                            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
                        
                            //#11
                            image = [image imageWithFixedOrientation];
                            image = [image imageResizedToMatchAspectRatioOfSize:self.captureVideoPreviewLayer.bounds.size];
                            
                            // #12
                            UIView *leftLine = self.verticalLines.firstObject;
                            UIView *rightLine = self.verticalLines.lastObject;
                            UIView *topLine = self.horizontalLines.firstObject;
                            UIView *bottomLine = self.horizontalLines.lastObject;
                            
                            CGRect gridRect = CGRectMake(CGRectGetMinX(leftLine.frame), CGRectGetMinY(topLine.frame), CGRectGetMaxX(rightLine.frame) - CGRectGetMinX(leftLine.frame), CGRectGetMinY(bottomLine.frame) - CGRectGetMinY(topLine.frame));
                            
                            CGRect cropRect = gridRect;
                            cropRect.origin.x = (CGRectGetMinX(gridRect) + (image.size.width - CGRectGetWidth(gridRect)) / 2);
                            
                            image = [image imageCroppedToRect:cropRect];
                            
                            // #13
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate cameraViewController:self didCompleteWithImage:image];
                            });
                            
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                           UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
                                           [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                                       {
                                                       [self.delegate cameraViewController:self didCompleteWithImage:nil];
                                                       }
                                                               ]
                                            ];
                                           
                                           [self presentViewController:alertVC animated:YES completion:nil];
                                           
                                        
                                           });
                        }
                        
                        }];

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
