//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaTableViewCell, ComposeCommentView;

@protocol MediaTableViewCellDelegate <NSObject>

- (void)cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void)cellDidPressLikeButton:(MediaTableViewCell *)cell;
- (void)cellWillStartComposingComment:(MediaTableViewCell *)cell;
- (void)cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment;


@end


@interface MediaTableViewCell : UITableViewCell

// each cell associated with a single mediaItem
@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;
@property (nonatomic, strong, readonly) ComposeCommentView *commentView;
// two arrays of auto-layout constraints
@property (nonatomic, strong) NSArray *horizontallyRegularConstraints;
@property (nonatomic, strong) NSArray *horizontallyCompactConstraints;


+ (CGFloat)heightForMediaItem:(Media *)mediaItem width:(CGFloat)width traitCollection:(UITraitCollection *)traitCollection;

- (void)stopComposingComment;


@end
