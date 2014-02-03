//
//  DOSFeaturedStatsViewController.m
//  DOSDataAPIExampleApp
//
//  Created by Kevin Ferrell on 2/2/14.
//  Copyright (c) 2014 Acuity Inc. All rights reserved.
//

#import "DOSFeaturedStatsViewController.h"
#import "DOSStatsPageContentViewController.h"
#import "DOSDataAPI.h"
#import "DOSSecretaryTravelDataManager.h"
#import "DOSSecretaryTravelStatsItem.h"

@interface DOSFeaturedStatsViewController ()

@property (nonatomic, strong) NSNumber *totalMilage;
@property (nonatomic, strong) NSString *totalMilageText;

@end

@implementation DOSFeaturedStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Create the data model
    self.pageStatText = [NSArray arrayWithObjects:@"TRIPS FROM D.C. TO LONDON",@"TRIPS AROUND THE EQUATOR OF EARTH",@"TRIPS FROM D.C. TO THE MOON", nil];
    self.pageBackgroundImages = [NSArray arrayWithObjects:@"BigBen",@"Earth",@"Moon", nil];
    self.divisionFactors = [NSArray arrayWithObjects:[NSNumber numberWithFloat:3662.0],[NSNumber numberWithFloat:24901.55],[NSNumber numberWithFloat:238855.0], nil];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeaturedStatsPageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.pageViewController.view.frame.size.height - 76);
    self.pageViewController.view.backgroundColor = [UIColor whiteColor];

    // Add the page control to the main view
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    // Setup the page control display
    self.pageControl.numberOfPages = self.pageStatText.count;
    self.pageControl.currentPage = 0;
    self.pageControl.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.pageControl];
    
    DOSSecretaryTravelDataManager *dataMan = [[DOSSecretaryTravelDataManager alloc] init];
    [dataMan getSecretaryTravelStatsWithSuccess:^(NSArray *response) {
        
        if (response[0]) {
            DOSSecretaryTravelStatsItem *travelStats = response[0];
            NSNumberFormatter* milageFormatter = [[NSNumberFormatter alloc] init];
            [milageFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
            [milageFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
            self.totalMilage = travelStats.milage;
            self.totalMilageText = [milageFormatter stringFromNumber:travelStats.milage];
            
            // Create the initial view
            DOSStatsPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
            NSArray *viewControllers = @[startingViewController];
            [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"API Query failed: %@",error);
    }];
    
}

- (DOSStatsPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageStatText count] == 0) || (index >= [self.pageStatText count])) {
        return nil;
    }
    
    // Create a new view controller and pass data.
    DOSStatsPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeaturedStatsPageContentController"];
    pageContentViewController.totalMilageText = self.totalMilageText;
    pageContentViewController.totalMilage = self.totalMilage;
    pageContentViewController.backgroundImageName = self.pageBackgroundImages[index];
    pageContentViewController.equivalentDistanceText = self.pageStatText[index];
    pageContentViewController.divisionFactor = self.divisionFactors[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DOSStatsPageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DOSStatsPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageStatText count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageStatText count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - Page View Controller delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished) {
        self.pageControl.currentPage = ((DOSStatsPageContentViewController *) pageViewController.viewControllers[0]).pageIndex;
    }
}

@end
