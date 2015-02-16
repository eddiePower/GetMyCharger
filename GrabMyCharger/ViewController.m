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
    
    
    //Set a notification to tell us when the charger state has changed i.e: unplugged, charging, full.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
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
        
        //self.chargerStateLabel.text = @"Monitoring on!";
    }
    else
    {
        self.myDevice.batteryMonitoringEnabled = NO;
        //self.chargerStateLabel.text = @"Monitoring off!";
        
    }
}


-(void)updateCounter:(NSTimer *)theTimer
{
    //if the counter has timer above 0 then run loop.
    if (secondsLeft > 0)
    {
        //deduct one second
        secondsLeft--;
        
        //do math magic on secondsLeft value to turn it into human readable time hh:mm:ss
        // may shorten it to just mm:ss
        hours = secondsLeft / 3600; //=60seconds * 60 = 1 hr.
        minutes = (secondsLeft % 3600) / 60;
        seconds = (secondsLeft % 3600) % 60;
        
        //update timer label -- may not need this as it will be a blind counter from the users p.o.v.
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else
    {
        //Prepare the alertBox View.
        UIAlertView *chargerAlert = [[UIAlertView alloc] initWithTitle:@"GrabMyCharger" message:@"Dont Forget Your Charger!" delegate: self cancelButtonTitle:@"Got It" otherButtonTitles:@"Remind in 5", nil];
       
        //Show the alert box
        [chargerAlert show];
        
        //!! reset the timer this will be done via the alert box soon!!
        [self resetTimer: 300];
    }
}

//method to reset timer countdown to a user set or programed int value ie: 100 seconds = 1:30
-(void)resetTimer:(int)timePeriod
{
    secondsLeft = timePeriod;
}

//Main Timer Method to run the timer counting via 1second using the updateCounter method
// !! may need to use a bool variable to set if the timer repeates or not, so user and car mode can disable timer. !!
-(void)countdownTimer
{
    //Start the timer counting down by using the method UpdateCounter
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
    
}


- (void)batteryStateChanged:(NSNotification *)notification
{
    //Debug info:
    NSLog(@"The battery state has changed it is now %ld", self.myDevice.batteryState);
    
    //Check the battery states to alert user when needed.
    if (self.myDevice.batteryState == 2)
    {
        self.chargerStateLabel.text = @"Charging";
        //Work out what is needed for plugged in state??
    }
    else if (self.myDevice.batteryState == 1)
    {
        self.chargerStateLabel.text = @"unplugged!!";
        
        //ENTRY POINT for method calls to alert the user to take their charger with them.
        
    }
    
}




@end
