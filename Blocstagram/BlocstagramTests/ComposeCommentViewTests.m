//
//  ComposeCommentViewTests.m
//  Blocstagram
//
//  Created by Tim on 2015-06-08.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ComposeCommentView.h"


@interface ComposeCommentViewTests : XCTestCase

@end

@implementation ComposeCommentViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testIsWritingCommentForNonEmptyString
{
    ComposeCommentView *ccv = [[ComposeCommentView alloc]initWithFrame:CGRectMake(1, 1, 1, 1)];
    NSString *emptyText = @"";
    ccv.text = emptyText;
    XCTAssertEqual(ccv.isWritingComment, NO, @"isWritingComment should be set to NO");
}


- (void)testIsWritingCommentorEmptyString
{
    ComposeCommentView *ccv = [[ComposeCommentView alloc]initWithFrame:CGRectMake(1, 1, 1, 1)];
    NSString *nonEmptyText = @"foo bar baz qux";
    ccv.text = nonEmptyText;
    XCTAssertEqual(ccv.isWritingComment, YES, @"isWritingComment should be set to YES");
}





@end
