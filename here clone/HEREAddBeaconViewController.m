//
//  HEREAddBeaconViewController.m
//  here clone
//
//  Created by Joseph Cheung on 7/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREAddBeaconViewController.h"
#import "HERELocation.h"
#import "Location.h"

@interface HEREAddBeaconViewController ()
{
    NSTimer *animationTimer;
    NSNumber *major;
    NSNumber *minor;
    NSString *uuidString;
    NSArray *uuidStrings;
    NSString *name;
    NSString *locationId;
}
@property (strong, nonatomic) NSMutableArray *beaconRegions;
@property (strong, nonatomic) HERELocation *location;
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

- (HERELocation *)location
{
    if (!_location) {
        _location = [[HERELocation alloc] init];
    }
    return _location;
}

- (HEREAPIHelper *)apiHelper
{
    if (!_apiHelper) {
        _apiHelper = [[HEREAPIHelper alloc] init];
    }
    return _apiHelper;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    uuidStrings = @[@{ kHEREBeaconNameKey: @"readbear", kHEREBeaconUUIDKey: @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0" }, @{ kHEREBeaconNameKey: @"estimote", kHEREBeaconUUIDKey: @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"}];
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
    self.apiHelper.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.location monitorBeacons];
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
    if (major && minor && uuidString && name && locationId) {
        NSDictionary *data = @{ kHEREBeaconUUIDKey : uuidString, kHEREBeaconMajorKey : major, kHEREBeaconMinorKey : minor, kHEREBeaconNameKey : name, kHEREAPILocationIdKey : locationId };
        [self.apiHelper updateLocation:data];
        [self.delegate didAddBeacon];
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
    [self.location stopMonitoringBeacons];
    
    self.scanBeaconButton.hidden = YES;
    self.scanningBeaconsLabel.hidden = NO;
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.animationView selector:@selector(startCanvasAnimation) userInfo:nil repeats:YES];
    [self scanBeacons];
}

#pragma mark - CoreLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeaconRegion *beaconRegion in self.beaconRegions) {
        [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
    }
    CLBeacon *foundBeacon = [beacons firstObject];
    if (foundBeacon.major && foundBeacon.minor) {
        uuidString = [foundBeacon.proximityUUID UUIDString];
        self.foundBeacon = foundBeacon;
        [self checkExistingBeacon:foundBeacon];
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
    major = self.foundBeacon.major;
    minor = self.foundBeacon.minor;
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

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Detected iBeacon" message:@"Detected a new iBeacon" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}

- (void)checkExistingBeacon:(CLBeacon *)beacon
{
    NSDictionary *beaconDict = @{ kHEREAPIUUIDKey : [beacon.proximityUUID UUIDString], kHEREAPIMajorKey : beacon.major, kHEREAPIMinorKey : beacon.minor };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:beaconDict options:0 error:nil];
    
    NSString *postLength = [NSString stringWithFormat:@"%tu", [postData length]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kHEREAPILocationsUrl]];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:postData];
    
    NSURLSessionDataTask *uploadTask = [self.session dataTaskWithRequest:urlRequest];
    [uploadTask resume];
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

- (void)LocationWithServerId:(NSString *)serverId
{
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    Location *location = [NSEntityDescription insertNewObjectForEntityForName:kHERELocationClassKey inManagedObjectContext:context];
    location.name = name;
    location.major = major;
    location.minor = minor;
    location.uuid = uuidString;
    location.serverId = serverId;
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

#pragma mark - NSURLSession Delegate


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error != nil) {
        NSLog(@"did receive data error in add beacon view controller: %@", error);
        return;
    }
    if ([parsedObject[@"ok"] boolValue]) {
        NSLog(@"created location");
        locationId = parsedObject[kHEREAPILocationIdKey];
        [self foundNewBeacon];
    }
    else {
        NSLog(@"location already exists");
    }
}

#pragma mark - api Delegate

- (void)didUpdateLocation
{
    NSLog(@"updated location");
    [self.navigationController popViewControllerAnimated:YES];
}

@end
