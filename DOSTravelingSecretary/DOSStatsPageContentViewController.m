//
//  DOSStatsPageContentViewController.m
//  DOSDataAPIExampleApp
//
//  Created by Kevin Ferrell on 2/2/14.
//  Copyright (c) 2014 Acuity Inc. All rights reserved.
//

#import "DOSStatsPageContentViewController.h"

@interface DOSStatsPageContentViewController ()

@property (nonatomic, strong) NSNumberFormatter *distanceFormatter;
@property (nonatomic) float targetDistance;
@property (nonatomic) float currentlyDisplayedDistance;
@property (nonatomic, strong) NSTimer *eventTimer;

@end

@implementation DOSStatsPageContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.distanceTraveledLabel.text = self.totalMilageText;
    self.backgroundImageView.image = [UIImage imageNamed:self.backgroundImageName];
    self.equivalentDistanceLabel.text = self.equivalentDistanceText;
    
    // Calculate equilivent distance
    float equivalentDistance = [self.totalMilage floatValue] / [self.divisionFactor floatValue];
    self.targetDistance = equivalentDistance;
    self.currentlyDisplayedDistance = 0.0;
    
    // Set the equlivent distance
    NSNumberFormatter *distanceFormatter = [[NSNumberFormatter alloc] init];
    [distanceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [distanceFormatter setFormatWidth:2];
    [distanceFormatter setMinimumFractionDigits:2];
    [distanceFormatter setMaximumFractionDigits:2];
    self.distanceFormatter = distanceFormatter;
    
    // Detect screen size
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float darkBackgroundAlpha = 0.0;
    if (screenBounds.size.height == 480) {
        darkBackgroundAlpha = 0.70;
    }
    
    // Set the background color
    switch (self.pageIndex) {
        case 0:
            self.textBackgroundColor.alpha = 0.70;
            break;
        case 1:
            self.textBackgroundColor.alpha = darkBackgroundAlpha;
            break;
        case 2:
            self.textBackgroundColor.alpha = darkBackgroundAlpha;
            break;
        default:
            break;
    }
    
    self.equivalentTimesLabel.text = [distanceFormatter stringFromNumber:[NSNumber numberWithFloat:0.0]];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Set the count rate
    float speedFactor = 200.0;
    switch (self.pageIndex) {
        case 0:
            speedFactor = 2000.0;
            break;
        case 1:
            speedFactor = 200.0;
            break;
        case 2:
            speedFactor = 100.0;
            break;
        default:
            break;
    }
    
    NSTimeInterval tiCallRate = 1.0 / speedFactor;
    self.eventTimer = [NSTimer scheduledTimerWithTimeInterval:tiCallRate
                                                       target:self
                                                     selector:@selector(incrementDistance)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)incrementDistance
{
    if (self.targetDistance > self.currentlyDisplayedDistance) {
        self.currentlyDisplayedDistance += 0.01;
        
        // Increment DC to London faster since the metric is larger
        if (self.pageIndex == 0) {
            self.currentlyDisplayedDistance += 0.04;
        }
    }
    else
    {
        [self.eventTimer invalidate];
        self.eventTimer = nil;
    }
    
    self.equivalentTimesLabel.text = [self.distanceFormatter stringFromNumber:[NSNumber numberWithFloat:self.currentlyDisplayedDistance]];
}

@end
