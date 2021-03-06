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
    
    //Ask user permission to show notifications from our app, this allows for badge,sound & alertBar.
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    //open space for the user defaults to be setup persestant during app run time.
    self.userDefaults = [[NSUserDefaults alloc] init];
    
    //Create location manager for use globally through-out the application
    self.locationManager = [[CLLocationManager alloc] init];
    //Start updating the location data of the user to begin monitoring regions after app loads.
    
    
    //Macro used to check that device is ios8+ then uses new location authorization
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
      //request permission to use location manager if user has not already granted it.
      [self.locationManager requestAlwaysAuthorization];
    
    #endif
    
    //Start updating the users location and heading / direction.
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];

    
    //Set desired accuracy as high as feasable due to purpose of the app.
    //may set a switch in settings to lower the accuracy to save battery life.
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    //self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
    //Set locationManager accuracy and distance filter or amount of space before device location is checked.
    // default is kCLDistanceFilterNone: all movements are reported.
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    //self.locationManager.distanceFilter = 5.0f;
    self.locationManager.delegate = self;

    
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
    
    //set flag for inBackground to let the location methods know.
    self.inBackground = 1;
    
    //Check background GPS monitoring is available and if so set a listener for batteryStateChanges.
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        // Stop normal location updates and start significant location change updates for battery efficiency.
        //[self.locationManager stopUpdatingLocation];
        // [self.locationManager startMonitoringSignificantLocationChanges];
        
        //Set a notification to tell us when the charger state has changed i.e: unplugged, charging, full.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:)
                                                     name:UIDeviceBatteryStateDidChangeNotification object: [UIDevice currentDevice]];
        
        //spit out some debug info on location data and battery.
        NSLog(@"Inside appDidEnterBackground and the allowed location change monitoring.\nLocation is now: %f, %f\nBatteryState is now: %li", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, [UIDevice currentDevice].batteryState);
        
    }
    else
    {
        NSLog(@"Significant location change monitoring is not available.");
    }
    
    
    //call to old timer to trigger notifications each 5 seconds keeping the battery state alive.
    //[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkBattery) userInfo:nil repeats:YES];
    
    //Alert Types used in Notification Action's catagories
    self.types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Set up a Accept Action for notification / button on notification that does somthing.
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"OK Got It";
    acceptAction.activationMode = UIUserNotificationActivationModeBackground; //keeps the app in the BG or can call it to FG.
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;

    //Set up a decline Action for notification.
    UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
    declineAction.identifier = @"DECLINE_IDENTIFIER";
    declineAction.title = @"Remind Me in 5";
    declineAction.activationMode = UIUserNotificationActivationModeBackground;
    declineAction.destructive = NO;
    declineAction.authenticationRequired = NO;
    
    //Action catagories for above actions.
    UIMutableUserNotificationCategory *acceptCatagory = [[UIMutableUserNotificationCategory alloc] init];
    acceptCatagory.identifier = @"ACCEPT_CATAGORY";
    [acceptCatagory setActions:@[acceptAction, declineAction] forContext:UIUserNotificationActionContextDefault];
    [acceptCatagory setActions:@[acceptAction, declineAction] forContext:UIUserNotificationActionContextMinimal];
    
    //Register Action Catagories
    NSSet *catagories = [NSSet setWithObjects:acceptCatagory, nil];
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes: self.types categories: catagories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    /*
    //Alert the user if they switch apps and the charger is unpluged at time of app switch
    // MAY REMOVE THIS ONE LATER.
    if ([UIDevice currentDevice].batteryState == 1)
    {
        NSLog(@"Background charging state is now %ld meaning unplugged!", [UIDevice currentDevice].batteryState);
        
        //create and init notification of the local Type = not from server -> apple -> device.
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setCategory:@"ACCEPT_CATAGORY"];
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
        [notification setCategory: @"ACCEPT_CATAGORY"];
        //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
        [notification setAlertBody:@"Background charging state is now 2 meaning Charging!"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        
        // NSLog(@"THE NOTIFICATION IS %@", notification.description);
        
        //Set the notification on the application.
        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
    else if ([UIDevice currentDevice].batteryState == 3)
    {
        NSLog(@"Background charging state is now %ld meaning Battery Full", [UIDevice currentDevice].batteryState);
        //create and init notification
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setCategory: @"ACCEPT_CATAGORY"];
        //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
        [notification setAlertBody:@"Background charging state is now 3 meaning Battery Full!"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        
        // NSLog(@"THE NOTIFICATION IS %@", notification.description);
        
        //Set the notification on the application.
        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
     */
    
}


