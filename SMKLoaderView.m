//
//  SMKLoaderView.m
//  ShareSong
//
//  Created by Vo1 on 14/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SMKLoaderView.h"

@implementation SMKLoaderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGFloat x = self.center.x-50;
    CGFloat y = self.center.y-50;
    //sorry god for magic numbers
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x+43.59, y+46)];
    [path addLineToPoint:CGPointMake(x+43.59, y+41)];
    [path addCurveToPoint:CGPointMake(x+58.78, y+41) controlPoint1:CGPointMake(x+43.59, y+30) controlPoint2:CGPointMake(x+58.78, y+31)];
    [path addLineToPoint:CGPointMake(x+58.78, y+51)];
    [path addCurveToPoint:CGPointMake(x+43.59, y+51) controlPoint1:CGPointMake(x+58.78, y+62) controlPoint2:CGPointMake(x+43.59, y+62)];
    [path addLineToPoint:CGPointMake(x+43.59, y+11)];
    [path addCurveToPoint:CGPointMake(x+29, y+11) controlPoint1:CGPointMake(x+43.49, y+2) controlPoint2:CGPointMake(x+29, y+2)];
    [path addLineToPoint:CGPointMake(x+29, y+69)];
    [path addCurveToPoint:CGPointMake(x+18, y+58) controlPoint1:CGPointMake(x+29, y+69) controlPoint2:CGPointMake(x+20, y+59)];
    [path addCurveToPoint:CGPointMake(x+9, y+59) controlPoint1:CGPointMake(x+15, y+57) controlPoint2:CGPointMake(x+11, y+57)];
    [path addCurveToPoint:CGPointMake(x+6.5, y+70.8) controlPoint1:CGPointMake(x+7.2, y+60.5) controlPoint2:CGPointMake(x+4, y+66.5)];
    [path addCurveToPoint:CGPointMake(x+42, y+96) controlPoint1:CGPointMake(x+8.2, y+73.9) controlPoint2:CGPointMake(x+21.7, y+94.6)];
    [path addCurveToPoint:CGPointMake(x+57.34, y+96.6) controlPoint1:CGPointMake(x+47.5, y+96.5) controlPoint2:CGPointMake(x+50, y+96.4)];
    [path addCurveToPoint:CGPointMake(x+71.3, y+96.18) controlPoint1:CGPointMake(x+64.6, y+96.5) controlPoint2:CGPointMake(x+65.6, y+97)];
    [path addCurveToPoint:CGPointMake(x+84, y+89.5) controlPoint1:CGPointMake(x+77.5, y+95.2) controlPoint2:CGPointMake(x+82.1, y+91.9)];
    [path addCurveToPoint:CGPointMake(x+89.5, y+76.3) controlPoint1:CGPointMake(x+86.1, y+87.1) controlPoint2:CGPointMake(x+89.3, y+84)];
    [path addLineToPoint:CGPointMake(x+89.5, y+18)];
    [path addCurveToPoint:CGPointMake(x+74, y+18) controlPoint1:CGPointMake(x+89.5, y+9) controlPoint2:CGPointMake(x+74, y+9)];
    [path addLineToPoint:CGPointMake(x+74, y+51)];
    [path addCurveToPoint:CGPointMake(x+59, y+51) controlPoint1:CGPointMake(x+74, y+62) controlPoint2:CGPointMake(x+59, y+62)];
    [path addLineToPoint:CGPointMake(x+59, y+41)];
    [path addCurveToPoint:CGPointMake(x+74, y+42) controlPoint1:CGPointMake(x+59, y+30) controlPoint2:CGPointMake(x+74, y+30)];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = 2.0;
    layer.path = path.CGPath;
    [layer setFillColor:[UIColor clearColor].CGColor];
    
    [self.layer addSublayer:layer];
    
    layer.strokeStart = 0.0;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    anim.duration = 2.0;
    anim.fromValue = @(0.0);
    anim.toValue = @(1.0);
        anim.repeatCount = HUGE_VAL;
    [layer addAnimation:anim forKey:@"anim"];
}


@end
