//
//  DOSTripDetailTableViewController.m
//  DOSTravelingSecretary
//
//  Created by Kevin Ferrell on 12/28/13.
//  Copyright (c) 2013 Acuity Inc. All rights reserved.
//

#import "DOSTripDetailTableViewController.h"
#import "EGYModalWebViewController.h"

@interface DOSTripDetailTableViewController ()

@property (nonatomic, strong) NSArray *travelDetailItems;

@end

@implementation DOSTripDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

// Override parentTravelItem setter
- (void)setParentTravelItem:(DOSSecretaryTravelItem *)parentTravelItem
{
    _parentTravelItem = parentTravelItem;
    
    // Load travel details
    DOSSecretaryTravelDataManager *dataMan = [[DOSSecretaryTravelDataManager alloc] init];
    [dataMan getSecretaryTravelDetailForItem:[NSString stringWithFormat:@"%@",parentTravelItem.itemId] withOptions:nil success:^(NSArray *response){
        
        self.travelDetailItems = response;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"API Query failed: %@",error);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
    // Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.title = self.parentTravelItem.title;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.travelDetailItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TravelDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    DOSSecretaryTravelDetailItem *item = self.travelDetailItems[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.date;
    
    return cell;
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOSSecretaryTravelDetailItem *selectedItem = self.travelDetailItems[indexPath.row];
    
    EGYModalWebViewController *webview = [[EGYModalWebViewController alloc] initWithAddress:selectedItem.mobileUrl];
    [self presentViewController:webview animated:YES completion:NULL];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
