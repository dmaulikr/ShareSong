//
//  SMKIntroViewController.m
//  ShareSong
//
//  Created by Vo1 on 01/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SMKIntroViewController.h"
#import "ViewController.h"
#import "SMKLoadAnimator.h"

@interface SMKIntroViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation SMKIntroViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.logo.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.view addSubview:self.logo];
    
    [self.logo.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.logo.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.logo.widthAnchor constraintEqualToConstant:54].active = YES;
    [self.logo.heightAnchor constraintEqualToConstant:60].active = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ViewController class])];
    [vc setTransitioningDelegate:self];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return [[SMKLoadAnimator alloc] init];
}

@end
