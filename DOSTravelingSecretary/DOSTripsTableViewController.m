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

@interface DOSTripsTableViewController ()

@property (nonatomic, strong) NSArray *tripItems;

@end

@implementation DOSTripsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    DOSSecretaryTravelDataManager *dataMan = [[DOSSecretaryTravelDataManager alloc] init];
    [dataMan getSecretaryTravelWithOptions:nil success:^(NSArray *response) {
        
        self.tripItems = response;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"API Query failed: %@",error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tripItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TripItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    DOSSecretaryTravelItem *item = self.tripItems[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",item.dateStart,item.dateEnd];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowSelectedTripDetail"]) {
        
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        DOSTripDetailTableViewController *detailViewController = [segue destinationViewController];
        detailViewController.parentTravelItem = self.tripItems[selectedRowIndex.row];
        
    }
}


@end
