//
//  CommentTests.m
//  Blocstagram
//
//  Created by Tim on 2015-06-08.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Comment.h"

@interface CommentTests : XCTestCase

@end

@implementation CommentTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testThatCommentIntitializationWorks
{

    NSDictionary *sourceDictionary = @{@"id":@"13579",
                                       @"text":@"This is comment text for CommentTests.m",
                                       @"from":
                                                @{
                                                    @"full_name": @"TestFullName",
                                                    @"id": @"97531",
                                                    @"profile_picture": @"www.example.com/example.jpg",
                                                    @"username": @"TestUserName"
                                                }
                                        };
    
    Comment *testComment = [[Comment alloc]initWithDictionary:sourceDictionary];
    XCTAssertEqualObjects(testComment.idNumber, sourceDictionary[@"id"], @"The id numbers should be equal");
    XCTAssertEqualObjects(testComment.text, sourceDictionary[@"text"], @"The text contents should be equal");
    
}




@end
