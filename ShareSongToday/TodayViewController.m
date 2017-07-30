//
//  TodayViewController.m
//  ShareSongToday
//
//  Created by Vo1 on 30/07/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation TodayViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateLabelsText];
}

- (void)updateLabelsText {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ShareSong.ShareSongToday"];
    NSString *title = [defaults objectForKey:@"title"];
    NSString *artist = [defaults objectForKey:@"artist"];
    self.artistLabel.text = artist;
    self.titleLabel.text = title;
}


- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
