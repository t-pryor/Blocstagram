//
//  DataSource.h
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Media;

// using typedef to define a block which we can reuse as a parameter in multiple methods

typedef void (^NewItemCompletionBlock)(NSError *error);
//typedef return_type (^blockName)(var_type);

@interface DataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong, readonly) NSString *accessToken;


+ (NSString *) instagramClientID;
- (void)deleteMediaItem:(Media *)item;
- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void)downloadImageForMediaItem:(Media *)mediaItem;

@end
