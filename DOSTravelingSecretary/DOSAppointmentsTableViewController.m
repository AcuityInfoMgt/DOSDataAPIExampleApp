//
//  DOSAppoointmentsTableViewController.m
//  DOSTravelingSecretary
//
//  Created by Kevin Ferrell on 1/20/14.
//  Copyright (c) 2014 Acuity Inc.
//

#import "DOSAppointmentsTableViewController.h"
#import "DOSDataAPI.h"
#import "DOSSecretaryAppointmentManager.h"
#import "DOSSecretaryAppointmentItem.h"
#import "EGYModalWebViewController.h"

@interface DOSAppointmentsTableViewController ()

@property (nonatomic, strong) NSArray *appointmentItems;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSNumber *itemsPerPage;
@property (nonatomic, strong) NSNumber *totalItemsInQueryResults;


@end

@implementation DOSAppointmentsTableViewController

- (void)awakeFromNib
{
    self.title = @"Appointments";
    self.appointmentItems = [[NSArray alloc] init];
    self.currentPage = [NSNumber numberWithInt:0];
    self.itemsPerPage = [NSNumber numberWithInt:25];
    self.totalItemsInQueryResults = [NSNumber numberWithInt:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadAppointmentDataset];
}

- (void)loadAppointmentDataset
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:self.itemsPerPage forKey:DOSQueryArgPerPage];
    [options setObject:self.currentPage forKey:DOSQueryArgPage];
    [options setObject:@"id,title,date,mobile_url" forKey:DOSQueryArgFields];
    
    DOSSecretaryAppointmentManager *dataMan = [[DOSSecretaryAppointmentManager alloc] init];
    [dataMan getSecretaryAppointmentsWithOptions:options success:^(NSArray *response) {
        
        NSMutableArray *newItemList = [self.appointmentItems mutableCopy];
        [newItemList addObjectsFromArray:response];
        
        self.appointmentItems = newItemList;
        self.totalItemsInQueryResults = dataMan.recordCountReturned;
        [self.tableView reloadData];
        
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
    // If there are more items than currently displayed, add a cell for the "Load More..." indicator
    if (self.appointmentItems.count < [self.totalItemsInQueryResults intValue]) {
        return self.appointmentItems.count + 1;
    }
    else {
        return self.appointmentItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AppointmentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row < self.appointmentItems.count) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        DOSSecretaryAppointmentItem *item = self.appointmentItems[indexPath.row];

        cell.textLabel.text = item.title;
    }
    else {
        cell.textLabel.text = @"Load More...";
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.appointmentItems.count) {
        // Load detail
        DOSSecretaryAppointmentItem *selectedItem = self.appointmentItems[indexPath.row];
        
        EGYModalWebViewController *webview = [[EGYModalWebViewController alloc] initWithAddress:selectedItem.mobileUrl];
        [self presentViewController:webview animated:YES completion:NULL];
    }
    else {
        // Load more records
        self.currentPage = [NSNumber numberWithInt:[self.currentPage intValue] + 1];
        [self loadAppointmentDataset];
    }
}

@end
