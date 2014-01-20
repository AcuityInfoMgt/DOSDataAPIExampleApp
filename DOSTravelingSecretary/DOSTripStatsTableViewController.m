//
//  DOSTripStatsTableViewController.m
//  DOSTravelingSecretary
//
//  Created by Kevin Ferrell on 1/19/14.
//  Copyright (c) 2014 Acuity Inc. All rights reserved.
//

#import "DOSTripStatsTableViewController.h"
#import "DOSDataAPI.h"
#import "DOSSecretaryTravelStatsItem.h"

@interface DOSTripStatsTableViewController ()

@property (nonatomic, strong) NSArray *travelStatTitles;
@property (nonatomic, strong) DOSSecretaryTravelStatsItem *travelStats;

@end

@implementation DOSTripStatsTableViewController

- (void)awakeFromNib
{
    self.title = @"Travel Stats";
    self.tableView.allowsSelection = NO;
    self.travelStatTitles = [NSArray arrayWithObjects:@"Hrs In Flight",@"Milage",@"Countries Visited",@"Travel Days", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTripStats];
    
}

- (void)loadTripStats
{
    DOSSecretaryTravelDataManager *dataMan = [[DOSSecretaryTravelDataManager alloc] init];
    [dataMan getSecretaryTravelStatsWithSuccess:^(NSArray *response) {
        
        if (response[0]) {
            self.travelStats = response[0];
        }
        
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
    return self.travelStatTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TripStatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.travelStatTitles[indexPath.row];
    
    NSNumberFormatter *hrsFormatter = [[NSNumberFormatter alloc] init];
    [hrsFormatter setMaximumFractionDigits:0];
    [hrsFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    
    NSNumberFormatter* milageFormatter = [[NSNumberFormatter alloc] init];
    [milageFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [milageFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    
    if (self.travelStats) {
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = [hrsFormatter stringFromNumber:self.travelStats.flightTimeHours];
                break;
            case 1:
                cell.detailTextLabel.text = [milageFormatter stringFromNumber:self.travelStats.milage];
                break;
            case 2:
                cell.detailTextLabel.text = [self.travelStats.countriesVisited stringValue];
                break;
            case 3:
                cell.detailTextLabel.text = [self.travelStats.travelDays stringValue];
                break;
        }
    }
    
    return cell;
}


@end
