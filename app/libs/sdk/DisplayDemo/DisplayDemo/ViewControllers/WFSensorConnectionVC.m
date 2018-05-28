//
//  WFSensorConnectionVC.m
//  DisplayDemo
//
//  Created by Murray Hughes on 29/12/12.
//  Copyright (c) 2012 Wahoo Fitness. All rights reserved.
//

#import "WFSensorConnectionVC.h"

@interface WFSensorConnectionVC ()

@property (copy, nonatomic) NSString* statusString;

@end

@implementation WFSensorConnectionVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WFConnectionParams* params = [[WFHardwareConnector sharedConnector].settings connectionParamsForSensorType:self.sensorType];
    
    if (!params | [params isWildcard]) {
        self.wildcardSwitch.on = YES;
        self.proxSwitch.on = YES;
    }
    else
    {
        self.wildcardSwitch.on = NO;
        self.proxSwitch.on = NO;
    }
    
    [self updateDisplay];
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if([[segue destinationViewController] respondsToSelector:@selector(setSensorConnection:)])
    {
        [segue.destinationViewController performSelector:@selector(setSensorConnection:) withObject:self.sensorConnection];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section==0)
    {
        return self.statusString;
    }
    else
    {
        return [super tableView:tableView titleForFooterInSection:section];
    }
}

//--------------------------------------------------------------------------------
- (NSString*)signalStrength
{
    NSString* retVal = @"n/a";
    
    if ( self.sensorConnection )
    {
        // format the signal efficiency value.
		float signal = [self.sensorConnection signalEfficiency];
        //
        // signal efficency is % for ANT connections, dBm for BTLE.
        if ( self.sensorConnection.isANTConnection && signal != -1 )
        {
            retVal = [NSString stringWithFormat:@"%1.0f%%", (signal*100)];
        }
        else if ( self.sensorConnection.isBTLEConnection )
        {
            retVal = [NSString stringWithFormat:@"%1.0f dBm", signal];
        }
    }
    
    return retVal;
}


//--------------------------------------------------------------------------------

