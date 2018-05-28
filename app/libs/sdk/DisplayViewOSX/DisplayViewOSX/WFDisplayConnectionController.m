//
//  WFDisplayConnectionController.m
//  DisplayViewOSX
//
//  Created by Murray Hughes on 9/07/2014.
//  Copyright (c) 2014 Wahoo Fitness. All rights reserved.
//

#import "WFDisplayConnectionController.h"

@interface WFDisplayConnectionController () <WFDiscoveryManagerDelegate, WFSensorConnectionDelegate, WFDisplayConnectionDelegate>

@property (nonatomic, retain) WFDiscoveryManager* discoveryManager;

@end



@implementation WFDisplayConnectionController

- (void) startDiscovery
{
    
    self.discoveredDisplays = [NSMutableArray new];
    
    self.discoveryManager = [WFDiscoveryManager new];
    self.discoveryManager.delegate = self;
    [self.discoveryManager discoverSensorTypes:@[@(WF_SENSORTYPE_DISPLAY)] onNetwork:WF_NETWORKTYPE_BTLE];
    
}

- (void) connectDisplayWithDeviceInfo:(WFDeviceInformation*) deviceInfo
{
    if(self.sensorConnection) {
        [self.sensorConnection disconnect:YES];
        self.sensorConnection = nil;
    }
    
    self.sensorConnection = (WFDisplayConnection*)[[WFHardwareConnector sharedConnector] requestSensorConnection:[deviceInfo connectionParamsForSensorType:WF_SENSORTYPE_DISPLAY]];
    self.sensorConnection.delegate = self;
    self.sensorConnection.displayConnectionDelegate = self;
    
    
    
}



#pragma mark - 
#pragma WFDiscoveryManagerDelegate

-(void) discoveryManager:(WFDiscoveryManager *)discoveryManager didDiscoverDevice:(WFDeviceInformation *)discoveryDeviceInfo
{
    if(![self.discoveredDisplays containsObject:discoveryDeviceInfo]) {
        [self.discoveredDisplays addObject:discoveryDeviceInfo];
    }
}

- (void) discoveryManager:(WFDiscoveryManager *)discoveryManager didLooseDevice:(WFDeviceInformation *)discoveryDeviceInfo
{
    [self.discoveredDisplays removeObject:discoveryDeviceInfo];
}

#pragma mark -
#pragma WFSensorConnectionDelegate

- (void)connection:(WFSensorConnection*)connectionInfo stateChanged:(WFSensorConnectionStatus_t)connState
{
    NSLog(@"connection:stateChaned: %d",connState);
}


#pragma mark -
#pragma mark WFDisplayConnectionDelegate Implementation

- (WFDisplayConfiguration *)configurationForDisplayConnection:(WFDisplayConnection *)connection
{
    NSLog(@"configurationForDisplayConnection:");
    return nil;
}

- (void) displayConnectionDidStartConfigurationLoading:(WFDisplayConnection*) connection
{
    NSLog(@"displayConnectionDidStartConfigurationLoading:");
}

- (void) displayConnection:(WFDisplayConnection*) connection didProgressConfigurationLoading:(float) progress
{
    NSLog(@"displayConnection:didProgressConfigurationLoading: %1.1f", progress*100.0);
}

- (void) displayConnectionDidFinishConfigurationLoading:(WFDisplayConnection*) connection
{
    NSLog(@"displayConnectionDidFinishConfigurationLoading:");
}

- (void) displayConnection:(WFDisplayConnection*) connection didFailConfigurationLoadingWithError:(NSError*) error
{
    NSLog(@"displayConnection:didFailConfigurationLoadingWithError");
}

- (void) displayConnection:(WFDisplayConnection *)connection didButtonDown:(int)buttonIndex
{
    NSLog(@"displayConnection:didButtonDown:%d", buttonIndex);
}

- (void) displayConnection:(WFDisplayConnection *)connection didButtonUp:(int)buttonIndex
{
    NSLog(@"displayConnection:didButtonUp:%d", buttonIndex);
}

- (void)displayConnection:(WFDisplayConnection *)connection visablePageChanged:(NSString *)visablePageKey
{
    NSLog(@"displayConnection:visablePageChanged:%@", visablePageKey);
}

- (void) displayConnection:(WFDisplayConnection*) connection didRespondShouldSleepOnDisconnect:(BOOL) sleepOnDisconnect error:(NSError*) error
{
    NSLog(@"displayConnection:didRespondShouldSleepOnDisconnect:%d error:%@", sleepOnDisconnect, error ? error : @"nill");
    
}




@end
