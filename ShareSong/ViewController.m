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
@property (weak, nonatomic) IBOutlet UITextField *resultTextField;
@property (weak, nonatomic) IBOutlet UIView *backViewWithMask;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIView *logoBackgroundView;
@property (nonatomic) UIAlertController *alertController;
@property (nonatomic) SMKLoaderView *animationView;
@property (nonatomic) SMKTransferingSong *transferManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIView *secondBottomLine;
@property (nonatomic) UIView *notificatationView;
@property (nonatomic) UILabel *errorLabel;

@end

@implementation ViewController


#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.transferManager = [SMKTransferingSong sharedTransfer];
    [self prepareView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFromNotification:)
                                                 name:@"search" object:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self search];
    });
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setMaskToBackView];
}

- (BOOL)updateTodayExtensionWithSong:(NSDictionary *)dict {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ShareSong.ShareSongToday"];
    [sharedDefaults setObject:[dict objectForKey:@"title"] forKey:@"title"];
    [sharedDefaults setObject:[dict objectForKey:@"artist"] forKey:@"artist"];
    [sharedDefaults synchronize];
    
    return YES;
}
#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)n {
    CGSize keyBoardSize = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    CGRect rect = self.resultTextField.frame;
    CGFloat move = keyBoardSize.height*.6;
    rect.origin.y -= move;
    [UIView animateWithDuration:0.08 animations:^{
        self.resultTextField.frame = rect;
    }];

    [self.view layoutIfNeeded];
}
- (void)keyboardWillHide:(NSNotification *)n {
    CGSize keyBoardSize = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    CGRect rect = self.resultTextField.frame;
    CGFloat move = keyBoardSize.height*.6;
    rect.origin.y += move;
    [UIView animateWithDuration:0.08 animations:^{
        self.resultTextField.frame = rect;
    }];
    
    [self.view layoutIfNeeded];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self search];
    return YES;
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.resultTextField resignFirstResponder];
    if ([self isNeedToHideWarning]) {[self hideWarningView];}
}

#pragma mark - Actions
- (IBAction)presentHistoryVC:(id)sender {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    SMKHistoryCollectionViewController *vc = [[SMKHistoryCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (void)save {
    BOOL success = [[SMKHistoryData sharedData] saveChanges];
    if (!success) {
        @throw [NSException exceptionWithName:@"Error while saving" reason:@"appDelegate" userInfo:nil];
    }
}
- (void)search{
    self.resultTextField.text = @"";
    NSString *url = [UIPasteboard generalPasteboard].string;
    [self.indicatorView startAnimating];
    __weak ViewController* weakViewController = self;
    if ([SMKTransferingSong isSuitableLink:url]) {
        [weakViewController.transferManager transferSongWithLink:[UIPasteboard generalPasteboard].string withSuccessBlock:^(NSDictionary *dict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakViewController succesfullLink:dict sourceLink:url];
                [self updateTodayExtensionWithSong:dict];
                [self save];
                [self.indicatorView stopAnimating];
            });
        } withFailureBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakViewController failureWithLink:@"Sorry, but this song is absent on wishes music service, please try again later"];
                [self.indicatorView stopAnimating];
                self.resultTextField.text = @"";
            });
        }];
    } else {
        [weakViewController failureWithLink:@"Wrong Link, try again with another link."];
        self.resultTextField.text = @"";
        [self.indicatorView stopAnimating];
    }
}
- (void)searchFromNotification:(NSNotification *)n {
    [self search];
}

