//
//  CircleSpinnerView.m
//  Blocstagram
//
//  Created by Tim on 2015-04-28.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "CircleSpinnerView.h"

@interface CircleSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end


@implementation CircleSpinnerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeThickness = 1;
        self.radius = 12;
        self.strokeColor = [UIColor purpleColor];
    }
    return self;
}


- (CAShapeLayer *)circleLayer
{
    // lazy instantiation-create the first time its called
    if (!_circleLayer) {
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius + self.strokeThickness/2+5);
        // arcCenter used to construct a CGRect-spinning circle will fit inside this rect
        CGRect rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
        
        // bezier path is a path which can have both straight and curved line segments
        // start and end angles in radians
        // smoothedPath represents a smooth circle
        UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        // create a CAShapeLayer, a core animation layer made from a bezier path
        _circleLayer = [CAShapeLayer layer];
        // contentsScale - 1.0 on regular screens, 2.0 on Retina
        _circleLayer.contentsScale = [[UIScreen mainScreen] scale];
        // frame set to rect
        _circleLayer.frame = rect;
        // want center of circle to be transparent (so we can see the heart)
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = self.strokeColor.CGColor;
        _circleLayer.lineWidth = self.strokeThickness;
        // specifies the shape of the ends of the line
        _circleLayer.lineCap = kCALineCapRound;
        _circleLayer.lineJoin = kCALineJoinBevel;
        // assign circular path to the layer
        _circleLayer.path = smoothedPath.CGPath;
        
        
        // make a mask layer and set its size to be the same
        // different parts of a layer can have different opacities
        CALayer *maskLayer = [CALayer layer];
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask"] CGImage];
        maskLayer.frame = _circleLayer.bounds;
        _circleLayer.mask = maskLayer;
        
        // animation duration in seconds
        CFTimeInterval animationDuration = 1;
        // linear animation-speed of the movement will stay the same throughout the entire animation
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction
                                              functionWithName:kCAMediaTimingFunctionLinear];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = @0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        // leave the layer on screen after the animation
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_circleLayer.mask addAnimation:animation forKey:@"rotate"];
        
        // animate the line that draws the circle iteself
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        // use two CABasicAnimations, one animates the start of the stroke, the other animates the end
        // Both are added to a CAAnimationGroup, which groups multiple animations and runs them concurrently
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        // both animations are added to a CAAnimationGroup, which groups multiple animations and runs them concurrently
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_circleLayer addAnimation:animationGroup forKey:@"progress"];
        
    }
    return _circleLayer;
}


- (void)layoutAnimatedLayer
{   // self.layer is the view's CoreAnimation layer used for rendering
    [self.layer addSublayer:self.circleLayer];
    
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}


// when we add a subview to another view using [UIView -addSubview:], the subview can react to this
// in [UIView -willMoveToSuperview:]
// willMoveToSuperview tells the superview that its view is about to change to the specified superview
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview != nil) {
        [self layoutAnimatedLayer];
    } else {
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
    }
}

// Update the position of the layer if the frame changes
//
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (self.superview != nil) {
        [self layoutAnimatedLayer];
    }
}

- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    
    [self layoutAnimatedLayer];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    _circleLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness
{
    _strokeThickness = strokeThickness;
    _circleLayer.lineWidth = _strokeThickness;
}

// Asks the view to calculate and return the size that best fits the specified size.
//The default implementation of this method returns the existing size of the view.
//Subclasses can override this method to return a custom value based on the desired layout of any subviews
- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}


@end
