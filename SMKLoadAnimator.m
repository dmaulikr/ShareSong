//
//  SMKLoadAnimator.m
//  constrains
//
//  Created by Vo1 on 01/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SMKLoadAnimator.h"
#import "SMKIntroViewController.h"

@implementation SMKLoadAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    SMKIntroViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *inView = [transitionContext containerView];
    
    [inView addSubview:toVC.view];
    [toVC.view setAlpha:0.0];
    
    
    
    
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:0 animations:^{
        [UIView animateKeyframesWithDuration:0.6/1.0 delay:0 options:0 animations:^{
            fromVC.logo.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:.4/1.0 delay:.6/1.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                fromVC.logo.transform = CGAffineTransformMakeScale(50.0, 50.0);
                toVC.view.alpha = 1.0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }];
    } completion:nil];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.8;
}
@end