- (void) updateDisplay
{
    NSLog(@"updateDisplay");
    
	// get the current connection status.
	WFSensorConnectionStatus_t connState = WF_SENSOR_CONNECTION_STATUS_IDLE;
	if ( self.sensorConnection != nil )
	{
		connState = self.sensorConnection.connectionStatus;
	}
	
	// set the button state based on the connection state.
	switch (connState)
	{
		case WF_SENSOR_CONNECTION_STATUS_IDLE:
			[self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            self.statusString = @"...";
			break;
		case WF_SENSOR_CONNECTION_STATUS_CONNECTING:
			[self.connectButton setTitle:@"Cancel" forState:UIControlStateNormal];
            self.statusString = @"Searching...";
			break;
		case WF_SENSOR_CONNECTION_STATUS_CONNECTED:
			[self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            self.statusString = @"...";
			break;
		case WF_SENSOR_CONNECTION_STATUS_DISCONNECTING:
			[self.connectButton setTitle:@"Disconnecting..." forState:UIControlStateNormal];
            self.statusString = @"...";
			break;
        case WF_SENSOR_CONNECTION_STATUS_INTERRUPTED:
            self.statusString = @"Interrupted, Now Searching...";
            break;
        default:
            self.statusString = @"...";
            break;
	}
    
    [self.tableView reloadData];
}

- (IBAction)connectionButtonTouched:(id)sender
{
    NSLog(@"connectionButtonTouched:");
    
    // get the current connection status.
    WFSensorConnectionStatus_t connState = WF_SENSOR_CONNECTION_STATUS_IDLE;
    
    
    if (self.sensorConnection != nil )
    {
        connState = self.sensorConnection.connectionStatus;
    }
    
    // set the button state based on the connection state.
    switch (connState)
    {
        case WF_SENSOR_CONNECTION_STATUS_IDLE:
            // connect the sensor.
            [self connectSensor];
            break;
            
        case WF_SENSOR_CONNECTION_STATUS_CONNECTING:
        case WF_SENSOR_CONNECTION_STATUS_CONNECTED:
        case WF_SENSOR_CONNECTION_STATUS_INTERRUPTED:
            // disconnect the sensor.
            [self disconnectSesnor];
            break;
            
        case WF_SENSOR_CONNECTION_STATUS_DISCONNECTING:
            // do nothing.
            break;
    }
}


#pragma mark -
#pragma mark Sensor Connection Helpers / Events

- (WFConnectionParams*) connectionParams
{
    //[self mathTest];
    
    // create the connection params.
    WFConnectionParams* params = nil;
    
    //
    // if wildcard search is specified, create empty connection params.
    if ( self.wildcardSwitch.on )
    {
        params = [[WFConnectionParams alloc] init];
        params.sensorType = self.sensorType;
        params.networkType = WF_NETWORKTYPE_ANY;
    }
    //
    // otherwise, get the params from the stored settings.
    else
    {
        params = [[WFHardwareConnector sharedConnector].settings connectionParamsForSensorType:self.sensorType];
    }
    
    if ( params != nil)
    {
        // set the search timeout.
        params.searchTimeout = [WFHardwareConnector sharedConnector].settings.searchTimeout;
    }
    
    return params;
}

- (void) connectSensor
{
    NSLog(@"connectSensor:");
    
    // create the connection params.
    WFConnectionParams* params = [self connectionParams];
    
    //Create the new sensor connection
    if ( params != nil)
    {
        if([params isWildcard])
        {
            if(self.proxSwitch.on)
            {
                self.sensorConnection = [[WFHardwareConnector sharedConnector] requestSensorConnection:params withProximity:WF_PROXIMITY_RANGE_4];
            }
            else
            {
                self.sensorConnection = [[WFHardwareConnector sharedConnector] requestSensorConnection:params];
            }
        }
        else
        {
            self.sensorConnection = [[WFHardwareConnector sharedConnector] requestSensorConnection:params];
        }
        
        self.sensorConnection.delegate = self;
    }
    
    // update the display.
    [self updateDisplay];
}

- (void) disconnectSesnor
{
    [self.sensorConnection disconnect];
    
    // update the display.
    [self updateDisplay];
}

- (void) sensorDidConnect:(WFSensorConnection*) connectionInfo
{
    NSLog(@"sensorDidConnect:");
    
    //Save the connection settings
    [[WFHardwareConnector sharedConnector].settings saveConnectionInfo:connectionInfo];
    
    //Load the display layout from file
    //[self.sensorConnection loadMyConfigurationFile];
    
    // update the display.
    [self updateDisplay];
}

- (void) sensorDidDisconnect:(WFSensorConnection*) connectionInfo
{
    NSLog(@"sensorDidDisconnect:");
    
    // check for a connection error.
    if ( connectionInfo.hasError )
    {
        NSString* msg = nil;
        switch ( connectionInfo.error )
        {
            case WF_SENSOR_CONN_ERROR_PAIRED_DEVICE_NOT_AVAILABLE:
                msg = @"Paired device error.\n\nA device specified in the connection parameters was not found in the Bluetooth Cache.  Please use the paring manager to remove the device, and then re-pair.";
                break;
                
            case WF_SENSOR_CONN_ERROR_PROXIMITY_SEARCH_WHILE_CONNECTED:
                msg = @"Proximity search is not allowed while a device of the specified type is connected to the iPhone.";
                break;
                
            default:
                break;
        }
        
        if ( msg )
        {
            // display the error message.
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alert = nil;
        }
    }
    
    [self updateDisplay];
}

#pragma mark -
#pragma mark WFSensorConnectionDelegate Implementation

//--------------------------------------------------------------------------------
- (void)connectionDidTimeout:(WFSensorConnection*)connectionInfo
{
    NSLog(@"connectionDidTimeout:");
    
    // update the button state.
    [self updateDisplay];
    
    // alert the user that the search timed out.
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Search Timeout"
                                                    message:@"A connection was not established before the maximum search time expired."
                                                   delegate:nil cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    alert = nil;
}

//--------------------------------------------------------------------------------
- (void)connection:(WFSensorConnection*)connectionInfo stateChanged:(WFSensorConnectionStatus_t)connState
{
    NSString* state = @"Unknown";
    
	switch (connState)
	{
		case WF_SENSOR_CONNECTION_STATUS_IDLE:
			state = @"IDLE";
			break;
		case WF_SENSOR_CONNECTION_STATUS_CONNECTING:
			state = @"CONNECTING";
			break;
		case WF_SENSOR_CONNECTION_STATUS_CONNECTED:
			state = @"CONNECTED";
			break;
		case WF_SENSOR_CONNECTION_STATUS_DISCONNECTING:
			state = @"DISCONNECTING";
			break;
        case WF_SENSOR_CONNECTION_STATUS_INTERRUPTED:
			state = @"INTERRUPTED";
	}
    
    
    NSLog(@"SENSOR CONNECTION STATE CHANGED:  connState = %@(%d)",state,connState);
    
    // check for a valid connection.
    if ( connectionInfo.isValid && connectionInfo.isConnected )
    {
        // process post-connection setup.
        [self sensorDidConnect:connectionInfo];
    }
    
    // check for disconnected sensor.
    else if ( connState == WF_SENSOR_CONNECTION_STATUS_IDLE )
    {
        // process the disconnect
        [self sensorDidDisconnect:connectionInfo];
    }
	
	
}


- (void) connection:(WFSensorConnection*)connectionInfo rejectedByDeviceNamed:(NSString*) deviceName appAlreadyConnected:(NSString*) connectedAppName
{
    NSString* msg = [NSString stringWithFormat:@"The %@ device rejected the connection because an app named '%@' is already connected.\n\nPlease close the app if you wish to connect to this device.",deviceName ,connectedAppName];
    
    UIAlertView* alertView  = [[UIAlertView alloc] initWithTitle:@"Connection" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}


@end
