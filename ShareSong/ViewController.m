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
#import "Searcher.h"


@interface ViewController () <MPMediaPickerControllerDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UITextField *resultTextField;
@property (weak, nonatomic) IBOutlet UIView *backViewWithMask;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIView *logoBackgroundView;
@property (nonatomic) UIAlertController *successAlertController;
@property (nonatomic) UIAlertController *failureAlertController;
@property (nonatomic) SMKLoaderView *animationView;
@property (nonatomic) SMKTransferingSong *transferManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIView *secondBottomLine;
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
    if (![self.resultTextField.text isEqualToString:@""]) {
        [self search];
    }
    return YES;
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.resultTextField resignFirstResponder];
}

#pragma mark - Actions
- (IBAction)presentHistoryVC:(id)sender {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    SMKHistoryCollectionViewController *vc = [[SMKHistoryCollectionViewController alloc]
                                              initWithCollectionViewLayout:flowLayout];
    
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
        [weakViewController.transferManager transferSongWithLink:[UIPasteboard generalPasteboard].string
                                                withSuccessBlock:^(NSDictionary *dict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakViewController succesfullLink:dict sourceLink:url];
//                [weakViewController updateTodayExtensionWithSong:dict];
                [weakViewController save];
                [weakViewController.indicatorView stopAnimating];
            });
        } withFailureBlock:^(NSString *errorMessage){
            if (!errorMessage) {errorMessage = [NSString stringWithFormat:@""];}
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakViewController failureWithLink:[NSString stringWithFormat:@"Why are you punishing me? (%@)", errorMessage]];
                [weakViewController.indicatorView stopAnimating];
                weakViewController.resultTextField.text = @"";
            });
        }];
    } else {
        [weakViewController failureWithLink:@"I have some bad news. (Wrong link)"];
        weakViewController.resultTextField.text = @"";
        [weakViewController.indicatorView stopAnimating];
    }
}
- (void)searchFromNotification:(NSNotification *)n {
    [self search];
}

#pragma mark - success/fail
- (void)succesfullLink:(NSDictionary *)dict sourceLink:(NSString *)link{
    self.resultTextField.text = [dict objectForKey:@"url"];
    [self pasteToPasteboard:self.resultTextField.text];
    if (![[SMKHistoryData sharedData] isMemberWith:link]) {
        [[SMKHistoryData sharedData] addSongWithDict:[self prepareDictWith:dict sourceLink:link]];
    }
    [self presentViewController:self.successAlertController animated:YES completion:nil];
}
- (void)failureWithLink:(NSString *)error {
    self.resultTextField.text = @"";
    [self.failureAlertController setMessage:error];
    [self presentViewController:self.failureAlertController animated:YES completion:nil];
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
    NSString *imgLink = [dict objectForKey:@"artwork"];
    
    NSDictionary *songData = [[NSDictionary alloc] initWithObjectsAndKeys:appleMusicLink,@"appleLink",
                              spotifyLink, @"spotifyLink",
                              title, @"title",
                              artist, @"artist",
                              imgLink,@"imgLink",nil];
    return songData;
}

#pragma mark - Prepare view
- (void)prepareView {
    [self configureLogo];
    [self configureTextFields];
    [self prepareIndicatorView];
    [self prepareAlertControllers];
    [self setImageForHistoryButton];
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
    self.resultTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}
- (void)prepareIndicatorView {
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.view.center;
    [self.view addSubview:self.indicatorView];
}
- (void)prepareAlertControllers {
    self.successAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSuccess = [UIAlertAction actionWithTitle:@"Daaamn" style:UIAlertActionStyleCancel handler:nil];
    NSString *emoji = [self configuredEmoji:@"\xF0\x9F\x99\x8C"];
    NSString *successTitle = [NSString stringWithFormat:@"%@ Success %@",emoji,emoji];
    [self.successAlertController setTitle:successTitle];
    [self.successAlertController setMessage:@"You wishes link in clipboard now. Just send it to your mom ;)"];
    
    self.failureAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionFail = [UIAlertAction actionWithTitle:@"OMG WHY?!" style:UIAlertActionStyleCancel handler:nil];
    NSString *failTitle = [NSString stringWithFormat:@"Sorry, but your link is wrong. Very wrong"];
    [self.failureAlertController setTitle:failTitle];
    [self.failureAlertController setMessage:@"Maybe, no.Try again later. Bad link. No life. Just work."];
    
    [self.successAlertController addAction:actionSuccess];
    [self.failureAlertController addAction:actionFail];
}
- (void)setImageForHistoryButton {
    [self.historyButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
    
    self.historyButton.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.historyButton.imageView.heightAnchor constraintEqualToConstant:22].active = YES;
    [self.historyButton.imageView.widthAnchor constraintEqualToConstant:36].active = YES;
    [self.historyButton.imageView.centerXAnchor constraintEqualToAnchor:self.historyButton.centerXAnchor].active = YES;
    [self.historyButton.imageView.centerYAnchor constraintEqualToAnchor:self.historyButton.centerYAnchor].active = YES;
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
