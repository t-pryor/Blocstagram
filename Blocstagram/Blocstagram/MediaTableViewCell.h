//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaTableViewCell;

@protocol MediaTableViewCellDelegate <NSObject>

- (void)cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void)cell:(MediaTableViewCell *)cell didTwoFingerTouchImageView:(UIImageView *)imageView;
- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;

@end


@interface MediaTableViewCell : UITableViewCell

// each cell associated with a single mediaItem
@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;

+(CGFloat) heightForMediaItem:(Media *) mediaItem width:(CGFloat)width;

@end
