//
//  HEREAddBeaconViewController.m
//  here clone
//
//  Created by Joseph Cheung on 7/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREAddBeaconViewController.h"
#import "HERELocationHelper.h"
#import "Location.h"
#import "APIManager.h"
#import "CoreDataStore.h"

@interface HEREAddBeaconViewController ()

@property (weak, nonatomic) NSTimer *animationTimer;
@property (strong, nonatomic) NSMutableArray *beaconRegions;
@property (strong, nonatomic) HERELocationHelper *locationHelper;
@property (strong, nonatomic) CLBeacon *foundBeacon;

@end

@implementation HEREAddBeaconViewController

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (HERELocationHelper *)locationHelper
{
    if (!_locationHelper) {
        _locationHelper = [[HERELocationHelper alloc] init];
    }
    return _locationHelper;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [CoreDataStore mainQueueContext];
    }
    return _managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    NSArray *uuidStrings = @[@{ kHEREBeaconNameKey: @"readbear", kHEREBeaconUUIDKey: @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0" }, @{ kHEREBeaconNameKey: @"estimote", kHEREBeaconUUIDKey: @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"}];
    self.beaconRegions = [@[] mutableCopy];
    for (NSDictionary *beacon in uuidStrings) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beacon[kHEREBeaconUUIDKey]];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:beacon[kHEREBeaconNameKey]];
        [self.beaconRegions addObject:beaconRegion];
    }

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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationHelper stopMonitoringBeacons];
    [self.locationHelper monitorBeacons];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)addBeaconButtonPressed:(UIButton *)sender
{
    NSDictionary *data = @{ kHEREAPILocationNameKey : self.beaconNameTextField.text, kHEREAPILocationUUIDKey : [self.foundBeacon.proximityUUID UUIDString], kHEREAPILocationMajorKey : self.foundBeacon.major, kHEREAPILocationMinorKey : self.foundBeacon.minor };
    
    [APIManager createLocationInServer:data CompletionHandler:^(BOOL success, NSDictionary *response, NSError *error) {
        if (success) {
            [APIManager fetchLocationsWithManagedObjectContext:[CoreDataStore privateQueueContext] CompletionHandler:NULL];
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)scanBeaconButtonPressed:(UIButton *)sender
{
    [self.locationHelper stopMonitoringBeacons];
    
    self.scanBeaconButton.hidden = YES;
    self.scanningBeaconsLabel.hidden = NO;
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.animationView selector:@selector(startCanvasAnimation) userInfo:nil repeats:YES];
    [self scanBeacons];
}

#pragma mark - CoreLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *foundBeacon in beacons) {
        if (foundBeacon.major && foundBeacon.minor) {
            [self checkExistingBeaconInCoreData:foundBeacon];
        }
    }
}

#pragma mark - helper methods

- (void)scanBeacons
{
    for (CLBeaconRegion *beaconRegion in self.beaconRegions) {
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}

- (void)foundNewBeacon
{
    self.majorNumberLabel.text = [NSString stringWithFormat:@"%@", self.foundBeacon.major];
    self.minorNumberLabel.text = [NSString stringWithFormat:@"%@", self.foundBeacon.minor];
    
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    
    self.animationView.hidden = YES;
    self.majorLabel.hidden = NO;
    self.majorNumberLabel.hidden = NO;
    self.minorLabel.hidden = NO;
    self.minorNumberLabel.hidden = NO;
    self.addBeaconButton.hidden = NO;
    self.beaconNameTextField.hidden = NO;

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Detected iBeacon" message:@"Detected a new iBeacon" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}

- (void)checkExistingBeaconInCoreData:(CLBeacon *)beacon
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@ AND %K == %@", kHEREAPILocationUUIDKey, [beacon.proximityUUID UUIDString], kHEREAPILocationMajorKey, beacon.major, kHEREAPILocationMinorKey, beacon.minor];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kHERELocationClassKey];
    fetchRequest.predicate = predicate;
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (!fetchError) {
        if ([result count] != 0) {
            NSLog(@"exist in database");
        }
        else {
            NSLog(@"New beacon");
            self.foundBeacon = beacon;
            [self foundNewBeacon];
            for (CLBeaconRegion *beaconRegion in self.beaconRegions) {
                [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
            }
        }
    }
    else {
        NSLog(@"fetch error in add beacon view controller: %@", fetchError);
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:
            [self scanBeacons];
            break;
        default:
            break;
    }
}

@end
