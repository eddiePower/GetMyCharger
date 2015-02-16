//
//  ViewController.h
//  GrabMyCharger
//
//  Created by Eddie Power on 16/02/2015.
//  Copyright (c) 2015 Power and Boyd consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *chargerStateLabel;
@property (weak, nonatomic) UIDevice *myDevice;
- (IBAction)carModeSwitch:(id)sender;



@property (nonatomic, retain) IBOutlet UITextField *timerLabel;
@property (nonatomic, retain) NSTimer *timer;


-(void)updateCounter:(NSTimer *)theTimer;
-(void)countdownTimer;




@end

