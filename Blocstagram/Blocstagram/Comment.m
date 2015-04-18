//
//  Comment.m
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

- (instancetype)initWithDictionary:(NSDictionary *)commentDictionary
{
    self = [super init];
    
    if (self) {
        self.idNumber = commentDictionary[@"id"];
        self.text = commentDictionary[@"text"];
        self.from = [[User alloc] initWithDictionary:commentDictionary[@"from"]];
        
    }
    
    return self;
}

@end
