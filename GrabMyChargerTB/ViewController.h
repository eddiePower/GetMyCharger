//
//  ViewController.h
//  GrabMyChargerTB
//
//  Created by Tyron Boyd on 17/02/2015.
//  Copyright (c) 2015 TyronPBoyd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *chargerStateLabel;
@property (weak, nonatomic)UIDevice *myDevice;

- (IBAction)setCarModeSwitch:(id)sender;



@end

