//
//  ViewController.m
// ShareSong
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>
#import "SpotifySearch.h"
#import "AppleMusicSearch.h"
#import "SMKTransferingSong.h"
#import "SMKHistoryCollectionViewController.h"
#import "SMKHistoryData.h"

#import "SMKLoaderView.h"
#import "SMKSong.h"


@interface ViewController () <MPMediaPickerControllerDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextField *resultTextField;
@property (weak, nonatomic) IBOutlet UIView *backViewWithMask;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak,nonatomic) IBOutlet UIView *logoBackgroundView;
@property (nonatomic) UIAlertController *alertController;
@property (nonatomic) NSString *fronteStoreId;

@property (nonatomic) SMKTransferingSong *transferManager;

@end

@implementation ViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.transferManager = [[SMKTransferingSong alloc] init];
    [self prepareView];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setMaskToBackView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.searchTextField resignFirstResponder];
    [self.resultTextField resignFirstResponder];
    
}

#pragma mark - Actions
- (IBAction)presentHistoryVC:(id)sender {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    SMKHistoryCollectionViewController *vc = [[SMKHistoryCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)search{
    self.resultTextField.text = @"";
    NSString *url = [UIPasteboard generalPasteboard].string;
    
    self.searchTextField.text = url;
    if ([SMKTransferingSong isSuitableLink:url]) {
        [self.indicatorView startAnimating];
        // убрать испольщование self в блоках - завикифаить)
        [self.transferManager transferSongWithLink:[UIPasteboard generalPasteboard].string withSuccessBlock:^(NSDictionary *dict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self succesfullLink:dict sourceLink:url];
            });
        } withFailureBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self failureWithLink];
            });
        }];
    } else {
        [self failureWithLink];
        [self.indicatorView stopAnimating];
    }
}

#pragma mark - success/fail
- (void)succesfullLink:(NSDictionary *)dict sourceLink:(NSString *)link{
    self.resultTextField.text = [dict objectForKey:@"url"];
    [self.indicatorView stopAnimating];
    [self pasteToPasteboard:self.resultTextField.text];
    [self setMessageForSuccessAlert];
    if (![[SMKHistoryData sharedData] isMemberWithLink:link]) {
        [[SMKHistoryData sharedData] addSongWithDict:[self prepareDictWith:dict sourceLink:link]];
    }
    [self presentViewController:self.alertController animated:YES completion:nil];
}
- (void)failureWithLink {
    self.resultTextField.text = @"";
    [self.indicatorView stopAnimating];
    [self setMessageForWrongLink];
    [self presentViewController:self.alertController animated:YES completion:nil];
}

#pragma mark - Prerare dict for crearitn history 
- (NSDictionary *)prepareDictWith:(NSDictionary *)dict sourceLink:(NSString *)link {
    NSString *spotifyLink;
    NSString *appleMusicLink;
    if ([SMKTransferingSong isAppleMusicLink:link]) {
        appleMusicLink = link;
        spotifyLink = [dict objectForKey:@"url"];
    } else {
        spotifyLink = link;
        appleMusicLink = [dict objectForKey:@"url"];
    }
    NSString *title = [dict objectForKey:@"title"];
    NSString *artist = [dict objectForKey:@"artist"];
    NSString *imgLink = [dict objectForKey:@"imgLink"];
    
    NSDictionary *songData = [[NSDictionary alloc] initWithObjectsAndKeys:appleMusicLink,@"appleLink", spotifyLink, @"spotifyLink",title, @"title", artist, @"artist", imgLink, @"imgLink",nil];
    return songData;
}

#pragma mark - Prepare view
- (void)prepareView {
    [self configureLogo];
    [self configureTextFields];
    [self prepareIndicatorView];
    [self prepareAlertController];
}
- (void)configureLogo {
    self.logoBackgroundView.layer.cornerRadius = self.logoBackgroundView.frame.size.width/2.0;
}
- (void)configureTextFields {
    self.searchTextField.layer.cornerRadius = 5;
    self.resultTextField.layer.cornerRadius = 5;
}
- (void)prepareIndicatorView {
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.view.center;
    [self.view addSubview:self.indicatorView];
}
- (void)prepareAlertController {
    self.alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSuccess = [UIAlertAction actionWithTitle:@"Daaamn" style:UIAlertActionStyleCancel handler:nil];
    [self.alertController addAction:actionSuccess];
}
- (void)setMessageForWrongLink {
    NSString *title = [NSString stringWithFormat:@"Sorry, but your link is wrong. "];
    [self.alertController setTitle:title];
    [self.alertController setMessage:@"Maybe, it's not link from your subscription country. Try again with another lunk, and be careaful"];
}
- (void)setMessageForSuccessAlert {
    NSString *emoji = [self configuredEmoji:@"\xF0\x9F\x99\x8C"];
    NSString *title = [NSString stringWithFormat:@"%@ Success %@",emoji,emoji];
    [self.alertController setTitle:title];
    [self.alertController setMessage:@"You link to the song now in clipboard. Just send it"];
}

- (NSString *)configuredEmoji:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *datta = [valueUnicode dataUsingEncoding:NSUTF8StringEncoding];
    NSString *result = [[NSString alloc] initWithData:datta encoding:NSNonLossyASCIIStringEncoding];
    return result;
}
- (void)setMaskToBackView {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    CGRect maskRect = CGRectMake(0, 0, self.backViewWithMask.frame.size.width, self.backViewWithMask.frame.size.height);
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(maskRect.size.width, 0)];
    [path addLineToPoint:CGPointMake(maskRect.size.width, maskRect.size.height*0.737)];
    [path addLineToPoint:CGPointMake(0, maskRect.size.height)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path closePath];
    [maskLayer setBackgroundColor:[UIColor blackColor].CGColor];
    
    maskLayer.path = path.CGPath;
    self.backViewWithMask.layer.mask = maskLayer;
    
}

#pragma mark - UIPasteboard
- (void)pasteToPasteboard:(NSString *)url{
    [UIPasteboard generalPasteboard].string = url;
}
- (bool)checkIsLinkAlreadyInPasteboard {
    NSString *link = [UIPasteboard generalPasteboard].string;
    if ([AppleMusicSearch checkLinkWithString:link] || [SpotifySearch checkLinkWithString:link]) {
        return YES;
    }
    return NO;
}


@end
