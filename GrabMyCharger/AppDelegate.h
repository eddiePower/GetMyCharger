//
//  AppDelegate.h
//  GrabMyCharger
//
//  Created by Eddie Power on 16/02/2015.
//  Copyright (c) 2015 Power and Boyd consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (assign, nonatomic) BOOL background;
@property (assign, nonatomic) BOOL sentNotification;
@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) UIDeviceBatteryState lastBatteryState;
@property (assign, nonatomic) BOOL jobExpired;
@property (assign, nonatomic) BOOL batteryFullNotificationDisplayed;
@property (strong, nonatomic) NSUserDefaults* userDefaults;



@end

