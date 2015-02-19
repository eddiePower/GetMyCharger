//
//  ViewController.m
//  GrabMyChargerTB
//
//  Created by Tyron Boyd on 17/02/2015.
//  Copyright (c) 2015 TyronPBoyd. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.myDevice = [UIDevice currentDevice];

    
    self.locationManager = [[CLLocationManager alloc] init];
    
    //setting the location manager distance filter to best
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    
    //set up the homeLocations array this may come from CoreData soon
    // incase user has managed to exit the app when not using it.
    
    self.homeLocationsArray = [[NSMutableArray alloc] init];
    self.streetAddressArray = [[NSArray alloc] init];
    
    //Set a notification to tell us when the charger state has changed i.e: unplugged, charging, full.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object: self.myDevice];
    
    
    [self.setHomeLocation addTarget:self action:@selector(buttonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self.homeLocationsTblView reloadData];
}

/*
-(NSArray  *)lookupStreetAddress
{
    //create the reverseGeocoder to get the address of the gps data for home location.
    //or may be user will input that them selfs.
    // Reverse Geocoding
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    
    [geocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
         
         if (error == nil && [placemarks count] > 0)
         {
             NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[placemarks count]];
             
             for (CLPlacemark *placemark in placemarks)
             {
                 [tempArray addObject:[NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                                       placemark.subThoroughfare, placemark.thoroughfare,
                                       placemark.locality, placemark.postalCode,
                                       placemark.administrativeArea,
                                       placemark.country]];
             }
             
             self.streetAddressArray = [tempArray copy];
         }
         else
         {
             self.streetAddressArray = nil;
             NSLog(@"%@", error.debugDescription);
         }
     }];
    
    NSLog(@"Returning street address's of %@", self.streetAddressArray.description);
    
    
    return self.streetAddressArray;
}
*/

- (IBAction)buttonPressed:(UIButton *)sender
{
    
    //Prepare the alertBox View. - New to iOS 5+
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"GrabMyCharger"
                                          message: [NSString stringWithFormat:@"%f, %f", self.locationManager.location.coordinate.longitude, self.locationManager.location.coordinate.latitude]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    //create some UIAlertController(AlertBox) actions(buttons) to show.
    //create a cancel action/button
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       //cancel or dont add the home location somehow.
                                       NSLog(@"Cancel action logic is now running....");
                                   }];
    
    //create a OK action
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   //ok do nothing with it. or other action.
                                   NSLog(@"OK action logic is now running....\nTrying to add %@", [NSString stringWithFormat:@"%f, %f", self.locationManager.location.coordinate.longitude, self.locationManager.location.coordinate.latitude]);
                                   
                                   
                                   //create the reverseGeocoder to get the address of the gps data for home location.
                                   //or may be user will input that them selfs.
                                   // Reverse Geocoding
                                   CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                   
                                   //run the reverse geoCode or a lookup from gps(Long, Lat) CLLocation object and runs a async block on a webserver to find the street address which is returned as a array of CLPlacemark objects.
                                   [geocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
                                    {
                                        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                                        
                                        //if no errors and there are results
                                        if (error == nil && [placemarks count] > 0)
                                        {
                                            //create temp array with the placemarks found
                                            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[placemarks count]];
                                            
                                            //for each placemark in our array
                                            for (CLPlacemark *placemark in placemarks)
                                            {
                                                //add a string with address for each placemark found in our tempArray
                                                [tempArray addObject:[NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                                                                      placemark.subThoroughfare, placemark.thoroughfare,
                                                                      placemark.locality, placemark.postalCode,
                                                                      placemark.administrativeArea,
                                                                      placemark.country]];
                                            }
                                            
                                            //copy and finish using our Mutable tempArray to our Array for adding to our view
                                            self.streetAddressArray = [tempArray copy];
                                            //Add the current location street address as a string to our Array
                                            [self.homeLocationsArray addObjectsFromArray: self.streetAddressArray];
                                            
                                            //add the new result to the table view when it is finished downloading
                                            //!!!! Monitor time for random locations in the field!!!!
                                            [self.homeLocationsTblView reloadData];
                                        }
                                        else
                                        {
                                            self.streetAddressArray = nil;
                                            NSLog(@"%@", error.debugDescription);
                                        }
                                    }];
                                   
                                   //NSLog(@"Returning street address's of %@", self.streetAddressArray.description);
                               }];
    
    //add actions to the new alertController.
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    //present the AlertBox viewController to the screen.
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    //Create an annoying sound for use prob not here but else where in the app!!
    //set the location of the sound file any length either mp3 or wav
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/beepSound.wav", [[NSBundle mainBundle] resourcePath]]];
    //create error object in case error happens in playing
    NSError *error;
    
    //create a audio player object with the above file location and error objects.
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:&error];
    //only let the audioPlayer run 1 time.
    self.audioPlayer.numberOfLoops = 1;
    //play the sound effect now.
    [self.audioPlayer play];
    
}

- (void)batteryStateChanged:(NSNotification *)notification
{
    //Debug info:
    // NSLog(@"The battery state has changed it is now %ld", self.myDevice.batteryState);
    
    //Check the battery states to alert user when needed.
    if (self.myDevice.batteryState == 1)
    {
        self.chargerStateLabel.text = @"Unplugged!";
        //Work out what is needed for plugged in state??
        
        //Prepare the alertBox View.
        UIAlertView *chargerAlert = [[UIAlertView alloc] initWithTitle:@"GrabMyCharger" message:@"Dont forget to Grab Your charger." delegate: self cancelButtonTitle:@"Got It" otherButtonTitles:@"Remind in 5", nil];
        
        //Show the alert box
        [chargerAlert show];
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
       
        //Prepare the alertBox View.
        UIAlertView *chargerAlert = [[UIAlertView alloc] initWithTitle:@"GrabMyCharger" message:@"Running in the simulator? then the unknowen state is not a real error!" delegate: self cancelButtonTitle:@"Got It" otherButtonTitles:@"Remind in 5", nil];
        
        //Show the alert box
        [chargerAlert show];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setCarModeSwitch:(id)sender
{
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.homeLocationsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"homePointsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.homeLocationsArray objectAtIndex:indexPath.row];
    
    
    
    return cell;
}

//Table View method to stop editing / deleting of a specific row in this case the alarm count.
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
        return YES;
}

//Save or delete a row/Alarm/Region and update table view data and display.
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If they type of edit initiated by the user is the delete action then
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {

        
        NSString *tmpString = [self.homeLocationsArray objectAtIndex:indexPath.row];
        NSLog(@"The string to delete is %@" , tmpString);
        
        
        //remove the string in the array matching tmpString.
        [self.homeLocationsArray removeObjectAtIndex: indexPath.row];
        
        
        
        //Set the animation of the delete action
        //Comment out to switch to reload all table data
        //   [self.homeLocationsTblView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationFade];
        
        //set animation of the reloaded rows moving up in place of removed row.
        //combines delete and reload tableView data in one.
        // [self.homeLocationsTblView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: 0 inSection: 1]] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.homeLocationsTblView reloadData];
        
        NSLog(@"The Array is now %@", self.homeLocationsArray.description);
        
    }
}



@end
