#import "AppDelegate.h"
#import "ViewController.h"
#import "SMKIntroViewController.h"
#import "SMKHistoryData.h"

@interface AppDelegate ()
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"search" object:nil];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[SMKHistoryData sharedData] saveChanges];
    if (!success) {
        @throw [NSException exceptionWithName:@"Error while saving" reason:@"appDelegate" userInfo:nil];
    }
}



@end
