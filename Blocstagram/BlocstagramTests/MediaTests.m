//
//  MediaTests.m
//  Blocstagram
//
//  Created by Tim on 2015-06-04.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "User.h"
#import "Media.h"

@interface MediaTests : XCTestCase

@end

@implementation MediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testThatMediaInitializationWorks
{

    // ASSIGNMENT:
    // STEVE: I test equality for Foundation and primitive data types.
    // The Media initializer takes a User and a Comment object.
    // I test the initializers for these in their own test implementation files
    // I created CommentTests.m, with UserTests.m provided in the lesson
    
    NSURL *testURL = [[NSURL alloc] initWithString:@"www.test.com"];
    
    NSDictionary *sourceDictionary = @{@"id": @"123456789",
                                        @"user": @{@"id": @"8675309",
                                                   @"username": @"d'oh",
                                                   @"full_name": @"Homer Simpson",
                                                   @"profile_picture": @"http://www.example.com/example.jpg"},
                                        @"images": @{@"standard_resolution": @{@"url":@"www.test.com"}},
                                        @"caption": @{@"text": @"This is caption text"},
                                       @"comments": @{@"id":@"13579",
                                                      @"text":@"This is comment text for CommentTests.m",
                                                      @"from":
                                                          @{
                                                              @"full_name": @"TestFullName",
                                                              @"id": @"97531",
                                                              @"profile_picture": @"www.example.com/example.jpg",
                                                              @"username": @"TestUserName"
                                                              }
                                                      },
                                        @"user_has_liked": @1
                                       };
    
    
    Media *testMedia = [[Media alloc]initWithDictionary:sourceDictionary];
    
    // Simulate LikeState
    BOOL userHasLiked = [sourceDictionary[@"user_has_liked"] boolValue];
    LikeState likeStateTranslatedFromJSON = userHasLiked ? LikeStateLiked : LikeStateNotLiked;
    
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The ID numbers should be equal");
    XCTAssertEqualObjects(testMedia.mediaURL, testURL, @"The urls should be equal");
    XCTAssertEqualObjects(testMedia.caption, sourceDictionary[@"caption"][@"text"], @"The captions should be equal");
    XCTAssertEqual(testMedia.likeState, likeStateTranslatedFromJSON);
    
}




@end
