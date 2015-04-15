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
    // An array must be accessible as an instance variable named _<key> or by a method named -<key>
    NSMutableArray *_mediaItems;

}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;

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
        [self populateDataWithParameters:nil];
        
    }];
}




#pragma mark - Key/Value Observing

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
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        // TODO: Add images
        
        
        // reset isRefreshing to NO since no longer in the process of refreshing
        self.isRefreshing = NO;
        
        // check if a completion handler was passed before calling it with nil
        // Do not provide an NSError because creating a fake, local piece of data like media
        // rarely results an error
        // NSError will be employed once we begin communicating with Instagram
        if (completionHandler) {
            completionHandler(nil);
        }
        
        
    }
}

-(void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.isLoadingOlderItems == NO) {
        self.isLoadingOlderItems = YES;
      
        //TODO: Add images
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void)populateDataWithParameters:(NSDictionary *)parameters
{
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // do the network request in the background, so the UI doesn't lockup
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                // for ex, if dictionary contains {count: 50}, append '&count=50' to the URL
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
                        });
                        
                    }
                    
                }
                
            }
            
        });
    }
}


- (void)parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSLog(@"%@", feedDictionary);
}




@end
