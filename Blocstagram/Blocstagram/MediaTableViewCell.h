//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaTableViewCell : UITableViewCell

// each cell associated with a single mediaItem
@property (nonatomic, strong) Media *mediaItem;
+(CGFloat) heightForMediaItem:(Media *) mediaItem width:(CGFloat)width;

@end
