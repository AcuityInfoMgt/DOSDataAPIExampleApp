//
//  DOSTripsTableViewController.m
//  DOSTravelingSecretary
//
//  Created by Kevin Ferrell on 12/28/13.
//  Copyright (c) 2013 Acuity Inc. All rights reserved.
//

#import "DOSTripsTableViewController.h"
#import "DOSTripDetailTableViewController.h"
#import "DOSDataAPI.h"
#import "DOSSecretaryTravelItem.h"
#import "DOSSecretaryTravelDetailItem.h"
#import "MBProgressHUD.h"

@interface DOSTripsTableViewController ()

@property (nonatomic, strong) NSArray *tripItems;
@property (nonatomic, strong) NSArray *searchItems;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSNumber *itemsPerPage;
@property (nonatomic, strong) NSNumber *totalItemsInQueryResults;

@end

@implementation DOSTripsTableViewController


- (void)awakeFromNib
{
    self.tripItems = [[NSArray alloc] init];
    self.searchItems = [[NSArray alloc] init];
    self.currentPage = [NSNumber numberWithInt:0];
    self.itemsPerPage = [NSNumber numberWithInt:10];
    self.totalItemsInQueryResults = [NSNumber numberWithInt:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTripDataset];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self loadTripDatasetForSearch:searchString];
    return YES;
}

- (void)loadTripDataset
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:self.itemsPerPage forKey:DOSQueryArgPerPage];
    [options setObject:self.currentPage forKey:DOSQueryArgPage];
    [options setObject:@"id,title,date_start,date_end" forKey:DOSQueryArgFields];
    
    DOSSecretaryTravelDataManager *dataMan = [[DOSSecretaryTravelDataManager alloc] init];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [dataMan getSecretaryTravelWithOptions:options success:^(NSArray *response) {
        
        NSMutableArray *newItemList = [self.tripItems mutableCopy];
        [newItemList addObjectsFromArray:response];
        
        self.tripItems = newItemList;
        self.totalItemsInQueryResults = dataMan.recordCountReturned;
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        
    } failure:^(NSError *error) {
        NSLog(@"API Query failed: %@",error);
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    }];
}

- (void)loadTripDatasetForSearch:(NSString *)searchString
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:[NSNumber numberWithInt:100] forKey:DOSQueryArgPerPage];
    [options setObject:[NSNumber numberWithInt:0] forKey:DOSQueryArgPage];
    [options setObject:@"id,title,date_start,date_end" forKey:DOSQueryArgFields];
    [options setObject:searchString forKey:DOSQueryArgTerms];
    
    DOSSecretaryTravelDataManager *dataMan = [[DOSSecretaryTravelDataManager alloc] init];
    [dataMan getSecretaryTravelWithOptions:options success:^(NSArray *response) {
        
        self.searchItems = response;
        [self.searchDisplayController.searchResultsTableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"API Query failed: %@",error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        // If there are more items than currently displayed, add a cell for the "Load More..." indicator
        if (self.tripItems.count < [self.totalItemsInQueryResults intValue]) {
            return self.tripItems.count + 1;
        }
        else {
            return self.tripItems.count;
        }
    }
    else
    {
        return self.searchItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TripItemCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.tableView) {
        if (indexPath.row < self.tripItems.count) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            
            DOSSecretaryTravelItem *item = self.tripItems[indexPath.row];
            
            // Attempt to remove redundant lead in text
            NSString *newTitle = [item.title stringByReplacingOccurrencesOfString:@"Details of Travel to the " withString:@""];
            newTitle = [newTitle stringByReplacingOccurrencesOfString:@"Details of Travel to " withString:@""];
            
            cell.textLabel.text = newTitle;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:item.dateStart],[dateFormatter stringFromDate:item.dateEnd]];
        }
        else {
            cell.textLabel.text = @"Load More...";
            cell.detailTextLabel.text = @"";
        }
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        DOSSecretaryTravelItem *item = self.searchItems[indexPath.row];
        
        // Attempt to remove redundant lead in text
        NSString *newTitle = [item.title stringByReplacingOccurrencesOfString:@"Details of Travel to the " withString:@""];
        newTitle = [newTitle stringByReplacingOccurrencesOfString:@"Details of Travel to " withString:@""];
        
        cell.textLabel.text = newTitle;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:item.dateStart],[dateFormatter stringFromDate:item.dateEnd]];
    }
    
    return cell;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
    if (selectedRowIndex.row < self.tripItems.count) {
        return YES;
    }
    else {
        self.currentPage = [NSNumber numberWithInt:[self.currentPage intValue] + 1];
        [self loadTripDataset];
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowSelectedTripDetail"]) {
        
        if (self.searchItems.count > 0) {
            // Navigate to search result detail
            NSIndexPath *selectedRowIndex = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            DOSTripDetailTableViewController *detailViewController = [segue destinationViewController];
            detailViewController.parentTravelItem = self.searchItems[selectedRowIndex.row];
        }
        else {
            // Navigate to full result detail
            NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
            DOSTripDetailTableViewController *detailViewController = [segue destinationViewController];
            detailViewController.parentTravelItem = self.tripItems[selectedRowIndex.row];
        }
        
        
    }
}



@end
