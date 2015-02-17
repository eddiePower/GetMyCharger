//
//  ViewController.m
//  GrabMyChargerTB
//
//  Created by Tyron Boyd on 17/02/2015.
//  Copyright (c) 2015 TyronPBoyd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.myDevice = [UIDevice currentDevice];
    
    //Set a notification to tell us when the charger state has changed i.e: unplugged, charging, full.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object: self.myDevice];
    
    
}


- (void)batteryStateChanged:(NSNotification *)notification
{
    //Debug info:
    NSLog(@"The battery state has changed it is now %ld", self.myDevice.batteryState);
    
    //Check the battery states to alert user when needed.
    if (self.myDevice.batteryState == 1)
    {
        self.chargerStateLabel.text = @"Unplugged!";
        //Work out what is needed for plugged in state??
    }
    else if (self.myDevice.batteryState == 2)
    {
        self.chargerStateLabel.text = @"Charging!!";
        
        //ENTRY POINT for method calls to alert the user to take their charger with them.
        // May be do this via a notification if the app is not running!! needs more thinking time.
    }
    else if(self.myDevice.batteryState == 3)
    {
        self.chargerStateLabel.text = @"Battery Full!!!";
    }
    else if(self.myDevice.batteryState == 0)
    {
        self.chargerStateLabel.text = @"Prob simulator or a Error Charging.";
    }
    else
    {
        self.chargerStateLabel.text = @"Unknown-!";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setCarModeSwitch:(id)sender {
    if ([sender isOn])
    {
        self.myDevice.batteryMonitoringEnabled = YES;
    }
    else
    {
        self.myDevice.batteryMonitoringEnabled = NO;
        //self.chargerStateLabel.text = @"Monitoring off!";
        
    }
    
    
    
}
@end
