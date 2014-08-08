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
}

@end

@implementation HEREAddBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    NSUUID *redBearUUID = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:redBearUUID identifier:@"beacon"];

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
    [self.navigationController popViewControllerAnimated:YES];
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
    CLBeacon *foundBeacon = [beacons firstObject];
    if (foundBeacon.major && foundBeacon.minor) {
        
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
        
        NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
        NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
        self.majorNumberLabel.text = major;
        self.minorNumberLabel.text = minor;
 
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
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Detected iBeacon" message:@"Detected a new iBeacon. You can name and add it to your beacon collection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

@end
