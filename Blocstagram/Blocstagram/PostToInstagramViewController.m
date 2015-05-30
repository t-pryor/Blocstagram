//
//  PostToInstagramViewController.m
//  Blocstagram
//
//  Created by Tim on 2015-05-25.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "PostToInstagramViewController.h"

@interface PostToInstagramViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIDocumentInteractionControllerDelegate>

// stores the image passed with initWithImage
@property (nonatomic, strong) UIImage *sourceImage;
// displays the image with its current filter
@property (nonatomic, strong) UIImageView *previewImageView;
// stores the photo filter operatons
@property (nonatomic, strong) NSOperationQueue *photoFilterOperationQueue;
// shows all the filters available
@property (nonatomic, strong) UICollectionView *filterCollectionView;
// these arrays hold filtered images and their titles
@property (nonatomic, strong) NSMutableArray *filterImages;
@property (nonatomic, strong) NSMutableArray *filterTitles;
// send to Instagram button
@property (nonatomic, strong) UIButton *sendButton;
// shows on short iPhones in the navigation bar where there's no room for send button
@property (nonatomic, strong) UIBarButtonItem *sendBarButton;
// shares the image with Instagram
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation PostToInstagramViewController

- (instancetype)initWithImage:(UIImage *)sourceImage
{
    self = [super init];
    
    if (self) {
        // store the source image passed in and initialize the preview image with that image
        self.sourceImage = sourceImage;
        self.previewImageView = [[UIImageView alloc] initWithImage:self.sourceImage];
        
        // create the operation queue
        self.photoFilterOperationQueue = [[NSOperationQueue alloc] init];
        
        // Create and configure a UICollectionFlowLayout instance to define the layout of our filter
        // collection view, and then use it to initialize a UICollectionView
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(44, 64);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        
        self.filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.filterCollectionView.dataSource = self;
        self.filterCollectionView.delegate = self;
        self.filterCollectionView.showsHorizontalScrollIndicator = NO;
        
        // The first object in each array represents the unfiltered image
        self.filterImages = [NSMutableArray arrayWithObject:sourceImage];
        self.filterTitles = [NSMutableArray arrayWithObject:NSLocalizedString(@"None", @"Label for when no filter is applied to a photo")];
        
        // create both sendButton and sendBarButton->they both have the same target-action method
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.sendButton.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1]; /*#58516c*/
        self.sendButton.layer.cornerRadius = 5;
        [self.sendButton setAttributedTitle:[self sendAttributedString] forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.sendBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send button") style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonPressed:)];
        
        [self addFiltersToQueue];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.view addSubview:self.previewImageView];
    [self.view addSubview:self.filterCollectionView];
    
    // less than 500 = 3.5inch iphone
    if (CGRectGetHeight(self.view.frame) > 500) {
        [self.view addSubview:self.sendButton];
    } else {
        self.navigationItem.rightBarButtonItem = self.sendBarButton;
    }
    
    
    [self.filterCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.filterCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = NSLocalizedString(@"Apply Filter", @"apply filter view title");
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    self.previewImageView.frame = CGRectMake(0, self.topLayoutGuide.length, edgeSize, edgeSize);
    
    CGFloat buttonHeight = 50;
    CGFloat buffer = 10;
    
    CGFloat filterViewYOrigin = CGRectGetMaxY(self.previewImageView.frame) + buffer;
    CGFloat filterViewHeight;
    
    if (CGRectGetHeight(self.view.frame) > 500) {
        self.sendButton.frame = CGRectMake(buffer, CGRectGetHeight(self.view.frame) - buffer - buttonHeight, CGRectGetWidth(self.view.frame) - 2 * buffer, buttonHeight);
        filterViewHeight = CGRectGetHeight(self.view.frame) - filterViewYOrigin - buffer - buffer - CGRectGetHeight(self.sendButton.frame);
    } else {
        filterViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.previewImageView.frame) - buffer - buffer;
    }
    
    self.filterCollectionView.frame = CGRectMake(0, filterViewYOrigin, CGRectGetWidth(self.view.frame), filterViewHeight);
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(CGRectGetHeight(self.filterCollectionView.frame) - 20, CGRectGetHeight(self.filterCollectionView.frame));
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (NSAttributedString *) sendAttributedString
{
    NSString *baseString = NSLocalizedString(@"SEND TO INSTAGRAM", @"send to Instagram button text");
    NSRange range = [baseString rangeOfString:baseString];
    
    
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    [commentString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13] range:range];
    [commentString addAttribute:NSKernAttributeName value:@1.3 range:range];
    [commentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.933  green:0.933 blue:0.933 alpha:1] range:range];
    
    return commentString;
    
}

