//
//  WFDisplayDemoSystemStringsVC.m
//  DisplayDemo
//
//  Created by Murray Hughes on 10/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

// This VC demostraights what you can do with SystemStrings.
// System strings are global string varibles that are accessible from any page in the configuration
//
// Some system strings can be overriden to customise the built in pages. Eg. Localization
//
// Some system strings can be updated at runtime to present information to the user. Eg Weekly Total
//
// Other system strings are generated on the device and can be used in your pages, eg. Current Time / Date
//
// See each example below for more information.
//

#import "WFDisplayDemoSystemStringsVC.h"

@interface WFDisplayDemoSystemStringsVC ()

@end

@implementation WFDisplayDemoSystemStringsVC

#pragma mark -
#pragma mark Config Loading


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
     self.distanceLabel.text = [NSString stringWithFormat:@"%1.1f",self.distanceSlider.value];
}


- (WFDisplayConfiguration*) displayConfiguration
{
    NSString* configPath = [[NSBundle mainBundle] pathForResource:@"SystemStrings" ofType:@"json"];
    WFDisplayConfiguration* config = [WFDisplayConfiguration instanceWithContentsOfFile:configPath];
    
    return config;
}

- (void) loadConfiguration
{
    [self.displayConnection loadConfiguration:[self displayConfiguration]];
}


- (IBAction)trySettingMondayStringTocuhed:(id)sender
{
    // Example of using  system string in your own config:
    //
    // 'systemStringCalendarDayOfWeekFullMon' cannot be set at runtime because its not declaired in the
    // config file. Its basically a constant string read from the factory config file.
    // In the case of Echo, This is also localized for the selected language.
    // If you wish to set the device to use a custom string, maybe for a language not supported by default
    // You can define it in your config file. See "systemStringCalendarDayOfWeekFullWed' in the config
    
    BOOL result = [self.displayConnection setValue:@"Tuesday" forElementWithKey:@"systemStringCalendarDayOfWeekFullMon"];
    
    // NOTE: It should FAIL.
    [self showAlert:[NSString stringWithFormat:@"Set 'Monday' system string result\n\n%@", result ? @"SUCCESS" : @"FAIL"]];
}



- (IBAction)trySettingWednesdayStringTocuhed:(id)sender
{
    // Example of customizing the system strings used throughout the watch including your own config
    //
    // A custom value 'systemStringCalendarDayOfWeekFullWed' has been set in the config file, it is also set to be constant
    // You should ensure you set constant=1 for all strings that you dont need to edit at runtime, it save valible memory
    //
    // This is a great way to customer the watch to suit your App / Language
    //
    // See factoryConfig.json for a full list of system strings
    //
    // Not all system strings can be customized.

    BOOL result = [self.displayConnection setValue:@"AnotherDay" forElementWithKey:@"systemStringCalendarDayOfWeekFullWed"];
    
    // NOTE: It should FAIL
    [self showAlert:[NSString stringWithFormat:@"Set 'Wednesday' system string result\n\n%@", result ? @"SUCCESS" : @"FAIL"]];
}

- (IBAction)distanceSliderChanged:(id)sender {
    self.distanceLabel.text = [NSString stringWithFormat:@"%1.1f",self.distanceSlider.value];
}

- (IBAction)sendWeeklyValueTouched:(id)sender {

    // Example setting some special weekly values
    //
    // The following 3 system strings allow the app customise the watch screen with a weekly counter. (Echo Only)
    // You can set the Name and Unit as constant strings in the config
    // Set the Value with constant=0 in the config so you can update it at runtime
    //
    // At the end of each workout you can update this value and it will be display on the main Echo watch face.
    //
    // The value will automatically reset to ZERO at the start of each week.
    //
    // systemStringTotalWeeklyVaribleName
    // systemStringTotalWeeklyVaribleValue
    // systemStringTotalWeeklyVaribleUnits
    //
    
     BOOL result = [self.displayConnection setValue: self.distanceLabel.text forElementWithKey:@"systemStringTotalWeeklyVaribleValue"];
    
    [self showAlert:[NSString stringWithFormat:@"Set Weekly Value\n\n%@", result ? @"SUCCESS" : @"FAIL"]];
}


- (void)viewDidUnload {
    [self setDistanceLabel:nil];
    [self setDistanceSlider:nil];
    [super viewDidUnload];
}
@end
