//
//  WFDisplayDemoSystemStringsVC.h
//  DisplayDemo
//
//  Created by Murray Hughes on 10/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFDisplayDemoStandard.h"

@interface WFDisplayDemoSystemStringsVC : WFDisplayDemoStandard

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;


- (IBAction)trySettingMondayStringTocuhed:(id)sender;
- (IBAction)trySettingWednesdayStringTocuhed:(id)sender;

- (IBAction)distanceSliderChanged:(id)sender;
- (IBAction)sendWeeklyValueTouched:(id)sender;

@end
