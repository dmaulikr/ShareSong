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
    [self.logo setFrame:CGRectMake(133, 254, 54, 60)];
    self.logo.center = self.view.center;
    [self.view addSubview:self.logo];
}

- (void)viewDidAppear:(BOOL)animated {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *vc = [story instantiateViewControllerWithIdentifier:NSStringFromClass([ViewController class])];
    [vc setTransitioningDelegate:self];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}



- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[SMKLoadAnimator alloc] init];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
