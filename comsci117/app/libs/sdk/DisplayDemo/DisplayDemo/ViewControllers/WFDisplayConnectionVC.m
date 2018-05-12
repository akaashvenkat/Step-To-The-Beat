//
//  WFDisplayConnectionVC.m
//  DisplayDemo
//
//  Created by Murray Hughes on 4/01/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFDisplayConnectionVC.h"

@interface UIViewController (_setDisplayConnection_)

@property (strong, nonatomic) WFDisplayConnection* displayConnection;

@end

@interface WFDisplayConnectionVC ()

@property (nonatomic, strong) NSURL *wahooUtilityAppURL;

@end

@implementation WFDisplayConnectionVC

- (void)viewDidLoad
{
    self.sensorType = WF_SENSORTYPE_DISPLAY;
    
    [[WFHardwareConnector sharedConnector].settings setApplicationName:@"CYCLE"
                                                             forSensor:WF_SENSORTYPE_DISPLAY
                                                               subType:WF_SENSOR_SUBTYPE_DISPLAY_CASIO_TYPE1];
    
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firmwareUpdateAvailable:) name:WF_NOTIFICATION_FIRMWARE_UPDATE_AVAILABLE object:nil];
}

- (void)viewDidUnload
{
    [self setSleepOnDisconnectSwitch:nil];
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.sensorConnection isKindOfClass:[WFDisplayConnection class]])
    {
        ((WFDisplayConnection*)self.sensorConnection).displayConnectionDelegate = self;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if([[segue destinationViewController] respondsToSelector:@selector(setDisplayConnection:)])
    {
        [segue.destinationViewController performSelector:@selector(setDisplayConnection:) withObject:self.sensorConnection];
    }
}

#pragma mark -
#pragma mark Property Overrides

- (void)setSensorConnection:(WFSensorConnection *)sensorConnection
{
    [super setSensorConnection:sensorConnection];
    
    if([sensorConnection isKindOfClass:[WFDisplayConnection class]])
    {
        ((WFDisplayConnection*)sensorConnection).displayConnectionDelegate = self;
    }
}

- (void) sensorDidConnect:(WFSensorConnection*) connectionInfo
{
    [((WFDisplayConnection*)connectionInfo) setShouldSleepOnDisconnect:self.sleepOnDisconnectSwitch.on];
    
    [super sensorDidConnect:connectionInfo];
}

#pragma mark -
#pragma mark WFDisplayConnectionDelegate Implementation

- (WFDisplayConfiguration *)configurationForDisplayConnection:(WFDisplayConnection *)connection
{
    NSLog(@"configurationForDisplayConnection:");

    NSString* configPath = nil;
    
    if(connection.sensorSubType == WF_SENSOR_SUBTYPE_DISPLAY_CASIO_TYPE1)
    {
        configPath = [[NSBundle mainBundle] pathForResource:@"AppName-Casio" ofType:@"json"];
    }
    else
    {
        configPath = [[NSBundle mainBundle] pathForResource:@"AppName" ofType:@"json"];
    }
    
    WFDisplayConfiguration* displayConfig = [WFDisplayConfiguration instanceWithContentsOfFile:configPath];
    
    return displayConfig;
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
    
    [(WFDisplayConnection*)self.sensorConnection setValue:@"Distance" forElementWithKey:@"systemStringTotalWeeklyVariableName"];
    [(WFDisplayConnection*)self.sensorConnection setValue:@"167.0" forElementWithKey:@"systemStringTotalWeeklyVariableValue"];
    
    NSString* appDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    [connection setValue:appDisplayName forElementWithKey:@"appName"];
}

- (void) displayConnection:(WFDisplayConnection*) connection didFailConfigurationLoadingWithError:(NSError*) error
{
    NSLog(@"displayConnection:didFailConfigurationLoadingWithError: %@",error);
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


#pragma mark - WFHardwareConnector notification from app delegate
//--------------------------------------------------------------------------------
- (void)firmwareUpdateAvailable:(NSNotification*)notification
{    
    NSLog(@"in firmwareUpdateAvailable notification received");
    NSDictionary* info = notification.userInfo;
    if ( info != nil )
    {
        // parse the user info.
        self.wahooUtilityAppURL = (NSURL *)[info objectForKey:@"wahooUtilityAppURL"];
        NSNumber *requiredNumber = (NSNumber *)[info objectForKey:@"firmwareUpdateRequired"];
        BOOL firmwareUdateRequired = [requiredNumber boolValue];
        
        // create an alert
        NSMutableString *message = [[NSMutableString alloc] init];
        
        if (firmwareUdateRequired)
        {
            [message appendString:@"A newer version of the RFLKT software is required before you can connect. "];
        }
        else
        {
            [message appendString:@"A newer version of the RFLKT software is available. "];
        }
        
        [message appendString:@"Installing the upgrade requires the Wahoo Utility app. The Wahoo Utility app will open or you will be transferred to iTunes where you can download the Wahoo Utility app.\n\nWould you like to upgrade now?"];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"RFLKT Software Update"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        [alertView show];
    }
    
}

#pragma mark - UIAlertViewDelegate implementation
//--------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button index = %ld", (long)buttonIndex);
    
	// check if the "Yes" button was selected.
	if (buttonIndex == 0)
	{
        // button index == 0 is typically the cancel button
        // allow the cancel
	}
    else if (buttonIndex == 1)
    {
        if ([alertView.title isEqualToString:@"KICKR Software Update"])
        {
            // YES button selected to update firmware, open the Wahoo Utility App URL
            if (self.wahooUtilityAppURL != nil)
            {
                [[UIApplication sharedApplication] openURL:self.wahooUtilityAppURL];
            }
        }
    }
}




- (IBAction)sleepOnDisconnectChanged:(id)sender
{
    [(WFDisplayConnection*)self.sensorConnection setShouldSleepOnDisconnect:self.sleepOnDisconnectSwitch.on];
}

@end
