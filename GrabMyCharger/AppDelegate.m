//
//  AppDelegate.m
//  GrabMyCharger
//
//  Created by Eddie Power on 16/02/2015.
//  Copyright (c) 2015 Power and Boyd consulting. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic) UIUserNotificationType types;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Set up a Accept Action for notification.
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Set up a Maybe Action for notification.
    UIMutableUserNotificationAction *maybeAction = [[UIMutableUserNotificationAction alloc] init];
    maybeAction.identifier = @"MAYBE_IDENTIFIER";
    maybeAction.title = @"MayBe";
    maybeAction.activationMode = UIUserNotificationActivationModeBackground;
    maybeAction.destructive = NO;
    maybeAction.authenticationRequired = NO;
    
    //Set up a decline Action for notification.
    UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
    declineAction.identifier = @"DECLINE_IDENTIFIER";
    declineAction.title = @"Decline";
    declineAction.activationMode = UIUserNotificationActivationModeBackground;
    declineAction.destructive = NO;
    declineAction.authenticationRequired = NO;
    
    //Action catagories for above actions.
    UIMutableUserNotificationCategory *acceptCatagory = [[UIMutableUserNotificationCategory alloc] init];
    acceptCatagory.identifier = @"ACCEPT_CATAGORY";
    [acceptCatagory setActions:@[acceptAction, maybeAction, declineAction] forContext:UIUserNotificationActionContextDefault];
    [acceptCatagory setActions:@[acceptCatagory, declineAction] forContext:UIUserNotificationActionContextMinimal];
    
    //Register Action Catagories
    NSSet *catagories = [NSSet setWithObjects:acceptCatagory, nil];
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes: self.types categories: catagories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    
    
    //Ask user permission to show notifications from our app, this allows for badge,sound & alertBar.
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    //open space for the user defaults to be setup persestant during app run time.
    self.userDefaults = [[NSUserDefaults alloc] init];
    
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
    
    
    //Alert the user if they switch apps and the charger is unpluged at time of app switch
    // MAY REMOVE THIS ONE LATER.
    if ([UIDevice currentDevice].batteryState == 1)
    {
        NSLog(@"Background charging state is now %ld meaning unplugged!", [UIDevice currentDevice].batteryState);
        
        //create and init notification of the local Type = not from server -> apple -> device.
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        
        
        
        
        
        
        
        
        //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
        [notification setAlertBody:@"Background charging state is now 1 meaning unplugged!"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        
        //Set the notification on the application.
        [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
    else if ([UIDevice currentDevice].batteryState == 2)
    {
        NSLog(@"Background charging state is now %ld meaning Charging", [UIDevice currentDevice].batteryState);
        //create and init notification
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.category = @"ACCEPT_CATAGORY";
        //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
        [notification setAlertBody:@"Background charging state is now 2 meaning Charging!"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        
        //Set the notification on the application.
        [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
    else if ([UIDevice currentDevice].batteryState == 3)
    {
        NSLog(@"Background charging state is now %ld meaning Battery Full", [UIDevice currentDevice].batteryState);
        //create and init notification
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.category = @"ACCEPT_CATAGORY";
        //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
        [notification setAlertBody:@"Background charging state is now 3 meaning Battery Full!"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        
        //Set the notification on the application.
        [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
    
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
    //Prepare App notification that states the user should keep the app running if they wish to be reminded about their charger status! Important may need re wording of message.
    
    //create and init notification of the local Type = not from server -> apple -> device.
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    
    //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
    [notification setAlertBody:@"You Quit GrabMyCharger monitoring service! We cant protect your charger till you restart the app."];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
   
    //Set the notification on the application.
    [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    
}

@end
