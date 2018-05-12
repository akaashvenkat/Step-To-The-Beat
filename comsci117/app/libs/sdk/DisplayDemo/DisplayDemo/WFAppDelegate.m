//
//  WFAppDelegate.m
//  RFLKDemo
//
//  Created by Murray Hughes on 7/09/12.
//  Copyright (c) 2012 Wahoo Fitness. All rights reserved.
//

#import "WFAppDelegate.h"


@implementation WFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //Setup the Wahoo Hardware Connector
    [[WFHardwareConnector sharedConnector] enableBTLE:YES];
    [WFHardwareConnector sharedConnector].delegate = self;
    [WFHardwareConnector sharedConnector].sampleRate = 0.5;  // sample rate 500 ms, or 2 Hz.
    [[WFHardwareConnector sharedConnector] setSampleTimerDataCheck:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark -
#pragma mark HardwareConnectorDelegate Implementation

//--------------------------------------------------------------------------------
- (void)hardwareConnector:(WFHardwareConnector*)hwConnector connectedSensor:(WFSensorConnection*)connectionInfo
{
    NSLog(@"hardwareConnector:connectedSensor: %@", connectionInfo);
}

//--------------------------------------------------------------------------------
- (void)hardwareConnector:(WFHardwareConnector*)hwConnector didDiscoverDevices:(NSSet*)connectionParams searchCompleted:(BOOL)bCompleted
{
    NSLog(@"hardwareConnector:didDiscoverDevices:searchCompleted: %d \n%@", bCompleted, connectionParams);
}

//--------------------------------------------------------------------------------
- (void)hardwareConnector:(WFHardwareConnector*)hwConnector disconnectedSensor:(WFSensorConnection*)connectionInfo
{
    NSLog(@"hardwareConnector:disconnectedSensor: %@", connectionInfo);
}

//--------------------------------------------------------------------------------
- (void)hardwareConnector:(WFHardwareConnector*)hwConnector stateChanged:(WFHardwareConnectorState_t)currentState
{
    NSLog(@"hardwareConnector:stateChanged: 0x%04X", currentState);
}

//--------------------------------------------------------------------------------
- (void)hardwareConnectorHasData
{

}

//--------------------------------------------------------------------------------
- (void) hardwareConnector:(WFHardwareConnector*)hwConnector hasFirmwareUpdateAvailableForConnection:(WFSensorConnection*)connectionInfo
                  required:(BOOL)required
    withWahooUtilityAppURL:(NSURL *)wahooUtilityAppURL
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              wahooUtilityAppURL, @"wahooUtilityAppURL",
                              [NSNumber numberWithBool:required], @"firmwareUpdateRequired",
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:WF_NOTIFICATION_FIRMWARE_UPDATE_AVAILABLE object:nil userInfo:userInfo];
}


@end
