//
//  User.m
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)userDictionary
{
    self = [super init];
    
    if (self) {
        self.idNumber = userDictionary[@"id"];
        self.userName = userDictionary[@"username"];
        self.fullName = userDictionary[@"full_name"];
        
        NSString *profileURLString = userDictionary[@"profile_picture"];
        NSURL *profileURL = [NSURL URLWithString:profileURLString];
        
        if (profileURL) {
            self.profilePictureURL = profileURL;
        }
    }
    return self;
}

#pragma mark - NSCoding

// the purpose of the key used when encoding is to retrieve the encoded value when this
// BNRItem is loaded from the filesystem later.
// Objects being loaded from an archive are sent the message initWithCoder:
// This method should grab all of the object that were encoded in encodeWithCoder:
// and assign them the appropriate instance variable

// NSCoder argument
// in initWithCoder:, the NSCoder is full of data to be consumed by the User object being initialized
// initWithCoder is not part of the initializer chain design pattern

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.userName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userName))];
        self.fullName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fullName))];
        self.profilePicture = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profilePictureURL))];
    }
    
    return self;
}

// By convention, the key is the name of the property being encoded

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.userName forKey:NSStringFromSelector(@selector(userName))];
    [aCoder encodeObject:self.fullName forKey:NSStringFromSelector(@selector(fullName))];
    [aCoder encodeObject:self.profilePicture forKey:NSStringFromSelector(@selector(profilePicture))];
    [aCoder encodeObject:self.profilePictureURL forKey:
                                            NSStringFromSelector(@selector(profilePictureURL))];
    
}



@end
