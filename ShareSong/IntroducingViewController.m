//
//  IntroducingViewController.m
//  ShareSong
//
//  Created by Vo1 on 06/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "IntroducingViewController.h"

@interface IntroducingViewController () <UIScrollViewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIImageView *imageView;

@end

@implementation IntroducingViewController

#pragma mark - VC LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareView];
}

#pragma mark - Action
- (void)dissmissVC:(UITapGestureRecognizer *)gesture {
    if (self.pageControl.currentPage == 4) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"wasOpenned"];
    }
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}

#pragma mark - Prepare UI
- (void)prepareView {
    [self prepareImageView];
    [self prepareScrollView];
    [self preparePageControl];
    [self prepareGestureRecogniser];
}
- (void)prepareImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*5, self.view.frame.size.height)];
    [self.imageView setImage:[UIImage imageNamed:@"introduce.png"]];
}
- (void)preparePageControl {
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 5;
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.pageControl];
    [self.pageControl.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.pageControl.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.pageControl.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
}
- (void)prepareScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor colorWithRed:198/255.0 green:235/255.0 blue:255/255.0 alpha:1.0];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.scrollView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.scrollView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.imageView.frame.size;
}
- (void)prepareGestureRecogniser {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissVC:)];
    tap.enabled = YES;
    tap.numberOfTapsRequired = 1;
    tap.cancelsTouchesInView = NO;
    
    [self.scrollView addGestureRecognizer:tap];
}


@end
