#import "AppDelegate.h"
#import "ViewController.h"
#import "SMKIntroViewController.h"
#import "SMKHistoryData.h"

@interface AppDelegate ()
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    ViewController *vc = (ViewController *)self.window.rootViewController.presentedViewController;
    [vc search];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[SMKHistoryData sharedData] saveChanges];
    if (!success) {
        @throw [NSException exceptionWithName:@"Error while saving" reason:@"IDK appDelegate" userInfo:nil];
    }
    
}



@end
