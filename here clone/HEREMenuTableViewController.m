//
//  HEREMenuTableViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREMenuTableViewController.h"
#import "HEREHomeViewController.h"
#import "HEREBeaconsTableViewController.h"
#import "HERECreateUserViewController.h"
#import "HERESignInViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "HERENavigationViewController.h"

@interface HEREMenuTableViewController ()

@property (strong, nonatomic) UILabel *usernameLabel;

@end

@implementation HEREMenuTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([PFUser currentUser]) {
        self.tableView.tableHeaderView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            imageView.image = [UIImage imageNamed:@"anonymous_user.png"];
            imageView.layer.masksToBounds = YES;
            imageView.layer.borderColor = [UIColor clearColor].CGColor;
            imageView.layer.borderWidth = 3.0f;
            imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            imageView.layer.shouldRasterize = YES;
            imageView.clipsToBounds = YES;
            
            self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
            self.usernameLabel.text = [PFUser currentUser].username;
            self.usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
            self.usernameLabel.backgroundColor = [UIColor clearColor];
            self.usernameLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
            [self.usernameLabel sizeToFit];
            self.usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [view addSubview:imageView];
            [view addSubview:self.usernameLabel];
            view;
        });
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
//{
//    if (sectionIndex == 0)
//        return nil;
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
//    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
//    label.text = @"Friends Online";
//    label.font = [UIFont systemFontOfSize:15];
//    label.textColor = [UIColor whiteColor];
//    label.backgroundColor = [UIColor clearColor];
//    [label sizeToFit];
//    [view addSubview:label];
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HERENavigationViewController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    if ([PFUser currentUser]) {
        if (indexPath.row == 0) {
            HEREHomeViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeController"];
            navigationController.viewControllers = @[homeViewController];
        } else if (indexPath.row == 1) {
            HEREBeaconsTableViewController *beaconsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconsController"];
            navigationController.viewControllers = @[beaconsTableViewController];
        } else {
            [PFUser logOut];
        }
    }
    else {
        if (indexPath.row == 0) {
            HERESignInViewController *signInController = [self.storyboard instantiateViewControllerWithIdentifier:@"signInController"];
            navigationController.viewControllers = @[signInController];
        } else {
            HERECreateUserViewController *createAccountController = [self.storyboard instantiateViewControllerWithIdentifier:@"createAccountController"];
            navigationController.viewControllers = @[createAccountController];
        }
    }
    
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if ([PFUser currentUser]) {
        return 3;
    }
    else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([PFUser currentUser]) {
        NSArray *titles = @[@"Home", @"Beacons", @"Sign out"];
        cell.textLabel.text = titles[indexPath.row];
    }
    else {
        NSArray *titles = @[@"Sign in", @"Sign up"];
        cell.textLabel.text = titles[indexPath.row];
    }
    
    return cell;
}

@end
