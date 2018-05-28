//
//  WFSensorConnectionVC.h
//  DisplayDemo
//
//  Created by Murray Hughes on 29/12/12.
//  Copyright (c) 2012 Wahoo Fitness. All rights reserved.
//

// This is a base connection class that handles the basic wahoo connection management, it contains no specific sensor code

#import <UIKit/UIKit.h>


@interface WFSensorConnectionVC : UITableViewController  <WFSensorConnectionDelegate>

@property (strong, nonatomic) WFSensorConnection* sensorConnection;

@property (weak, nonatomic) IBOutlet UISwitch *wildcardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *proxSwitch;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@property (assign, nonatomic) WFSensorType_t sensorType;

- (IBAction)connectionButtonTouched:(id)sender;


- (void) sensorDidConnect:(WFSensorConnection*) connectionInfo;


@end
