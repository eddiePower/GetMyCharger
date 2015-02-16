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

@property (strong, nonatomic) dispatch_block_t expirationHandler;

@property (strong, nonatomic) NSUserDefaults* userDefaults;



@end

