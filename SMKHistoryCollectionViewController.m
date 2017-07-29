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
@property (nonatomic,copy) NSString *spotifyLink;
@property (nonatomic,copy) NSString *appleMusicLink;

@property (nonatomic) UIButton *spotifyLinkToPasteboardButton;
@property (nonatomic) UIButton *appleMusicLinkToPasteboardButton;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *artistLabel;

@end

@implementation SMKHistoryCollectionViewController

#pragma mark - View life cycle
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
    [self setSongInformationWithIndex:indexPath.item];
    [self addForeground];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch view] == self.blurView) {
        [self hideBlurForeground];
        [self clearSongInformation];
    }
}

#pragma mark - settings for cells/collectionView/view
- (void)prepareView {
    [self setBackgroundColor];
    [self prepareCollectionViewFlowLayout];
    [self prepareBackButton];
    [self prepareBlurVisualEffectView];
    [self prepareForegroundAfterDidSelectItem];
}
- (void)setBackgroundColor {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)prepareCollectionViewFlowLayout {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    float size = self.view.frame.size.width / 3.0;
    
    flowLayout.itemSize = CGSizeMake(size, size);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    [flowLayout setSectionInset:UIEdgeInsetsMake(50, 0, 0, 0)];
}
- (void)prepareBackButton {
    self.backButton = [[UIButton alloc] init];
    [self.backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [self.view addSubview:self.backButton];
    
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:1].active = YES;
    [self.backButton.bottomAnchor constraintEqualToAnchor:self.collectionView.topAnchor constant:60].active = YES;
    [self.backButton.widthAnchor constraintEqualToConstant:44].active = YES;
    
    self.backButton.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton.imageView.bottomAnchor constraintEqualToAnchor:self.backButton.bottomAnchor constant:-15].active = YES;
    [self.backButton.imageView.heightAnchor constraintEqualToConstant:22].active = YES;
    [self.backButton.imageView.widthAnchor constraintEqualToConstant:36].active = YES;
}

#pragma  mark - after selecting item
- (void)prepareBlurVisualEffectView {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurView.frame = self.view.bounds;
        self.blurView.hidden = YES;
        self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else {
        @throw [NSException exceptionWithName:@"UIAccessibilityIsReduceTransparencyEnabled()" reason:nil userInfo:nil];
    }
}
- (void)prepareForegroundAfterDidSelectItem {
    CGFloat titleY = (self.appleMusicLinkToPasteboardButton.frame.origin.y-self.coverAlbumView.frame.origin.y+100)/1.4;
    CGFloat artistY = titleY + 30;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleY, self.view.frame.size.width, 25)];
    self.titleLabel.hidden = YES;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    
    self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, artistY, self.view.frame.size.width, 20)];
    self.artistLabel.hidden = YES;
    self.artistLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.artistLabel.numberOfLines = 0;
    self.artistLabel.textColor = [UIColor whiteColor];
    self.artistLabel.textAlignment = NSTextAlignmentCenter;
    
    self.spotifyLinkToPasteboardButton = [[UIButton alloc] init];
    self.spotifyLinkToPasteboardButton.hidden = YES;
    self.spotifyLinkToPasteboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.spotifyLinkToPasteboardButton.backgroundColor = [UIColor clearColor];
    [self.spotifyLinkToPasteboardButton setImage:[UIImage imageNamed:@"spotifyButton"] forState:UIControlStateNormal];
    
    self.appleMusicLinkToPasteboardButton = [[UIButton alloc] init];
    self.appleMusicLinkToPasteboardButton.hidden = YES;
    self.appleMusicLinkToPasteboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.appleMusicLinkToPasteboardButton.backgroundColor = [UIColor clearColor];
    [self.appleMusicLinkToPasteboardButton setImage:[UIImage imageNamed:@"appleButton"] forState:UIControlStateNormal];
    
    [self.appleMusicLinkToPasteboardButton addTarget:self action:@selector(pasteLinkToPasteboard:) forControlEvents:UIControlEventTouchUpInside];
    [self.spotifyLinkToPasteboardButton addTarget:self action:@selector(pasteLinkToPasteboard:) forControlEvents:UIControlEventTouchUpInside];
    
    self.coverAlbumView = [[UIImageView alloc] init];
    self.coverAlbumView.hidden = YES;
    self.coverAlbumView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.blurView];
    [self.view addSubview:self.coverAlbumView];
    [self.view addSubview:self.spotifyLinkToPasteboardButton];
    [self.view addSubview:self.appleMusicLinkToPasteboardButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.artistLabel];
    
    [self addConstraintsToForeground];
}

