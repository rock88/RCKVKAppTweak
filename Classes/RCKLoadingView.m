// RCKLoadingView.m
//
// RCKVKAppTweak
//
// Copyright (c) 2014 rock88
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "RCKLoadingView.h"
#import <objc/runtime.h>

@interface RCKLoadingView ()

@property (nonatomic) CAShapeLayer* shapeLayer;

@end

@implementation RCKLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        UIBezierPath* bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:(center.x - 2.0f) startAngle:M_PI + M_PI_2 endAngle:M_PI + M_PI_2 - 0.0001f clockwise:YES];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.path = bezierPath.CGPath;
        self.shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        self.shapeLayer.strokeColor = [UIColor greenColor].CGColor;
        self.shapeLayer.lineWidth = 2.0f;
        self.shapeLayer.shadowOffset = CGSizeZero;
        self.shapeLayer.shadowColor = [UIColor blackColor].CGColor;
        self.shapeLayer.shadowRadius = 2.0f;
        self.shapeLayer.shadowOpacity = 1.0f;
        self.shapeLayer.strokeEnd = 0.0f;
        [self.layer addSublayer:self.shapeLayer];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    self.shapeLayer.strokeEnd = progress;
}

- (void)startLoading
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.shapeLayer.strokeEnd = 0.0f;
    self.shapeLayer.strokeColor = [UIColor yellowColor].CGColor;
    
    [CATransaction commit];
}

- (void)doneLoading
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.shapeLayer.strokeEnd = 1.0f;
    self.shapeLayer.strokeColor = [UIColor greenColor].CGColor;
    
    [CATransaction commit];
}

- (void)errorLoading
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    self.shapeLayer.strokeEnd = 1.0f;
    self.shapeLayer.strokeColor = [UIColor redColor].CGColor;
    
    [CATransaction commit];
}

@end

@implementation UIViewController (RCKLoadingView)

- (void)setRCKLoadingView:(RCKLoadingView *)RCKLoadingView
{
    objc_setAssociatedObject(self, @selector(RCKLoadingView), RCKLoadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RCKLoadingView *)RCKLoadingView
{
    return objc_getAssociatedObject(self, @selector(RCKLoadingView));
}

@end
