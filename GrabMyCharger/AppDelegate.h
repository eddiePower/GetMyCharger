//
//  AppDelegate.h
//  GrabMyCharger
//
//  Created by Eddie Power on 16/02/2015.
//  Copyright (c) 2015 Power and Boyd consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSUserDefaults* userDefaults;
@property(strong, nonatomic) CLLocationManager *locationManager;

@property int inBackground;
@property int lastBatteryState;


@end

