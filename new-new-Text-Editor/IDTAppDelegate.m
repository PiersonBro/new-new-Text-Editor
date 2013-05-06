//
//  IDTAppDelegate.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTAppDelegate.h"
#import "IDTSplitViewController.h"
#import "IDTDetailViewController.h"
#import "IDTMasterViewController.h"
@implementation IDTAppDelegate

-(void)customizeApperance {
    //Added UINavigationBar apperance stuff the color is now a nice green. 
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.1 green:0.5 blue:0.5 alpha:1]];
//  [[UINavigationBar appearance] setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIColor colorWithRed:0.1 green:0.5 blue:0.5 alpha:1.0],
//      UITextAttributeTextColor,
//      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
//      UITextAttributeTextShadowColor,
//      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
//      UITextAttributeTextShadowOffset,
//      [UIFont fontWithName:@"Arial-Bold" size:0.0],
//      UITextAttributeFont,
//      nil]];
}
#define MEASURE_LAUNCH_TIME 1
extern CFAbsoluteTime startTime;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Launched in %f seconds",CFAbsoluteTimeGetCurrent() -startTime);
    });
    [self customizeApperance];
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        IDTSplitViewController *splitViewController = (IDTSplitViewController *)self.window.rootViewController;
//        IDTMasterViewController  *masterViewController = [splitViewController.viewControllers objectAtIndex:0];
//        IDTDetailViewController *detailViewController = [splitViewController.viewControllers lastObject];
//    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    IDTMasterViewController *firstViewController = (IDTMasterViewController *)[[navigationController viewControllers] objectAtIndex:0];
    // Make sure url indicates a file (as opposed to, e.g., http://)
    if (url != nil && [url isFileURL]) {
        //Contact the MasterVC and tell it to add a url to the datasource. 
        [firstViewController addFileFromURL:url];
        
    }
    // Indicateas that we have successfully opened the URL
    return YES;
}

@end
