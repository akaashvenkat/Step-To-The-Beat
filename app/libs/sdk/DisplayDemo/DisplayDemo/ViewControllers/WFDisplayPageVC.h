//
//  WFDisplayPageViewController.h
//  DisplayDemo
//
//  Created by Murray Hughes on 30/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WFConnector/WFDisplayPageView.h>

@interface WFDisplayPageVC : UIViewController

@property (nonatomic, retain) WFDisplayConfiguration* displayConfiguration;

@property (nonatomic, assign) WFSensorSubType_t sensorSubType;

@property (weak, nonatomic) IBOutlet WFDisplayPageView *displayPageView;

- (IBAction)previousPageButtonTouched:(id)sender;
- (IBAction)nextPageButtonTouched:(id)sender;

@end
