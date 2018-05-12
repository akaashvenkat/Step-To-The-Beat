//
//  WFSensorInformationVC.h
//  DisplayDemo
//
//  Created by Murray Hughes on 8/01/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFSensorImformationVC : UITableViewController

@property (strong, nonatomic) WFSensorConnection* sensorConnection;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *manufactureLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialLabel;
@property (weak, nonatomic) IBOutlet UILabel *hardwareLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryStateLabel;
@end