#pragma mark - UICollectionView delegate and data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filterImages.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
   // FilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
    
    
    
    static NSInteger imageViewTag = 1000;
    static NSInteger labelTag = 1001;
    
    UIImageView *thumbnail = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:labelTag];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;
    CGFloat thumbnailEdgeSize = flowLayout.itemSize.width;
    
    if (!thumbnail) {
        thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        thumbnail.tag = imageViewTag;
        thumbnail.clipsToBounds = YES;
        
        [cell.contentView addSubview:thumbnail];
    }
    
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        label.tag = labelTag;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        [cell.contentView addSubview:label];
                 
    }
    
    thumbnail.image = self.filterImages[indexPath.row];
    label.text = self.filterTitles[indexPath.row];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.previewImageView.image = self.filterImages[indexPath.row];
}

#pragma mark - Photo Filters

- (void)addCIImageToCollectionView:(CIImage *)CIImage withFilterTitle:(NSString *)filterTitle
{
    // convert the CIImage to a UIImage. Because CIImage isn't fully rendered, the output UIImage is slow to draw
    UIImage *image = [UIImage imageWithCIImage:CIImage scale:self.sourceImage.scale orientation:self.sourceImage.imageOrientation];
    if (image) {
        // Decompress image
        // force the UIImage to draw then saves the drawn UIImage
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawAtPoint:CGPointZero];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // on the main thread, add the completed UIImage and filter title to the arrays and tells the collection view that a new item is available
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger newIndex = self.filterImages.count;
            [self.filterImages addObject:image];
            [self.filterTitles addObject:filterTitle];
            
            [self.filterCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:0]]];
        });
    }
}

- (void) addFiltersToQueue
{
    CIImage *sourceCIImage = [CIImage imageWithCGImage:self.sourceImage.CGImage];
    
    // addOperationWithBlock: takes a block of code and adds it to the operation queue, which means it will run eventually
    // The operation queue executes as many blocks as it can, up to its maxConcurrentOperationCount
    // Because more than one operation can run at a time, the operations won't necessarily finish in the same order they're started
    
    // Noir filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *noirFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
        
        if (noirFilter) {
            [noirFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:noirFilter.outputImage withFilterTitle:NSLocalizedString(@"Noir", @"Noir Filter")];
        }
    }];
    
    // Boom filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *boomFilter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
        
        if (boomFilter) {
            [boomFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:boomFilter.outputImage withFilterTitle:NSLocalizedString(@"Boom", @"Boom Filter")];
        }
    }];
    
    // Warm filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *warmFilter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
        
        if (warmFilter) {
            [warmFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:warmFilter.outputImage withFilterTitle:NSLocalizedString(@"Warm", @"Warm Filter")];
        }
    }];
    
    // Pixel filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *pixelFilter = [CIFilter filterWithName:@"CIPixellate"];
        
        if (pixelFilter) {
            [pixelFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:pixelFilter.outputImage withFilterTitle:NSLocalizedString(@"Pixel", @"Pixel Filter")];
        }
        
    }];
    
    
    // Moody filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *moodyFilter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
    
        if (moodyFilter) {
            [moodyFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:moodyFilter.outputImage withFilterTitle:NSLocalizedString(@"Moody", @"Moody Filter")];
        }
        
    }];
    
    // Assignment
    // Monochrome Filter
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *monoFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
        
        if (monoFilter) {
            [monoFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:monoFilter.outputImage withFilterTitle:NSLocalizedString(@"Monochrome", @"Monochrome Filter")];
        }
    }];
    
    // Assignment
    // Compound filter: Monochrome + Pixellate
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *pixelFilter = [CIFilter filterWithName:@"CIPixellate"];
        CIFilter *monoFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
        
        if (pixelFilter) {
            [pixelFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            
            CIImage *result = pixelFilter.outputImage;
            
            if (monoFilter) {
                [monoFilter setValue:result forKeyPath:kCIInputImageKey];
                result = monoFilter.outputImage;
                
            }
            
            [self addCIImageToCollectionView:result withFilterTitle:NSLocalizedString(@"MonoPixel", @"MonoPixelFilter")];
            
            
        }
    }];
    
    
    
    
    
    
    
    
    
    // Drunk filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *drunkFilter = [CIFilter filterWithName:@"CIConvolution5X5"];
        CIFilter *tiltFilter = [CIFilter filterWithName:@"CIStraightenFilter"];
        
        if (drunkFilter) {
            [drunkFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            
            CIVector *drunkVector = [CIVector vectorWithString:@"[0.5 0 0 0 0 0 0 0 0 0.05 0 0 0 0 0 0 0 0 0 0 0.05 0 0 0 0.5]"];
            [drunkFilter setValue:drunkVector forKey:@"inputWeights"];
            
            CIImage *result = drunkFilter.outputImage;
            
            if (tiltFilter) {
                [tiltFilter setValue:result forKeyPath:kCIInputImageKey];
                [tiltFilter setValue:@0.2 forKeyPath:kCIInputAngleKey];
                result = tiltFilter.outputImage;
                
            }
            
            [self addCIImageToCollectionView:result withFilterTitle:NSLocalizedString(@"Drunk", @"Drunk Filter")];
            
             
        }
    }];
    
    // Film filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        // #1
        CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"];
        [sepiaFilter setValue:@1 forKey:kCIInputIntensityKey];
        [sepiaFilter setValue:sourceCIImage forKey:kCIInputImageKey];
    
        // #2
        CIFilter *randomFilter = [CIFilter filterWithName:@"CIRandomGenerator"];
        
        CIImage *randomImage = [CIFilter filterWithName:@"CIRandomGenerator"].outputImage;
        
        // #3
        CIImage *otherRandomImage = [randomImage imageByApplyingTransform:CGAffineTransformMakeScale(1.5, 25.0)];
        
        // #4
        CIFilter *whiteSpecks = [CIFilter filterWithName:@"CIColorMatrix" keysAndValues:kCIInputImageKey, randomImage,
                                 @"inputRVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputGVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputBVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                 @"inputAVector", [CIVector vectorWithX:0.0 Y:0.01 Z:0.0 W:0.0],
                                 @"inputBiasVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                 nil];
        
        
        CIFilter *darkScratches = [CIFilter filterWithName:@"CIColorMatrix" keysAndValues:kCIInputImageKey, otherRandomImage,
                                   @"inputRVector", [CIVector vectorWithX:3.659f Y:0.0 Z:0.0 W:0.0],
                                   @"inputGVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputBVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputAVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputBiasVector", [CIVector vectorWithX:0.0 Y:1.0 Z:1.0 W:1.0],
                                   nil];
        // #5
        CIFilter *minimumComponent = [CIFilter filterWithName:@"CIMinimumComponent"];
        
        CIFilter *composite = [CIFilter filterWithName:@"CIMultiplyCompositing"];
        
        // #6
        if (sepiaFilter && randomFilter && whiteSpecks && darkScratches && minimumComponent && composite) {
            // #7
            CIImage *sepiaImage = sepiaFilter.outputImage;
            
            // #8
            CIImage *whiteSpecksImage = [whiteSpecks.outputImage imageByCroppingToRect:sourceCIImage.extent];
            
            // #9
            CIImage *sepiaPlusWhiteSpecksImage = [CIFilter filterWithName:@"CISourceOverCompositing"
                                                            keysAndValues:kCIInputImageKey,
                                                            whiteSpecksImage,
                                                            kCIInputBackgroundImageKey,
                                                            sepiaImage,
                                                  nil].outputImage;
            
            // #10
            CIImage *darkScratchesImage = [darkScratches.outputImage imageByCroppingToRect:sourceCIImage.extent];
            
            [minimumComponent setValue:darkScratchesImage forKey:kCIInputImageKey];
            darkScratchesImage = minimumComponent.outputImage;
            
            [composite setValue:sepiaPlusWhiteSpecksImage forKey:kCIInputImageKey];
            [composite setValue:darkScratches forKey:kCIInputImageKey];
            
            [self addCIImageToCollectionView:composite.outputImage withFilterTitle:NSLocalizedString(@"Film", @"Film Filter")];
        }
        
    
    }];
    
}

