//
//  HEREHomeViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREHomeViewController.h"
#import "Location.h"
#import "HERELocationHelper.h"
#import "APIManager.h"
#import "CoreDataStore.h"

@interface HEREHomeViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation HEREHomeViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.managedObjectContext = [CoreDataStore mainQueueContext];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = sender;
        HEREBeaconsMessagesTableViewController *beaconsMessagesTableVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        beaconsMessagesTableVC.location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kHERELocationClassKey];
    
    request.predicate = nil;

    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kHEREAPILocationNameKey
                                                              ascending:YES
                                                               ]];

    [request setRelationshipKeyPathsForPrefetching:@[@"messages"]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (IBAction)menuBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self showMenu];
}

#pragma mark - UITableView Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = location.name;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRead == %@", [NSNumber numberWithBool:NO]];
    
    NSSet *filteredMessages = [location.messages filteredSetUsingPredicate:predicate];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)[filteredMessages count]];
    
    return cell;
}

@end
