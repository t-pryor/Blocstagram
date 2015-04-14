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

// this property can only be modified by the DataSource instance
// Instnces of other classes can only read from it

@interface DataSource () {

    //@property (nonatomic, strong) NSArray *mediaItems;
    // An array must be accessible as an instance variable named _<key> or by a method named -<key>
    NSMutableArray *_mediaItems;

}

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;

@end



@implementation DataSource

+(instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype) init
{
    self = [super init];
    
    if (self) {
        [self addRandomData];
    }
    
    return self;
}

// load every placeholder image in our app
// creates a Media model for it
// attaches a randomly generated User to it
// adds a random caption
// attaches a randomly generated number of Comments to it
// puts each media item into the mediaItems aray
-(void) addRandomData
{
    NSMutableArray *randomMediaItems = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image) {
            Media *media = [[Media alloc] init];
            media.user = [self randomUser];
            media.image = image;
            media.caption = [self randomSentence];
            
            NSUInteger commentCount = arc4random_uniform(10);
            NSMutableArray *randomComments = [NSMutableArray array];
            
            for (int i = 0; i <= commentCount; i++) {
                Comment *randomComment = [self randomComment];
                [randomComments addObject:randomComment];
            }
        
            media.comments = randomComments;
        
            [randomMediaItems addObject:media];
    
        }
    }
    
    // Ask Steve
    //self.mediaItems = randomMediaItems;
    _mediaItems = randomMediaItems;
}

-(User *) randomUser
{
    User *user = [[User alloc] init];
    
    user.userName = [self randomStringOfLength:arc4random_uniform(10)];
    
    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7)];
    
    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12)];
    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    return user;
}

- (Comment *) randomComment {
    Comment *comment = [[Comment alloc] init];
    
    comment.from = [self randomUser];
    comment.text = [self randomSentence];
    
    return comment;
}

- (NSString *) randomSentence
{
    NSUInteger wordCount = arc4random_uniform(20);
    
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    
    for (int i = 0; i < wordCount; i++) {
        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
        [randomSentence appendFormat:@"%@ ", randomWord];
    }
    
    return randomSentence;
}

-(NSString *) randomStringOfLength:(NSUInteger) len {
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return [NSString stringWithString:s];
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
        
        // create new random media object and append it to the front of the KVC array
        // place at front of array
        Media *media = [[Media alloc] init];
        media.user = [self randomUser];
        media.image = [UIImage imageNamed:@"10.jpg"];
        media.caption = [self randomSentence];
        
        
        // this code will be changed to access Instagram API
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        [mutableArrayWithKVO insertObject:media atIndex:0];
        
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
        Media *media = [[Media alloc] init];
        media.user = [self randomUser];
        media.image = [UIImage imageNamed:@"3.jpg"];
        media.caption = [self randomSentence];
        
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        [mutableArrayWithKVO addObject:media];
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}



@end
