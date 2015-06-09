//
//  MediaTableViewCellTests.m
//  Blocstagram
//
//  Created by Tim on 2015-06-08.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Media.h"
#import "MediaTableViewCell.h"

@interface MediaTableViewCellTests : XCTestCase

@end

@implementation MediaTableViewCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatHeightForMediaItemWidthReturnsAccurateHeight
{
   
  
    // Data needed for Media object initialization, but has no bearing on height
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
    
    
    // The other elements of the media cell add 242 points to the height of a media item
    int nonImageHeightFactor = 242;

    // width and traitCollection arguments are needed for function, but they have no bearing on height
    CGFloat testWidth = 100.0;
    UITraitCollection *testTraitCollection = [[UITraitCollection alloc]init];
    
    
    Media *testMedia1 = [[Media alloc]initWithDictionary:sourceDictionary];
    testMedia1.image = [UIImage imageNamed:@"sample image-balloons"];
    CGSize image1Size = testMedia1.image.size;
    int image1Height = image1Size.height;
    
    Media *testMedia2 = [[Media alloc]initWithDictionary:sourceDictionary];
    testMedia2.image = [UIImage imageNamed:@"sample image-bird1"];
    CGSize image2Size = testMedia2.image.size;
    int image2Height = image2Size.height;
    
    Media *testMedia3 = [[Media alloc]initWithDictionary:sourceDictionary];
    testMedia3.image = [UIImage imageNamed:@"sample image-flowers"];
    CGSize image3Size = testMedia3.image.size;
    int image3Height = image3Size.height;
    
    
    XCTAssertEqual(image1Height + nonImageHeightFactor, [MediaTableViewCell heightForMediaItem:testMedia1 width:testWidth traitCollection:testTraitCollection]);
    XCTAssertEqual(image2Height + nonImageHeightFactor, [MediaTableViewCell heightForMediaItem:testMedia2 width:testWidth traitCollection:testTraitCollection]);
    XCTAssertEqual(image3Height + nonImageHeightFactor, [MediaTableViewCell heightForMediaItem:testMedia3 width:testWidth traitCollection:testTraitCollection]);
    
}




@end
