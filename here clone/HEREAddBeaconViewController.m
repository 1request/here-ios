//
//  HEREAddBeaconViewController.m
//  here clone
//
//  Created by Joseph Cheung on 7/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREAddBeaconViewController.h"

@interface HEREAddBeaconViewController ()
{
    NSTimer *animationTimer;
    NSNumber *major;
    NSNumber *minor;
    NSString *uuidString;
    NSString *name;
}

@end

@implementation HEREAddBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    uuidString = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"beacon"];

    // setup animation view
    self.animationView.layer.cornerRadius = self.animationView.frame.size.width / 2;
    self.animationView.duration = 0.5;
    self.animationView.delay = 0;
    self.animationView.type = CSAnimationTypeZoomIn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self showMenu];
}

- (IBAction)addBeaconButtonPressed:(UIButton *)sender
{
    name = self.beaconNameTextField.text;
    if (major && minor && uuidString && name) {
        [self addBeaconToParse];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Beacon UUID/major/minor/name is missing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)scanBeaconButtonPressed:(UIButton *)sender
{
    self.scanBeaconButton.hidden = YES;
    self.scanningBeaconsLabel.hidden = NO;
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.animationView selector:@selector(startCanvasAnimation) userInfo:nil repeats:YES];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

#pragma mark - CoreLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    CLBeacon *foundBeacon = [beacons firstObject];
    if (foundBeacon.major && foundBeacon.minor) {
        [self checkExistingBeacon:foundBeacon];
    }
}

#pragma mark - helper methods

- (void)foundNewBeacon:(CLBeacon *)beacon
{
    major = beacon.major;
    minor = beacon.minor;
    self.majorNumberLabel.text = [NSString stringWithFormat:@"%@", major];
    self.minorNumberLabel.text = [NSString stringWithFormat:@"%@", minor];
    
    [animationTimer invalidate];
    animationTimer = nil;
    
    self.animationView.hidden = YES;
    self.majorLabel.hidden = NO;
    self.majorNumberLabel.hidden = NO;
    self.minorLabel.hidden = NO;
    self.minorNumberLabel.hidden = NO;
    self.addBeaconButton.hidden = NO;
    self.beaconNameTextField.hidden = NO;
    
    int systemSoundId = 1304;
    AudioServicesPlaySystemSound(systemSoundId);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Detected iBeacon" message:@"Detected a new iBeacon. You can name and add it to your beacon collection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}

- (void)checkExistingBeacon:(CLBeacon *)beacon
{
    PFQuery *query = [PFQuery queryWithClassName:kHEREBeaconClassKey];
    [query whereKey:kHEREBeaconUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kHEREBeaconUUIDKey equalTo:uuidString];
    [query whereKey:kHEREBeaconMajorKey equalTo:beacon.major];
    [query whereKey:kHEREBeaconMinorKey equalTo:beacon.minor];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0) {
            if (!error) {
                NSLog(@"New beacon");
                [self foundNewBeacon:beacon];
            }
            else {
                NSLog(@"Error: %@", error.description);
            }
        } else {
            NSLog(@"Beacon already exists");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Existing Beacon" message:@"This beacon has been added before. Please place a new beacon near the device and press rescan." delegate:self cancelButtonTitle:@"Back to beacons list" otherButtonTitles:@"Rescan", nil];
            [alertView show];
        }
    }];
}

- (void)addBeaconToParse
{
    PFObject *beacon = [PFObject objectWithClassName:kHEREBeaconClassKey];
    [beacon setObject:[PFUser currentUser] forKey:kHEREBeaconUserKey];
    [beacon setObject:uuidString forKey:kHEREBeaconUUIDKey];
    [beacon setObject:major forKey:kHEREBeaconMajorKey];
    [beacon setObject:minor forKey:kHEREBeaconMinorKey];
    [beacon setObject:name forKey:kHEREBeaconNameKey];
    [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Save beacon successfully");
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSLog(@"Cannot save");
        }
    }];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            break;
        default:
            break;
    }
}

@end
