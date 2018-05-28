//
//  WFDisplayConnectionVC.h
//  DisplayDemo
//
//  Created by Murray Hughes on 4/01/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFSensorConnectionVC.h"

@interface WFDisplayConnectionVC : WFSensorConnectionVC <WFDisplayConnectionDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *sleepOnDisconnectSwitch;

- (IBAction)sleepOnDisconnectChanged:(id)sender;

@end