#pragma mark - copy link actions
- (void)pasteLinkToPasteboard:(id)sender {
    if (sender == self.appleMusicLinkToPasteboardButton) {
        [UIPasteboard generalPasteboard].string = self.appleMusicLink;
    } else if (sender == self.spotifyLinkToPasteboardButton) {
        [UIPasteboard generalPasteboard].string = self.spotifyLink;
    }
    
    [self dismissVC];
}

#pragma mark - add/hide Blur to foreground
- (void)addForeground {
    self.blurView.layer.opacity = 0.0;
    self.blurView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.blurView.layer.opacity = 1.0    ;
    } completion:^(BOOL finished) {
        [self presentImageViewButtonsLabels];
    }];
}
- (void)hideBlurForeground {
    [self hideImageViewAndButtons];
    [UIView animateWithDuration:0.3 animations:^{
        self.blurView.layer.opacity = 0.0;
    } completion:^(BOOL finished) {
        self.blurView.hidden = YES;
        
    }];
}
- (void)addConstraintsToForeground {
    
    UILayoutGuide* margin = self.view.layoutMarginsGuide;
    
    [self.coverAlbumView.topAnchor constraintEqualToAnchor:margin.topAnchor constant:80].active = YES;
    [self.coverAlbumView.leftAnchor constraintGreaterThanOrEqualToAnchor:margin.leftAnchor constant:50].active = YES;
    [self.coverAlbumView.centerXAnchor constraintEqualToAnchor:margin.centerXAnchor].active = YES;
    [self.coverAlbumView.heightAnchor constraintEqualToAnchor:self.coverAlbumView.widthAnchor multiplier:1.0].active = YES;
    
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.coverAlbumView.bottomAnchor constant:60].active = YES;
    [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.coverAlbumView.centerXAnchor].active = YES;
    [self.titleLabel.leftAnchor constraintGreaterThanOrEqualToAnchor:margin.leftAnchor].active = YES;
    [self.titleLabel.rightAnchor constraintLessThanOrEqualToAnchor:margin.rightAnchor].active = YES;
    
    [self.artistLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:20].active = YES;
    [self.artistLabel.centerXAnchor constraintEqualToAnchor:self.titleLabel.centerXAnchor].active = YES;

    [self.appleMusicLinkToPasteboardButton.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.appleMusicLinkToPasteboardButton.widthAnchor constraintEqualToConstant:50].active = YES;
    [self.appleMusicLinkToPasteboardButton.bottomAnchor constraintEqualToAnchor:margin.bottomAnchor constant:-100].active = YES;
    [self.appleMusicLinkToPasteboardButton.rightAnchor constraintGreaterThanOrEqualToAnchor:self.coverAlbumView.centerXAnchor constant:-25].active = YES;
    
    [self.spotifyLinkToPasteboardButton.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.spotifyLinkToPasteboardButton.widthAnchor constraintEqualToConstant:50].active = YES;
    [self.spotifyLinkToPasteboardButton.bottomAnchor constraintEqualToAnchor:margin.bottomAnchor constant:-100].active = YES;
    [self.spotifyLinkToPasteboardButton.leftAnchor constraintLessThanOrEqualToAnchor:self.coverAlbumView.centerXAnchor constant:+25].active = YES;
}

#pragma mark - add/hide Buttons and Img to foreground
- (void)presentImageViewButtonsLabels {
    self.coverAlbumView.hidden = NO;
    self.titleLabel.hidden = NO;
    self.artistLabel.hidden = NO;
    self.appleMusicLinkToPasteboardButton.hidden = NO;
    self.spotifyLinkToPasteboardButton.hidden = NO;
   }
- (void)hideImageViewAndButtons {
    self.coverAlbumView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.artistLabel.hidden = YES;
    self.appleMusicLinkToPasteboardButton.hidden = YES;
    self.spotifyLinkToPasteboardButton.hidden = YES;
}

#pragma mark - set/hide song information
- (void)setSongInformationWithIndex:(NSUInteger)index {
    self.appleMusicLink = [[[SMKHistoryData sharedData] songAtIndex:index] appleMusicLink];
    self.spotifyLink = [[[SMKHistoryData sharedData] songAtIndex:index] spotifyLink];
    self.titleLabel.text = [[[SMKHistoryData sharedData] songAtIndex:index] title];
    self.artistLabel.text = [[[SMKHistoryData sharedData] songAtIndex:index] artist];
    self.coverAlbumView.image = [[[SMKHistoryData sharedData] songAtIndex:index] albumCover];
}
- (void)clearSongInformation {
    self.appleMusicLink = @"";
    self.spotifyLink = @"";
    self.titleLabel.text = @"";
    self.artistLabel.text = @"";
    self.coverAlbumView.image = nil;
}

@end