-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    NSLog(@"In the notification action reciever method notification sent was the %@", identifier);
    
    NSLog(@"\nBatteryState is now: %ld\n", [UIDevice currentDevice].batteryState);

    completionHandler();
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //if inBg flag is set to true or 1 then run BG stuff
    
    if (self.inBackground == 1)
    {
        //Set a notification to tell us when the charger state has changed i.e: unplugged, charging, full.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object: [UIDevice currentDevice]];
        
        NSLog(@"The inBG flag is set to %i", self.inBackground);
        
    }
    else
    {
        
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //if inBg flag is set to true or 1 then run BG stuff
    if (self.inBackground == 1)
    {
        NSLog(@"In DidUpdate Heading Method of appDelegate / locationManagerDelegate.");
        //Set a notification to tell us when the charger state has changed i.e: unplugged, charging, full.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object: [UIDevice currentDevice]];
        NSLog(@"The inBG flag is set to %i", self.inBackground);
        
    }
    else
    {
        
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.inBackground = 0;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"ApplicationDidBecomeActive method running...");
    self.inBackground = 0;
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



/*
- (void)checkBattery
{

    NSString * levelLabel = [NSString stringWithFormat:@"%ld", [UIDevice currentDevice].batteryState];
    NSLog(@"STATE %@", levelLabel);
    
    //Set a notification to tell us when the charger state has changed i.e: unplugged, charging, full.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object: [UIDevice currentDevice]];
}
*/



- (void)batteryStateChanged:(NSNotification *)notification
{
    //Debug info:
    NSLog(@"The battery state has changed it is now %ld", [UIDevice currentDevice].batteryState);
    
    //Check the battery states to alert user when needed with notification or alert box.
    //Alert the user if they switch apps and the charger is unpluged at time of app switch
    // MAY REMOVE THIS ONE LATER.
    if ([UIDevice currentDevice].batteryState == 1)
    {
        NSLog(@"Background charging state is now %ld meaning unplugged!", [UIDevice currentDevice].batteryState);
        
        if (self.inBackground == 1)
        {
                if (self.lastBatteryState != [UIDevice currentDevice].batteryState)
                {
               UILocalNotification *notification = [[UILocalNotification alloc]init];
               [notification setCategory:@"ACCEPT_CATAGORY"];
               //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
               [notification setAlertBody:@"Background charging state is now 1 meaning unplugged!"];
               [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
               [notification setTimeZone:[NSTimeZone defaultTimeZone]];
               [notification setSoundName:UILocalNotificationDefaultSoundName];
            
               //Set the notification on the application.
               [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
                    //Update the stored last battery state to the current state preventing double notifications.
                    self.lastBatteryState = [UIDevice currentDevice].batteryState;
                    
                    //spit out the new battery state in storage.
                    NSLog(@"Stored Battery State is now %i", self.lastBatteryState);
                }
            
        }
        else  // alert user with app in the foreground.
        {
            //set up an alert box for when user unplugs while in the app!!!!
        }
        
    }
    else if ([UIDevice currentDevice].batteryState == 2)
    {
        NSLog(@"Background charging state is now %ld meaning Charging", [UIDevice currentDevice].batteryState);
        
        if (self.inBackground == 1)
        {
            if (self.lastBatteryState != [UIDevice currentDevice].batteryState)
            {
              //create and init notification
               UILocalNotification *notification = [[UILocalNotification alloc]init];
               [notification setCategory: @"ACCEPT_CATAGORY"];
               //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
                [notification setAlertBody:@"Background charging state is now 2 meaning Charging!"];
                [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                [notification setTimeZone:[NSTimeZone defaultTimeZone]];
                [notification setSoundName:UILocalNotificationDefaultSoundName];
            
                //Set the notification on the application.
                [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
                //Update the stored last battery state to the current state preventing double notifications.
                self.lastBatteryState = [UIDevice currentDevice].batteryState;
                
                //spit out the new battery state in storage.
                NSLog(@"Stored Battery State is now %i", self.lastBatteryState);
            }
        }
        else  // alert user with app in the foreground.
        {
            //set up an alert box for when user unplugs while in the app!!!!
        }
    }
    else if ([UIDevice currentDevice].batteryState == 3)
    {
        NSLog(@"Background charging state is now %ld meaning Battery Full", [UIDevice currentDevice].batteryState);
        
        if (self.inBackground == 1)
        {
            if (self.lastBatteryState != [UIDevice currentDevice].batteryState)
            {
                //create and init notification
                UILocalNotification *notification = [[UILocalNotification alloc]init];
                [notification setCategory: @"ACCEPT_CATAGORY"];
                //set notification message, fireTime 0 seconds = now, using the device timeZone setting.
                [notification setAlertBody:@"Background charging state is now 3 meaning Battery Full!"];
                [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                [notification setTimeZone:[NSTimeZone defaultTimeZone]];
                [notification setSoundName:UILocalNotificationDefaultSoundName];
            
                //Set the notification on the application.
                [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
                //Update the stored last battery state to the current state preventing double notifications.
                self.lastBatteryState = [UIDevice currentDevice].batteryState;
                
                //spit out the new battery state in storage.
                NSLog(@"Stored Battery State is now %i", self.lastBatteryState);
            }//end if check on batterState stored value
        }//end of if in background check
        else  // alert user with app in the foreground.
        {
            //set up an alert box for when user unplugs while in the app!!!!
        }
    }//end of battery state check
}

@end
