//
//  ViewController.h
//  GrabMyChargerTB
//
//  Created by Tyron Boyd on 17/02/2015.
//  Copyright (c) 2015 TyronPBoyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *chargerStateLabel;
@property (weak, nonatomic)UIDevice *myDevice;

- (IBAction)setCarModeSwitch:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *setHomeLocation;

@property (strong, nonatomic)CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITableView *homeLocationsTblView;
@property(strong, nonatomic) NSMutableArray *homeLocationsArray;
@property(strong, nonatomic) NSArray *streetAddressArray;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;


//reverse geocode method to get street address from gps data.
//-(NSArray  *)lookupStreetAddress;

@end

