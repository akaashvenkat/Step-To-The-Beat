//
//  WFDisplayPageViewSelectVC.m
//  DisplayDemo
//
//  Created by Murray Hughes on 30/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFDisplayPageViewSelectTVC.h"
#import "WFDisplayPageVC.h"
#import <WFConnector/WFDisplayPageView.h>
#import "WFDisplayConfiguration+Timex.h"

@interface WFDisplayPageViewSelectTVC ()

@end

@implementation WFDisplayPageViewSelectTVC

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Types" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"EchoDisplayViewSegue"])
    {
        NSString* configPath = [[NSBundle mainBundle] pathForResource:@"StandardConfig" ofType:@"json"];
        
        WFDisplayPageVC* pageVC = segue.destinationViewController;
        pageVC.sensorSubType = WF_SENSOR_SUBTYPE_DISPLAY_ECHO;
        pageVC.displayConfiguration = [WFDisplayConfiguration instanceWithContentsOfFile:configPath];
        
    }
    else if([segue.identifier isEqualToString:@"TimexDisplayViewSegue"])
    {
        NSString* configPath = [[NSBundle mainBundle] pathForResource:@"pageTemplates-timex" ofType:@"json"];
        
        WFDisplayPageVC* pageVC = segue.destinationViewController;
        pageVC.sensorSubType = WF_SENSOR_SUBTYPE_DISPLAY_TIMEX_RUN_X50;
        pageVC.displayConfiguration = [WFDisplayConfiguration timeConfigurationWithContentsOfFile:configPath];

    }
    else if([segue.identifier isEqualToString:@"RFLKTDisplayViewSegue"])
    {
        NSString* configPath = [[NSBundle mainBundle] pathForResource:@"StandardConfig" ofType:@"json"];
        
        WFDisplayPageVC* pageVC = segue.destinationViewController;
        pageVC.sensorSubType = WF_SENSOR_SUBTYPE_DISPLAY_RFLKT;
        pageVC.displayConfiguration = [WFDisplayConfiguration instanceWithContentsOfFile:configPath];

    }
    else if([segue.identifier isEqualToString:@"CasioDisplayViewSegue"])
    {
        NSString* configPath = [[NSBundle mainBundle] pathForResource:@"Casio-STB-1000" ofType:@"json"];
        
        WFDisplayPageVC* pageVC = segue.destinationViewController;
        pageVC.sensorSubType = WF_SENSOR_SUBTYPE_DISPLAY_CASIO_TYPE1;
        pageVC.displayConfiguration = [WFDisplayConfiguration instanceWithContentsOfFile:configPath];
        
        UILabel* labe;
        
        labe.textAlignment = NSTextAlignmentRight;
        
    }
    
    
}






@end
