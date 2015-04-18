//
//  Media.m
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "Media.h"
#import "User.h"

@implementation Media

- (instancetype)initWithDictionary:(NSDictionary *)mediaDictionary
{
    
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL) {
            self.mediaURL = standardResolutionImageURL;
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // Caption might be null (if there's no caption)
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        // iterate through the comments array, pull out the dictionaries one at a time and
        // pass them to Comment for parsing
        // mediaDictionary[@"comments"][@"data"] is an array of Dictionaries
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
        }
        self.comments = commentsArray;
    }
    return self;
}

@end
