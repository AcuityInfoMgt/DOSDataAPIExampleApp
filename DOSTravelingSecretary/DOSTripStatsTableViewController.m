//
//  DOSTripStatsTableViewController.m
//  DOSTravelingSecretary
//
//  Created by Kevin Ferrell on 1/19/14.
//  Copyright (c) 2014 Acuity Inc.
//

#import "DOSTripStatsTableViewController.h"
#import "DOSDataAPI.h"
#import "DOSSecretaryTravelStatsItem.h"
#import "MBProgressHUD.h"

@interface DOSTripStatsTableViewController ()

@property (nonatomic, strong) NSArray *travelStatTitles;
@property (nonatomic, strong) DOSSecretaryTravelStatsItem *travelStats;

@end

@implementation DOSTripStatsTableViewController

- (void)awakeFromNib
{
    self.title = @"Travel Stats";
    self.navigationItem.title = @"Secretary Kerry's Travel Stats";
    self.tableView.allowsSelection = NO;
    self.travelStatTitles = [NSArray arrayWithObjects:@"HOURS IN FLIGHT",@"MILES FLOWN",@"COUNTRIES VISITED",@"DAYS TRAVELED", nil];
    
    // Load the background for the tableview
    UIImage *backgroundImage = [UIImage imageNamed:@"CloudBackground"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTripStats];
}

- (void)loadTripStats
{
    // Load cached data from disk
    [self loadStatsFromPlist];
    
    DOSSecretaryTravelDataManager *dataMan = [[DOSSecretaryTravelDataManager alloc] init];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [dataMan getSecretaryTravelStatsWithSuccess:^(NSArray *response) {
        
        if (response[0]) {
            self.travelStats = response[0];
        }
        
        [self.tableView reloadData];
        [self saveStatsToPlist];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
    } failure:^(NSError *error) {
        NSLog(@"API Query failed: %@",error);
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Unable to connect to www.state.gov" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        // Reload table to show data saved from plist
        [self.tableView reloadData];
    }];
}

-(void)saveStatsToPlist
{
    // Convert stats object to NSDictionary
    NSMutableDictionary *statsDict = [[NSMutableDictionary alloc] init];
    [statsDict setObject:self.travelStats.flightTimeHours forKey:@"flightTimeHours"];
    [statsDict setObject:self.travelStats.milage forKey:@"milage"];
    [statsDict setObject:self.travelStats.countriesVisited forKey:@"countriesVisited"];
    [statsDict setObject:self.travelStats.travelDays forKey:@"travelDays"];
    
    // Save to disk
    NSString *statsPath = [self getSavedStatsPath];
    [statsDict writeToFile:statsPath atomically:YES];
}

-(void)loadStatsFromPlist
{
    // Save to disk
    NSString *statsPath = [self getSavedStatsPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExist = [manager fileExistsAtPath:statsPath];
    
    if (isExist) {
        NSDictionary *statsDict = [NSDictionary dictionaryWithContentsOfFile:statsPath];
        
        DOSSecretaryTravelStatsItem *stats = [[DOSSecretaryTravelStatsItem alloc] init];
        stats.flightTimeHours = [statsDict objectForKey:@"flightTimeHours"];
        stats.milage = [statsDict objectForKey:@"milage"];
        stats.countriesVisited = [statsDict objectForKey:@"countriesVisited"];
        stats.travelDays = [statsDict objectForKey:@"travelDays"];
        self.travelStats = stats;
        [self.tableView reloadData];
    }
}

-(NSString *)getSavedStatsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *documentDirPath = [documentsDir
                                 stringByAppendingPathComponent:@"TravelStats.plist"];
    return documentDirPath;
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
    
    NSNumberFormatter *hrsFormatter = [[NSNumberFormatter alloc] init];
    [hrsFormatter setMaximumFractionDigits:0];
    [hrsFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    
    NSNumberFormatter* milageFormatter = [[NSNumberFormatter alloc] init];
    [milageFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [milageFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    UILabel *statValue = (UILabel *)[cell viewWithTag:100];
    UILabel *statTitle = (UILabel *)[cell viewWithTag:101];
    
    statTitle.text = self.travelStatTitles[indexPath.row];
    
    if (self.travelStats) {
        switch (indexPath.row) {
            case 0:
                statValue.text = [hrsFormatter stringFromNumber:self.travelStats.flightTimeHours];
                break;
            case 1:
                statValue.text = [milageFormatter stringFromNumber:self.travelStats.milage];
                break;
            case 2:
                statValue.text = [self.travelStats.countriesVisited stringValue];
                break;
            case 3:
                statValue.text = [self.travelStats.travelDays stringValue];
                break;
        }
    }
    
    return cell;
}


@end
