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
#import "LikeButton.h"
#import "ComposeCommentView.h"

@interface MediaTableViewCell () <UIGestureRecognizerDelegate, ComposeCommentViewDelegate>

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) LikeButton *likeButton;
@property (nonatomic, strong) ComposeCommentView *commentView;



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
    
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc]
                                      initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:@"layoutCell"];
    
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    layoutCell.mediaItem = mediaItem;
   // [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    
    return CGRectGetMaxY(layoutCell.commentView.frame);
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        self.mediaImageView.userInteractionEnabled = YES;

        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentView = [[ComposeCommentView alloc] init];
        self.commentView.delegate = self;
        
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.commentView]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            
        }
        
        // Each visual format string should begin with H: (horizontal) or V: (vertical)
        // | represents the superview and [someName] represents one view
       
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel,
                                                                      _commentLabel, _likeButton, _commentView);
        
        [self.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[_mediaImageView]|"
                                          options:kNilOptions
                                          metrics:nil
                                          views:viewDictionary]];
        
        // explicit width of 38
        [self.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likeButton(==38)]|"
                                          options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                          metrics:nil
                                          views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"H:|[_commentLabel]|"
                                          options:kNilOptions
                                          metrics:nil
                                          views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[_commentView]|"
                                          options:kNilOptions
                                          metrics:nil
                                          views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]"
                                          options:kNilOptions
                                          metrics:nil
                                          views:viewDictionary]];
        
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        self.imageHeightConstraint.identifier = @"Image height constraint";
        
        
        self.usernameAndCaptionLabelHeightConstraint =
            [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:100];
        
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Username and caption label height constraint";
        
        
        self.commentLabelHeightConstraint =
        [NSLayoutConstraint constraintWithItem:_commentLabel
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                      constant:100];
        self.commentLabelHeightConstraint.identifier = @"Comment label height constraint";
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
        
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    // Before layout, calculate the intrinsic size of the labels (they size they "want" to be)
    // and add 20 to the height for some vertical padding
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    self.usernameAndCaptionLabelHeightConstraint.constant =
        usernameLabelSize.height == 0 ? 0 : usernameLabelSize.height + 20;
    
    self.commentLabelHeightConstraint.constant =
        commentLabelSize.height == 0 ? 0 : commentLabelSize.height + 20;
    
    if (self.mediaItem.image.size.width > 0 && CGRectGetWidth(self.contentView.bounds) > 0) {
        self.imageHeightConstraint.constant = self.mediaItem.image.size.height /
        self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    } else {
        self.imageHeightConstraint.constant = 0;
    }
    
    
    
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
    self.likeButton.likeButtonState = mediaItem.likeState;
    self.commentView.text = mediaItem.temporaryComment;
}

- (void)setHighlighted:(BOOL)selected animated:(BOOL)animated
{
    [super setHighlighted:NO animated:animated];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];

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


#pragma mark - Liking

- (void)likePressed:(UIButton *)sender
{
    [self.delegate cellDidPressLikeButton:self];
}


#pragma mark - Image View
- (void)tapFired:(UITapGestureRecognizer *)sender
{
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

- (void)longPressFired:(UILongPressGestureRecognizer *)sender
{
    // could check for UIGestureRecognizerStateRecognized,
    // but then method wouldn't get called until user lifts their finger
    // if we don't check at all, the delegate method will get called twice,
    // once when it begins, once when user lifts finger
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}


#pragma mark - UIGestureRecognizerDelegate
// If the user swipes the cell to show the delete button, and then taps on the cell
// expected behavior is to hide the delete button, not zoom in on the image
// Make sure gesture recognizer only fires while cell isn't in editing mode
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.isEditing == NO;
}

#pragma mark - ComposeCommentViewDelegate

- (void)commentViewDidPressCommentButton:(ComposeCommentView *)sender
{
    [self.delegate cell:self didComposeComment:self.mediaItem.temporaryComment];
}

- (void)commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text
{
    self.mediaItem.temporaryComment = text;
}

- (void)commentViewWillStartEditing:(ComposeCommentView *)sender
{
    [self.delegate cellWillStartComposingComment:self];
}

- (void)stopComposingComment
{
    [self.commentView stopComposingComment];
}







@end
