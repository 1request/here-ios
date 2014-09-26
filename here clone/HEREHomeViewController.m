//
//  HEREHomeViewController.m
//  here clone
//
//  Created by Joseph Cheung on 6/8/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HEREHomeViewController.h"
#import "Location.h"
#import "Message.h"
#import "HERELocationHelper.h"
#import "APIManager.h"
#import "CoreDataStore.h"
#import "LocationTableViewCell.h"

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
    
    NSSortDescriptor *lastMessageDateDescriptor = [NSSortDescriptor sortDescriptorWithKey:kHERELocationLastMessageDateKey
                                                                                ascending:NO];
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:kHERELocationNameKey
                                                                     ascending:YES];
    
    request.sortDescriptors = @[lastMessageDateDescriptor, nameDescriptor];

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
    LocationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    
//    if (cell == nil) {
//        cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupCell"];
//    }
    
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.locationNameLabel.text = location.name;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRead == %@", [NSNumber numberWithBool:NO]];
    
    NSSet *filteredMessages = [location.messages filteredSetUsingPredicate:predicate];
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    if ([filteredMessages count] > 0) {
        cell.unreadMessageCountLabel.text = [NSString stringWithFormat:@"%d", (int)[filteredMessages count]];
        cell.unreadMessageCountView.hidden = NO;
    }
    UIImage *image = nil;
    
    if (!location.thumbnailURL) {
        image = [UIImage imageNamed:@"here_thumb.png"];
    }
    else {
        NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSString *path = [[[documentDirectories firstObject] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-thumb.png", location.locationId]] absoluteString];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
            image = [UIImage imageWithData:data];
        }
    }
    
    CGSize size = cell.thumbnailImageView.frame.size;
    
    cell.thumbnailImageView.image = [self imageWithImage:image scaledToSize:size];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    
    NSArray *sortedMessages = [location.messages sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    Message *lastMessage = [sortedMessages lastObject];
    
    if (lastMessage) {
        cell.lastMessageLabel.text = (lastMessage.text) ? lastMessage.text : @"[Voice]";
    }
    else {
        cell.lastMessageLabel.text = @"";
    }
    
    
    return cell;
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