- (void)sendButtonPressed:(id)sender
{
    
    
    // On iOS apps can define their own URL schemes so other apps can open them
    // Instagram defines their own, so checking to see if the instagram:// URL scheme can be handled is a way to tell if app installed
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    
    UIAlertController *alertVC;
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        alertVC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Add a caption and send your image in the Instagram.", @"send image instructions") preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Caption", @"Caption");
        }];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"cancel button") style:UIAlertActionStyleCancel handler:nil]];
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send", @"Send button") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textField = alertVC.textFields[0];
            [self sendImageToInstagramWithCaption:textField.text];
        }]];
        
    } else {
        alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Instagram App", nil) message:NSLocalizedString(@"Add a caption and send your image in the Instagram app.", @"send image instructions") preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:nil]];
        
        
        
    }
         
         [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)sendImageToInstagramWithCaption:(NSString *)caption
{
    // convert the image to NSData
    NSData *imagedata = UIImageJPEGRepresentation(self.previewImageView.image, 0.9f);
    //
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    // create a fle in the temp directory with the igo extension
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"blocstagram"] URLByAppendingPathExtension:@"igo"];
    
    BOOL success = [imagedata writeToURL:fileURL atomically:YES];
    
    if (!success) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't save image", nil) message:NSLocalizedString(@"Your cropped and filtered photo couldn't be saved. Make sure you have enough disk space and try again.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentController.UTI = @"com.instagram.exclusivegram";
    self.documentController.delegate = self;
    
    if (caption.length > 0) {
        self.documentController.annotation = @{@"InstagramCaption": caption};
    }
    
    if (self.sendButton.superview) {
        [self.documentController presentOpenInMenuFromRect:self.sendButton.bounds inView:self.sendButton animated:YES];
    } else {
        [self.documentController presentOpenInMenuFromBarButtonItem:self.sendBarButton animated:YES];
    }
    
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end