//
//  AppDelegate.m
//  FenbiLiveSdkDemo
//
//  Created by Liu Jinjun on 2021/5/26.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] init];
    UIViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
