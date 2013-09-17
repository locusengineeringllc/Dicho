//
//  DICHOAppDelegate.m
//  Dicho
//
//  Created by Tyler Droll on 9/22/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOAppDelegate.h"
#import <Parse/Parse.h>

@implementation DICHOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after application launch.
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    NSDictionary * defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                               
                               @"no", @"loggedIn",
                               @"", @"userID",
                               @"Not Logged In", @"username",
                               @"Not Logged In", @"name",
                               @"", @"password",
                               @"Not Logged In", @"email",
                               @"no", @"firstTimeToDicho",
                               @"no", @"firstTimeToSubmit",
                               @"no", @"firstTimeToSearch",
                               @"no", @"firstTimeToHome",
                               @"0", @"firstTimeOpening",
                               @"0", @"hasSetPushChannel",
                               @"0", @"hasSetDeviceToken",

                               
                               nil];
    [prefs registerDefaults:defaults];
    [prefs synchronize];
    
    [Parse setApplicationId:@"YNWRHIJkX0t1SvqM1md86grt2VmHVbMoPVTNTKd8"
                  clientKey:@"q2Up0Lr1e8eUcoFU5tLjrJVzxbVic4ChegmKt2KR"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];

    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    [prefs setObject:@"1" forKey:@"hasSetDeviceToken"];
    
    
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *channelStatus = [prefs objectForKey:@"hasSetPushChannel"];
    
    if([loginStatus isEqualToString:@"no"]){
        //do nothing
    }else{
        if([channelStatus isEqualToString:@"0"]){
            [currentInstallation addUniqueObject:[NSString stringWithFormat:@"c%@c", [prefs objectForKey:@"userID"]] forKey:@"channels"];
            [currentInstallation saveInBackground];
            [prefs setObject:@"1" forKey:@"hasSetPushChannel"];
        }
    }
        
    
    
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
