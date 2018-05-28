//
//  WFDisplayConnectionController.h
//  DisplayViewOSX
//
//  Created by Murray Hughes on 9/07/2014.
//  Copyright (c) 2014 Wahoo Fitness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WFConnector/WFConnector.h>

@interface WFDisplayConnectionController : NSObject

@property (nonatomic, retain) NSMutableArray* discoveredDisplays;

@property (nonatomic, retain) WFDisplayConnection* sensorConnection;

- (void) startDiscovery;

- (void) connectDisplayWithDeviceInfo:(WFDeviceInformation*) deviceInfo;


@end
