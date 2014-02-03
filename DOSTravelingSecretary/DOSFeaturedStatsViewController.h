//
//  DOSFeaturedStatsViewController.h
//  DOSDataAPIExampleApp
//
//  Created by Kevin Ferrell on 2/2/14.
//  Copyright (c) 2014 Acuity Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOSFeaturedStatsViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageStatText;
@property (strong, nonatomic) NSArray *pageStatValues;
@property (strong, nonatomic) NSArray *pageBackgroundImages;
@property (strong, nonatomic) NSArray *divisionFactors;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
