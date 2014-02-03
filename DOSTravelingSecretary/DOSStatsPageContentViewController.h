//
//  DOSStatsPageContentViewController.h
//  DOSDataAPIExampleApp
//
//  Created by Kevin Ferrell on 2/2/14.
//  Copyright (c) 2014 Acuity Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOSStatsPageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceTraveledLabel;
@property (weak, nonatomic) IBOutlet UILabel *equivalentTimesLabel;
@property (weak, nonatomic) IBOutlet UILabel *equivalentDistanceLabel;
@property (weak, nonatomic) IBOutlet UIView *textBackgroundColor;


@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic, strong) NSString *totalMilageText;
@property (nonatomic, strong) NSNumber *totalMilage;
@property (nonatomic, strong) NSString *equivalentDistanceText;
@property (nonatomic, strong) NSString *backgroundImageName;
@property (nonatomic, strong) NSNumber *divisionFactor;

@end
