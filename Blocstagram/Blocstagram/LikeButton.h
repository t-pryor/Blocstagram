//
//  LikeButton.h
//  Blocstagram
//
//  Created by Tim on 2015-04-28.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LikeState) {
    LikeStateNotLiked           = 0,
    LikeStateLiking             = 1,
    LikeStateLiked              = 2,
    LikeStateUnliking           = 3,
};

@interface LikeButton : UIButton

/**
 The current state of the like button. Setting to LikeButtonNotLiked or LikeButtonLiked will 
 display an embpty heart or a heart, respectively. Setting to LikeButtonLiking or LikeButtonUnliking
 will display an activity indicator and disable button taps until the button is set to 
 LikeButtonNotLiked or LikeButtonLiked
 */

@property (nonatomic, assign) LikeState likeButtonState;

@end
