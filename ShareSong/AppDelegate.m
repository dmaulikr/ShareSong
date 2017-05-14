#import "AppDelegate.h"
#import "ViewController.h"
#import "SMKIntroViewController.h"

@interface AppDelegate ()
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    ViewController *vc = (ViewController *)self.window.rootViewController.presentedViewController;
    [vc ssearch];
}



@end
