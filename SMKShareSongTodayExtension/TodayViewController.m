//
//  TodayViewController.m
//  SMKShareSongTodayExtension
//
//  Created by Vo1 on 04/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "SMKTransferingSong.h"

@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic) UIActivityIndicatorView *ind;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
//@property (nonatomic) SMKTransferingSong *transferManger;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ind = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:self.ind];
//    self.transferManger = [[SMKTransferingSong alloc] init];
    
    // Do any additional setup after loading the view from its nib.
}

//- (void)search {
//    NSString *link = [UIPasteboard generalPasteboard].string;
//    self.resultLabel.text = @"";
//    if ([SMKTransferingSong isSuitableLink:link]) {
//        [self.ind startAnimating];
//        [self.transferManger transferSongWithLink:link withSuccessBlock:^(NSString *str) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.resultLabel.text = @"Succes";
//                [self.ind stopAnimating];
//                [UIPasteboard generalPasteboard].string = str;
//            });
//        } withFailureBlock:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.resultLabel.text = @"Fail";
//                [self.ind stopAnimating];
//            });
//        }];
//    }
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self search];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
