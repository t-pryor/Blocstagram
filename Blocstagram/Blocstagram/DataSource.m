//
//  DataSource.m
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"
#import <UICKeyChainStore.h>
#import <AFNetworking.h>

// this property can only be modified by the DataSource instance
// Instnces of other classes can only read from it

@interface DataSource () {

    //@property (nonatomic, strong) NSArray *mediaItems;
    //https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/Compliant.html#//apple_ref/doc/uid/20002172-BAJEAIEE
    //Must make mediaItems key-value compliant, or KVC
    //An array must be accessible as an instance variable named _<key> or by a method named -<key>
    NSMutableArray *_mediaItems;

}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager; //switch assign and strong


@end

@implementation DataSource

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init]; //calls init
    });
    return sharedInstance;
}

+ (NSString *)instagramClientID
{
    return @"078a06d137a144f3afd319678bea3e07";
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self createOperationManager];
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            [self populateDataWithParameters:nil completionHandler:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            ^{
                //find the file at the path and convert to an array
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                
                // creates and instance of NSKeyedUnarchiver and load the archive located at the path into that instance
                // We created this archive with a root object of type NSArray, so this is stored as this type
                // newly allocated NSArray then sent initWithCoder: and NSKeyedUnarchiver passed as the argument
                // The array then starts decoding its content from the NSKeyedUnarchiver and sends each of
                // these objects the message initWithCoder:, passing the same NSKeyedArchiver
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        _mediaItems = mutableMediaItems;   //*ASK STEVE
                        [self didChangeValueForKey:@"mediaItems"];
                        
//                        for (Media* mediaItem in self.mediaItems) {
//                            [self downloadImageForMediaItem:mediaItem];
//                        }
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                }); // dispatch_get_main
            }); //DISPATCH_QUEUE
        }
    }
    
    return self;
}

- (void)registerForAccessTokenNotification
{
    // block will run after getting notification
    // object passed in the notification is an NSString containing the access token, store it in self.accessToken
    // when it arrives
    // Normally you would also unregister(removeObserver:..) for notifications in dealloc
    // Since DataSource is a singleton it will never get deallocated
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        // Got a token; populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
        
    }];
}




#pragma mark - Key/Value Observing
// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/Compliant.html#//apple_ref/doc/uid/20002172-BAJEAIEE

- (NSUInteger) countOfMediaItems{
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

-(void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

-(void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

// why not remove the item from our underlying data source without going through KVC methods?
// if not, no objects (including ImagesTableViewController) will receive a KVO notification
-(void) deleteMediaItem:(Media *) item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

-(void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    self.thereAreNoMoreOlderMessages = NO;
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        
        // minID is the number of the idNumber
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters;
        
        if (minID) {
            parameters = @{@"min_id": minID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

-(void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
      
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters;
        
        if (maxID) {
            parameters = @{@"max_id": maxID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}


// method
- (void)populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.accessToken) {
        // only try to get the data if there's an access token
        


        
        // create a parameters dictionary for the access token and
        // add in any other parameters that might be passed in (like min_id or max_id)
        // The request operation manager gets the resource and if it's successful
        // responseObject is passed to
        // parseDataFromFeedDictionary:fromRequestWithParameters: for parsing
        
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager
                    GET:@"users/self/feed"
             parameters:mutableParameters
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                    }
                    if (completionHandler) {
                        completionHandler(nil);
                    }
                                            
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (completionHandler) {
                        completionHandler(error);
                    }
                }
         ];
    
    }
}


- (void)parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters
{
    // feedDictionary contains three keys: @"data", @"meta", @"pagination"
    // feedDictionary[@"data"] is an array containing data about an individual picture
    // each element in the mediaArray is a Dictionary
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
  
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
           // [self downloadImageForMediaItem:mediaItem]; // inefficient, downloads images simultaneously, will replace
        }
    }
    
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
        
    } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        } else {
            [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        }
    
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        _mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    [self saveImages];
    
}

- (void)saveImages
{
    if (self.mediaItems.count > 0) {
        // Write the changes to disk
        // reading or writing to disk can be slow-dipatch to a background queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // make an NSArray containing the first 50 or fewer items (so we don't flood the user's harddrive)
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems
                                        subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            // Convert this array into an NSData and save it to disk
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath
                                                        options:NSDataWritingAtomic |
                                      NSDataWritingFileProtectionCompleteUnlessOpen
                                                          error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        
        });
    }
}

- (void)downloadImageForMediaItem:(Media *)mediaItem
{
    if (mediaItem.mediaURL && !mediaItem.image) {
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager
                    GET: mediaItem.mediaURL.absoluteString
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if ([responseObject isKindOfClass:[UIImage class]]) {
                        mediaItem.image = responseObject;
                        mediaItem.downloadState = MediaDownloadStateHasImage;
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                        [self saveImages];
                    } else {
                        mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                    }
                    
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error downloading image: %@", error);
                    mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                    
                    if ([error.domain isEqualToString:NSURLErrorDomain]) {
                        // A networking problem
                        if (error.code == NSURLErrorTimedOut ||
                            error.code == NSURLErrorCancelled ||
                            error.code == NSURLErrorCannotConnectToHost ||
                            error.code == NSURLErrorNetworkConnectionLost ||
                            error.code == NSURLErrorNotConnectedToInternet ||
                            error.code == kCFURLErrorInternationalRoamingOff ||
                            error.code == kCFURLErrorCallIsActive ||
                            error.code == kCFURLErrorDataNotAllowed ||
                            error.code == kCFURLErrorRequestBodyStreamExhausted) {
                            
                            mediaItem.downloadState = MediaDownloadStateNeedsImage;
                            
                        }
                    }
                }];
    }
}

// creates a string containing an absolute path to the user's Library/Caches directory
// this data can be very large and extend the time it takes to synchronize your device
// can be redownloaded


- (NSString *)pathForFilename:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

- (void)createOperationManager
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
    self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    imageSerializer.imageScale = 1.0;
    
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer
                                                compoundSerializerWithResponseSerializers:
                                                @[jsonSerializer, imageSerializer]];
    self.instagramOperationManager.responseSerializer = serializer;
                                            
}



@end
