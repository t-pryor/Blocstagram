//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Tim on 2015-04-07.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"

@interface MediaTableViewCell ()

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;


@end

// p.204-Programming in Objective-C
// static variable, local to this file (vs. global variable)
// because it's defines as a static variable in the implementation file, its scope is restricted to this file
// Users do not have direct access to it, and concept of data encapsulation is not violated
static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;


@implementation MediaTableViewCell
// Since the variables we've declared were all static and therefore belong to every instance
// we initialize them in load, which called once and only once per class

// Invoked whenever a class or category is added to the Objective-C runtime;
// implement this method to perform class-specific behavior upon loading.
+ (void)load
{
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*e5e5e5*/
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.424 alpha:1]; /*#58506d*/
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    // tailIndent specifies where the ends of the lines should stop, positive from right,
    // negative from left
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    paragraphStyle = mutableParagraphStyle;
}

+(CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc]
                                      initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"layoutCell"];
    
    // Set it to the given width and the maximum possible height
    layoutCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
    
    NSLog(@"1: %@", NSStringFromCGRect(layoutCell.frame));
    
    // Give it the media item
    layoutCell.mediaItem = mediaItem;
    
    
    // Make it adjust the image view and labels
    [layoutCell layoutSubviews];
    
    NSLog(@"2: %@", NSStringFromCGRect(layoutCell.frame));
    
    // The height will be wherever the bottom of the comments label is
    NSLog(@"ZZ %f", CGRectGetMaxY(layoutCell.commentLabel.frame));
    NSLog(@"3: %@", NSStringFromCGRect(layoutCell.commentLabel.frame));
    
    
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
    //return 500;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel]) {
            [self.contentView addSubview:view];
        }
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageHeight = self.mediaItem.image.size.height / self.mediaItem.image.size.width *
                                CGRectGetWidth(self.contentView.bounds);
    self.mediaImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight);
    
    NSLog(@"SELF.MEDIAIMAGEVIEW.FRAME: %@", NSStringFromCGRect(self.mediaImageView.frame));
    
    CGSize sizeOfUsernameAndCaptionLabel = [self sizeOfString:self.usernameAndCaptionLabel.attributedText];
    self.usernameAndCaptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.mediaImageView.frame), CGRectGetWidth(self.contentView.bounds), sizeOfUsernameAndCaptionLabel.height);
    
    NSLog(@"SELF.USERNAMEANDCAPTIONLABEL.FRAME: %@", NSStringFromCGRect(self.usernameAndCaptionLabel.frame));
    
    
    CGSize sizeOfCommentLabel = [self sizeOfString:self.commentLabel.attributedText];
    self.commentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.usernameAndCaptionLabel.frame), CGRectGetWidth(self.bounds), sizeOfCommentLabel.height);
    
    NSLog(@"COMMENTLABEL.FRAME: %@", NSStringFromCGRect(self.commentLabel.frame));
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
    
}

// When overriding a setter or getter method for a property you must refer to the implicitly generated IVAR
// (instance variable) rather than the property itelf
-(void) setMediaItem:(Media *)mediaItem
{
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSAttributedString *) usernameAndCaptionString {
    CGFloat usernameFontSize = 15;
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName,
                            self.mediaItem.caption];
    // Make an attributed string, with the "username" bold
    NSMutableAttributedString *mutableUsernameAndCaptionString =
    [[NSMutableAttributedString alloc] initWithString:baseString
                                           attributes: @{NSFontAttributeName :
                                                      [lightFont fontWithSize:usernameFontSize],
                                               NSParagraphStyleAttributeName :paragraphStyle}
     ];
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName
                                            value:[boldFont fontWithSize:usernameFontSize]
                                            range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName
                                            value:linkColor
                                            range:usernameRange];
    return mutableUsernameAndCaptionString;
}

-(NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    // commentString is a concatenation of every comment found for that particular media item
    //
    for (Comment *comment in self.mediaItem.comments) {
        // Make a string that says "username comment" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n",
                                comment.from.userName, comment.text];
        // Make an attributed string, with the "username" bold
        
        NSMutableAttributedString *oneCommentString =
            [[NSMutableAttributedString alloc] initWithString:baseString
                                                   attributes:
                                                   @{NSFontAttributeName: lightFont,
                                                     NSParagraphStyleAttributeName:paragraphStyle}];
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName
                                 value:linkColor
                                 range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
        
    }
    return commentString;
}

// calculates how tall'usernameAndCaptionLabel' and 'commentLabel' need to be
// CGSize maxSize
-(CGSize) sizeOfString:(NSAttributedString *) string
{
    
    //
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 0.0);
    // this function uses text, attributes and max width to determine how much space our string requires
    CGRect sizeRect = [string boundingRectWithSize:maxSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           context:nil];
    // add height of 20 to pad out the top and bottom
    sizeRect.size.height += 20;
    sizeRect = CGRectIntegral(sizeRect);
    return sizeRect.size;
}





@end
