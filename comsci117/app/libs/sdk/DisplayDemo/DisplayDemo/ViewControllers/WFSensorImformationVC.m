//
//  WFSensorInformationVC.m
//  DisplayDemo
//
//  Created by Murray Hughes on 8/01/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFSensorImformationVC.h"

@interface WFSensorImformationVC ()

@end

@implementation WFSensorImformationVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateSensorInformation];

}

- (void) updateSensorInformation
{
    
    WFSensorData* sensorData = [self.sensorConnection getData];
    WFBTLECommonData* commonData = nil;
    
    if([sensorData respondsToSelector:@selector(btleCommonData)])
    {
        commonData = [sensorData performSelector:@selector(btleCommonData)];
    }
    
    if(commonData && [self.sensorConnection isConnected])
    {
        self.nameLabel.text = commonData.deviceName;
        self.batteryLabel.text = [NSString stringWithFormat:@"%d", commonData.batteryLevel];
        self.versionLabel.text = commonData.firmwareRevision;
        self.manufactureLabel.text = commonData.manufacturerName;
        self.modelLabel.text = commonData.modelNumber;
        self.serialLabel.text = commonData.serialNumber;
        self.hardwareLabel.text = commonData.hardwareRevision;
        self.softwareLabel.text = commonData.softwareRevision;
        
    }
    else
    {
        self.nameLabel.text = @"N/A";
        self.batteryLabel.text = @"N/A";
        self.versionLabel.text = @"N/A";
        self.manufactureLabel.text = @"N/A";
        self.modelLabel.text = @"N/A";
        self.serialLabel.text = @"N/A";
        self.hardwareLabel.text = @"N/A";
        self.softwareLabel.text = @"N/A";
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setBatteryLabel:nil];
    [self setNameLabel:nil];
    [self setVersionLabel:nil];
    [self setManufactureLabel:nil];
    [self setModelLabel:nil];
    [self setSerialLabel:nil];
    [self setHardwareLabel:nil];
    [self setSoftwareLabel:nil];
    [self setBatteryStateLabel:nil];
    [super viewDidUnload];
}
@end
