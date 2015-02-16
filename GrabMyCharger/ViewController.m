//
//  ViewController.m
//  GrabMyCharger
//
//  Created by Eddie Power on 16/02/2015.
//  Copyright (c) 2015 Power and Boyd consulting. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

int hours, minutes, seconds;
int secondsLeft;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional init for complex objects that need it.
    self.myDevice = [UIDevice currentDevice];
    self.timer = [[NSTimer alloc] init];
    
    //set timer for 5Mins = 300
    [self resetTimer: 10];
    
    //call begin count down / timer.
    [self countdownTimer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Car Mode switch interface for after load time. is set by default to always on atm!!
- (IBAction)carModeSwitch:(id)sender
{
    if ([sender isOn])
    {
        self.myDevice.batteryMonitoringEnabled = YES;
        // The UI will be updated as a result of the first UIDeviceBatteryStateDidChangeNotification notification.
        // Note that enabling monitoring only triggers a UIDeviceBatteryStateDidChangeNotification;
        // a UIDeviceBatteryLevelDidChangeNotification is not sent.
        
        self.chargerStateLabel.text = @"Monitoring on!";
    }
    else
    {
        self.myDevice.batteryMonitoringEnabled = NO;
        self.chargerStateLabel.text = @"Monitoring off!";
        
    }
}


-(void)updateCounter:(NSTimer *)theTimer
{
    if (secondsLeft > 0)
    {
        //deduct one second
        secondsLeft--;
        
        hours = secondsLeft / 3600; //=60seconds * 60 = 1 hr.
        minutes = (secondsLeft % 3600) / 60;
        seconds = (secondsLeft % 3600) % 60;
        
        //update timer label -- may not need this as it will be a blind counter from the users p.o.v.
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else
    {
        UIAlertView *chargerAlert = [[UIAlertView alloc] initWithTitle:@"GrabMyCharger" message:@"Dont Forget Your Charger!" delegate: self cancelButtonTitle:@"Got It" otherButtonTitles:@"Remind in 5", nil];
       
        [chargerAlert show];
        
        [self resetTimer: 300];
    }
}

-(void)resetTimer:(int)timePeriod
{
    secondsLeft = timePeriod;
}

-(void)countdownTimer
{
    //Start the timer counting down by using the method UpdateCounter
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
    
}

@end
