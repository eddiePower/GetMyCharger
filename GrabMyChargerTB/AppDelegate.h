//
//  AppDelegate.h
//  GrabMyChargerTB
//
//  Created by Tyron Boyd on 17/02/2015.
//  Copyright (c) 2015 TyronPBoyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)CLLocationManager *locationManager;
@property (strong, nonatomic)NSUserDefaults *userDefaults;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, retain) NSTimer *silenceTimer;


@property int inBackground;
@property int lastBatteryState;


@end

