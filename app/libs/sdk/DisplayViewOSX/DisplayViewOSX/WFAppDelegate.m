//
//  WFAppDelegate.m
//  DisplayViewOSX
//
//  Created by Murray Hughes on 30/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFAppDelegate.h"
#import "WFDisplayConnectionController.h"

@interface WFAppDelegate ()

@property (nonatomic, copy) NSString* configPath;
@property (nonatomic, retain) WFDisplayConnectionController* connectionController;

@end

@implementation WFAppDelegate


#pragma mark
#pragma mark - Application Delegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Setup the Display view controller sub types
    self.displayEchoViewController.sensorSubType = WF_SENSOR_SUBTYPE_DISPLAY_ECHO;
    self.displayRFLKTViewController.sensorSubType = WF_SENSOR_SUBTYPE_DISPLAY_RFLKT;
    self.displayTimexViewController.sensorSubType = WF_SENSOR_SUBTYPE_DISPLAY_TIMEX_RUN_X50;
    
    [[WFHardwareConnector sharedConnector] enableBTLE:YES];
    
    self.connectionController = [WFDisplayConnectionController new];
    [self.connectionController startDiscovery];
    
    
    // Line for autoloading a config....
    //[self loadConfigAtPath:@"//Users/murrayhughes/Documents/WahooFitnessGit/WFDeveloper/WahooFitnessSDK/DisplayDemo/DisplayDemo/Configurations/pageTemplates-timex-size-test.json"];
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark
#pragma mark - Config Load / Update

- (IBAction)reSaveJSONClickedidsender:(id)sender
{
    NSError* error = nil;
    
    
    NSData* JSONData = [NSData dataWithContentsOfFile:self.configPath];
    id JSONObject = nil;
    
    if(JSONData) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&error];
    }
    
    if(JSONObject)
    {
        NSData* JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:NSJSONWritingPrettyPrinted error:&error];
        
        if(!error)
        {
            [JSONData writeToFile:self.configPath atomically:YES];
        }
    }
    
}

- (IBAction)buttonClicked:(id)sender
{
    //Get the files
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES]; // yes if more than one dir is allowed
    [panel setAllowedFileTypes:@[@"json",@"txt"]];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            // do something with the url here.
            [self loadConfigAtPath:[url path]];
        }
    }
}


- (void) loadConfigAtPath:(NSString*) path
{
    [self.filePath setStringValue:path];

    self.displayConfiguration = [WFDisplayConfiguration instanceWithContentsOfFile:path];
    
    [self.displayEchoViewController updateDisplayConfiguration:self.displayConfiguration];
    [self.displayRFLKTViewController updateDisplayConfiguration:self.displayConfiguration];
    [self.displayTimexViewController updateDisplayConfiguration:self.displayConfiguration];

    // Check to see if the Path changed
    if([self.configPath isEqualToString:path]==NO)
    {
        self.configPath = path;
        [self updateFileMonitorState];
    }
}


#pragma mark
#pragma mark - File Monitor

- (IBAction)monitorFileClicked:(id)sender
{
    [self updateFileMonitorState];
}

- (void) updateFileMonitorState
{
    if(self.monitorFileCheckbox.state == NSOnState)
    {
        [self startFileMonitor:self.configPath];
    }
    else
    {
        [self stopFileMonitor];
    }
}

- (void)updateLastEventId: (uint64_t) eventId
{
    lastEventId = @(eventId);
}


- (void) stopFileMonitor
{
    if(stream)
    {
        FSEventStreamStop(stream);
        FSEventStreamInvalidate(stream);
        stream=NULL;
    }
}

- (void) startFileMonitor:(NSString*) path
{
    [self stopFileMonitor];
    
    NSArray *pathsToWatch = [NSArray arrayWithObject:path];
    void *appPointer = (__bridge void *)self;
    FSEventStreamContext context = {0, appPointer, NULL, NULL, NULL};
    NSTimeInterval latency = 0.0;
    stream = FSEventStreamCreate(NULL,
                                 &fsevents_callback,
                                 &context,
                                 (__bridge CFArrayRef) pathsToWatch,
                                 [lastEventId unsignedLongLongValue],
                                 (CFAbsoluteTime) latency,
                                 kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes
                                 );
    
    FSEventStreamScheduleWithRunLoop(stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
}


void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])
{
    WFAppDelegate *appDelegate = (__bridge WFAppDelegate *)userData;
    size_t i;
    
    for(i=0; i < numEvents; i++){
        //[ac addModifiedImagesAtPath:[(NSArray *)eventPaths objectAtIndex:i]];
        
        NSString* path = [(__bridge NSArray *)eventPaths objectAtIndex:i];
        NSLog(@" EVENT (%X): '%@'", eventFlags[i], path);
        [appDelegate loadConfigAtPath:path];
        [appDelegate updateLastEventId:eventIds[i]];
    }
    
}

#pragma mark
#pragma mark - Connection Control
- (IBAction)sendConfiguration:(id)sender {
    [self.connectionController.sensorConnection loadConfiguration:self.displayConfiguration];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return self.connectionController.discoveredDisplays.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    WFDeviceInformation* deviceInformation = self.connectionController.discoveredDisplays[index];
    return deviceInformation.name;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    WFDeviceInformation* deviceInformation = self.connectionController.discoveredDisplays[self.deviceComboBox.indexOfSelectedItem];
    [self.connectionController connectDisplayWithDeviceInfo:deviceInformation];
}

@end
