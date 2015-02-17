//
//  AppDelegate.m
//  GrabMyChargerTB
//
//  Created by Tyron Boyd on 17/02/2015.
//  Copyright (c) 2015 TyronPBoyd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic) UIUserNotificationType types;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        
    }
    self.userDefaults = [[NSUserDefaults alloc] init];

    
    //allocate a new location manager object
    self.locationManager = [[CLLocationManager alloc] init];
    
    //Macro used to check that device is ios8+ then uses new location authorization
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    //request permission to use location manager if user has not already granted it.
    [self.locationManager requestAlwaysAuthorization];
    
#endif
    //Begin updating the users location and heading
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    //setting the location manager distance filter to best
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    
    
    
    return YES;
}



-(void)application:(UIApplication*)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    
    NSLog(@"In the notification action reciever method notification sent was the %@", identifier);
    
    NSLog(@"\nBatteryState is now: %d\n", [UIDevice currentDevice].batteryState);
    
    completionHandler();

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //did enter background method//
    
    self.inBackground = 1;
    //if location manager (GPS) is available then notify the user when the battery state is changed. Also listens for batteryState changes
    UIBackgroundTaskIdentifier bgTask;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    self.silenceTimer = [NSTimer scheduledTimerWithTimeInterval:550 target:self
                                                       selector:@selector(reloadLocationManager) userInfo:nil repeats:YES];
    
    [self updateLocation];
    
}


-(void)reloadLocationManager {
    
    
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    //setting the location manager distance filter to best
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    
    
}

-(void)updateLocation {
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        //Notifies the user if the battery state is changed to unplugged, plugged in or full.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:[UIDevice currentDevice]];
        
        //spit out some debug info on location data and battery.
        NSLog(@"Inside appDidEnterBackground and the allowed location change monitoring.\nLocation is now: %f, %f\nBatteryState is now: %i", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, [UIDevice currentDevice].batteryState);
    } else {
        NSLog(@"GPS data is not available, please check your connection");
    }
    
    
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


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self.inBackground = 0;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"Application window now opened");
    self.inBackground = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Call a notification when the application exits to let the user know the app wont notify them
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:@"To continue protecting your charger you must re-open Grab My Charger!"];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
    
    [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    
}



-(void)batteryStateChanged:(NSNotification*)notification {
    
    //debug state
    NSLog(@"The battery state has changed to %d", [UIDevice currentDevice].batteryState);
    

    if ([UIDevice currentDevice].batteryState == 1) {
    
        if (self.inBackground == 1) {
        
            if (self.lastBatteryState != [UIDevice currentDevice].batteryState) {
            
                UILocalNotification* notification = [[UILocalNotification alloc] init];
                [notification setCategory:@"ACCEPT_CATEGORY"];
                [notification setAlertBody:@"Charger Is Unplugged! (state:1)!"];
                [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                [notification setTimeZone:[NSTimeZone defaultTimeZone]];
                [notification setSoundName:UILocalNotificationDefaultSoundName];
            
                //Set the localNotifications for the app
                [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
                //set the last battery state
                self.lastBatteryState = [UIDevice currentDevice].batteryState;
                NSLog(@"New battery state %i", self.lastBatteryState);
            
                }
        } else {
        //Application is not in the background
        //code here for unplugging whilst still in the app
        }

    } else if ([UIDevice currentDevice].batteryState == 2){
    
            if (self.inBackground == 1) {
                
                if (self.lastBatteryState != [UIDevice currentDevice].batteryState) {
                    
                    UILocalNotification* notification = [[UILocalNotification alloc] init];
                    [notification setCategory:@"ACCEPT_CATEGORY"];
                    [notification setAlertBody:@"Charger Is Plugged in! (state:2)!"];
                    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
                    [notification setSoundName:UILocalNotificationDefaultSoundName];
                    
                    //Set the localNotifications for the app
                    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
                    //set the last battery state
                    self.lastBatteryState = [UIDevice currentDevice].batteryState;
                    NSLog(@"New battery state %i", self.lastBatteryState);
                    
                }
        
            }
        } else if ([UIDevice currentDevice].batteryState == 3) {
                
                if (self.inBackground == 1) {
                    
                    if (self.lastBatteryState != [UIDevice currentDevice].batteryState) {
                        
                        UILocalNotification* notification = [[UILocalNotification alloc] init];
                        [notification setCategory:@"ACCEPT_CATEGORY"];
                        [notification setAlertBody:@"battery is fully charged! (state:3)!"];
                        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
                        [notification setSoundName:UILocalNotificationDefaultSoundName];
                        
                        //Set the localNotifications for the app
                        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
                        //set the last battery state
                        self.lastBatteryState = [UIDevice currentDevice].batteryState;
                        NSLog(@"New battery state %i", self.lastBatteryState);
                        
                    }//end last state battery
                }//end inBackground
            }//end else if
        }
@end
