//
//  SMKHistoryCollectionViewController.m
//  ShareSong
//
//  Created by Vo1 on 13/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SMKHistoryCollectionViewController.h"
#import "SMKHistoryCollectionViewCell.h"
#import "SMKSong.h"


@interface SMKHistoryCollectionViewController ()
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIVisualEffectView *blurView;

@property (nonatomic) UIImageView *coverAlbumView;
@property (nonatomic,copy) NSString *songTitle;
@property (nonatomic,copy) NSString *songArtist;

@property (nonatomic) UIButton *spotifyLinkToCLipboardButton;
@property (nonatomic) UIButton *appleMusicLinkToCLipboardButton;


@end

@implementation SMKHistoryCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self prepareView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SMKHistoryCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([SMKHistoryCollectionViewCell class])];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[SMKHistoryData sharedData] countOfSongs];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SMKHistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SMKHistoryCollectionViewCell class]) forIndexPath:indexPath];
    
    NSInteger index = indexPath.item;
    SMKSong *song = [[SMKHistoryData sharedData] songAtIndex:index];
    cell.img.image = [song albumCover];
    cell.titleLabel.text = [song title];
    cell.artistLabel.text = [song artist];
    return cell;
}

#pragma mark - actions
- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self addBlurToForeground];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch view] == self.blurView) {
        [self hideBlurForeground];
    }
}

#pragma mark - settings for cells/collectionView/view
- (void)prepareView {
    [self setBackgroundColor];
    [self preparePaggingFromTop];
    [self prepareCollectionViewFlowLayout];
    [self prepareBackButton];
    [self prepareBlurVisualEffectView];
}
- (void)setBackgroundColor {
    self.collectionView.backgroundColor = [UIColor colorWithRed:235/255.0 green:239/255.0 blue:242/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:239/255.0 blue:242/255.0 alpha:1.0];
}
- (void)preparePaggingFromTop {
    CGRect rect = self.collectionView.frame;
    [self.collectionView setFrame:CGRectMake(0, 50, rect.size.width, rect.size.height)];
}
- (void)prepareCollectionViewFlowLayout {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    float size = self.view.frame.size.width / 3.0;
    flowLayout.itemSize = CGSizeMake(size, size);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
}
- (void)prepareBackButton {
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-18, 25.5, 36, 19.5)];
    [self.backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [self.view addSubview:self.backButton];
}
- (void)prepareBlurVisualEffectView {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurView.frame = self.view.bounds;
        self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else {
        @throw [NSException exceptionWithName:@"UIAccessibilityIsReduceTransparencyEnabled()" reason:nil userInfo:nil];
    }
}

#pragma makr - add/hide Blur to foreground

- (void)addBlurToForeground {
    self.blurView.layer.opacity = 0.0;
    [self.view addSubview:self.blurView];
    [UIView animateWithDuration:0.3 animations:^{
        self.blurView.layer.opacity = 1.0;
    }];
}
- (void)hideBlurForeground {
    [UIView animateWithDuration:0.3 animations:^{
        self.blurView.layer.opacity = 0.0;
    } completion:^(BOOL finished) {
        [self.blurView removeFromSuperview];
    }];
}

@end
