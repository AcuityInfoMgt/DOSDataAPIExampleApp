//
//  DOSTripDetailTableViewController.h
//  DOSTravelingSecretary
//
//  Created by Kevin Ferrell on 12/28/13.
//  Copyright (c) 2014 Acuity Inc.
//

#import <UIKit/UIKit.h>
#import "DOSDataAPI.h"
#import "DOSSecretaryTravelItem.h"

@interface DOSTripDetailTableViewController : UITableViewController

@property (nonatomic, strong) DOSSecretaryTravelItem *parentTravelItem;

@end