#pragma mark - success/fail
- (void)succesfullLink:(NSDictionary *)dict sourceLink:(NSString *)link{
    self.resultTextField.text = [dict objectForKey:@"url"];
    [self pasteToPasteboard:self.resultTextField.text];
    [self setMessageForSuccessAlert];
    if (![[SMKHistoryData sharedData] isMemberWithLink:link]) {
        [[SMKHistoryData sharedData] addSongWithDict:[self prepareDictWith:dict sourceLink:link]];
    }
    [self presentViewController:self.alertController animated:YES completion:nil];
}
- (void)failureWithLink:(NSString *)error {
    self.resultTextField.text = @"";

    [self showWarningView:error];
}
- (void)showWarningView:(NSString *)str {
    self.errorLabel.text = str;
    if (self.notificatationView.frame.origin.y <= 0) {
        [UIView animateWithDuration:1/2.0 animations:^{
            CGRect rect = CGRectMake(self.notificatationView.frame.origin.x, self.notificatationView.frame.origin.y+self.notificatationView.frame.size.height, self.notificatationView.frame.size.width, self.notificatationView.frame.size.height);
            [self.notificatationView setFrame:rect];
        } completion:nil];        
    }
}
- (void)hideWarningView {
    [UIView animateWithDuration:1/2.0 animations:^{
        CGRect rect = CGRectMake(self.notificatationView.frame.origin.x, self.notificatationView.frame.origin.y-self.notificatationView.frame.size.height, self.notificatationView.frame.size.width, self.notificatationView.frame.size.height);
        [self.notificatationView setFrame:rect];
    } completion:nil];
}
- (BOOL)isNeedToHideWarning{
    if (self.notificatationView.frame.origin.y >= 0) {
        return YES;
    }
    return NO;
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
    [self setImageForHistoryButton];
    [self configureErrorView];
}
- (void)configureErrorView {
    self.notificatationView = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height / 7.0;
    CGFloat x = 0;
    CGFloat y = -height;
    CGRect rect = CGRectMake(x, y, width, height);
    [self.notificatationView setFrame:rect];
    
    self.notificatationView.backgroundColor = [UIColor colorWithRed:247/255.0 green:150/255.0 blue:150/255.0 alpha:100.0];
    
    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.font = [UIFont systemFontOfSize:20];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.textColor = [UIColor whiteColor];
    self.errorLabel.numberOfLines = 2;
    
    [self.notificatationView addSubview:self.errorLabel];
    [self.view addSubview:self.notificatationView];
    
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.errorLabel.bottomAnchor constraintEqualToAnchor:self.notificatationView.bottomAnchor constant:-5].active = YES;
    [self.errorLabel.leftAnchor constraintEqualToAnchor:self.notificatationView.leftAnchor].active = YES;
    [self.errorLabel.rightAnchor constraintEqualToAnchor:self.notificatationView.rightAnchor].active = YES;
    
}
- (void)configureLogo {
    self.logoBackgroundView.layer.cornerRadius = self.logoBackgroundView.frame.size.width/2.0;
}
- (void)configureTextFields {
    self.resultTextField.delegate = self;
    self.bottomLine.layer.cornerRadius = 2;
    self.secondBottomLine.layer.cornerRadius = 2;
    self.resultTextField.layer.cornerRadius = 6;
    self.resultTextField.layer.borderWidth = 3;
    self.resultTextField.layer.borderColor = [UIColor colorWithRed:247.0/255 green:150.0/255 blue:150.0/255 alpha:1.0].CGColor;
    self.resultTextField.textAlignment = NSTextAlignmentCenter;
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
- (void)setImageForHistoryButton {
    [self.historyButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
    
    self.historyButton.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.historyButton.imageView.heightAnchor constraintEqualToConstant:22].active = YES;
    [self.historyButton.imageView.widthAnchor constraintEqualToConstant:36].active = YES;
    [self.historyButton.imageView.centerXAnchor constraintEqualToAnchor:self.historyButton.centerXAnchor].active = YES;
    [self.historyButton.imageView.centerYAnchor constraintEqualToAnchor:self.historyButton.centerYAnchor].active = YES;
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
- (BOOL)checkIsLinkAlreadyInPasteboard {
    NSString *link = [UIPasteboard generalPasteboard].string;
    if ([AppleMusicSearch checkLinkWithString:link] || [SpotifySearch checkLinkWithString:link]) {
        return YES;
    }
    return NO;
}

#pragma mark - Check Apple Music Subscription


@end
