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

@end

@implementation DataSource

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
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
        [self registerForAccessTokenNotification];
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
        
        //this is all done in the background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // do the network request in the background, so the UI doesn't lockup
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                
                //append min_id=   or max_id= per Instagram API
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                NSURLResponse *response;
                NSError *webError;
                
                //NSURLConnection returns an NSData object
                ///but it also wants to communicate other information about the response (NSURLResponse)
                // and possibly an error, if something went wrong (NSError)
                // Since ObjC can only return one method, we pass in addresses of other vars as args
                // and the method sets them. AKA "vending"
                // this method returns an NSData and vends an NSURLRequest and an NSError
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                             returningResponse:&response
                                                                         error:&webError];
                 // NSURLConnection returned valid response
                if (responseData) {
                    NSError *jsonError;
                    NSDictionary *feedDictionary = [NSJSONSerialization
                                                    JSONObjectWithData:responseData
                                                    options:0
                                                    error:&jsonError];
                    if (feedDictionary) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //done networking, go back to main thread
                            [self parseDataFromFeedDictionary:feedDictionary
                                    fromRequestWithParameters:parameters];
                            if (completionHandler) {
                                completionHandler(nil);
                            }
                        });
                    } else if (completionHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(jsonError);
                        });
                    }
                    
                }
                // responseData is nil
                else if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(webError);
                    });
                }
            }
            
        }); // end dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    }
}


- (void)parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    // feedDictionary contains three keys: @"data", @"meta", @"pagination"
    // feedDictionary[@"data"] is an array containing data about an individual picture
    // each element in the mediaArray is a Dictionary
    NSArray *mediaArray = feedDictionary[@"data"];
   
    
  for (int i = 0; i < mediaArray.count; i++) {
        NSLog(@"****************************");
        NSLog(@" MEDIA ARRAY index %d: %@", i, [mediaArray objectAtIndex:i]);
      
  }
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem]; // inefficient, downloads images simultaneously, will replace
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
    
}

- (void)downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        //dispatch_asynch to a background queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           //Make an NSURLRequest
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            NSURLResponse *response;
            NSError *error;
            // Use NSURLConnection to connect and get the NSData
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request
                                 returningResponse:&response
                                             error:&error];
            // Attempt to convert the NSData into the expected object type
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                // if it works, dispatch_async back to the main queue and update the data model with the results
                if (image) {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                        
                    });
                }
            }
        });
    }
}


@end
