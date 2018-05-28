//
//  WFDisplayDemoStandard.m
//  DisplayDemo
//
//  Created by Murray Hughes on 4/01/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFDisplayDemoStandard.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WFDisplayDemoStandard ()

@property (strong, nonatomic) NSDate* startTime;
@property (assign, nonatomic, getter = isUpdating) BOOL updating;

@property (copy, nonatomic) NSString* musicString;
@property (nonatomic) NSInteger musicStringLocation;

@end

@implementation WFDisplayDemoStandard

@synthesize musicString = _musicString;


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setHeartrateSlider:nil];
    [self setSpeedSlider:nil];
    [self setPowerSlider:nil];
    [self setCadenceSlider:nil];
    [self setWorkoutTimeLabel:nil];
    [self setHeartrateLabel:nil];
    [self setSpeedLabel:nil];
    [self setPowerLabel:nil];
    [self setCadenceLabel:nil];
    [self setArtistLabel:nil];
    [self setTrackLabel:nil];
    [self setMemoryCurrentLabel:nil];
    [self setMemoryRFLKTv1Label:nil];
    [self setMemoryRFLKTv2Label:nil];
    [self setMemoryRFLKTv2Label:nil];
    [self setMemoryEchoV1Label:nil];
    [self setAutoScrollButton:nil];
    [self setAutoScrollSlider:nil];
    [self setInvertedSwitch:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self startMediaUpdates];
    self.displayConnection.displayConnectionDelegate = self;
    
    [self autoPageSliderChanged:self.autoScrollSlider];
    [self memoryCalculations];
    
    self.invertedSwitch.enabled = NO;
    [self.displayConnection getDisplayInverted];


}

- (void) viewDidDisappear:(BOOL)animated
{
    [self stopMediaUpdates];
    [self stopUpdates];
    self.displayConnection.displayConnectionDelegate = nil;
}

- (void) showAlert:(NSString*) msg
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark Config Loading

// simple helper method for loading the display config from file.
- (WFDisplayConfiguration*) displayConfiguration
{
    NSString* configPath = nil;
    
    if(self.displayConnection.sensorSubType == WF_SENSOR_SUBTYPE_DISPLAY_CASIO_TYPE1)
    {
        configPath = [[NSBundle mainBundle] pathForResource:@"Casio-STB-1000" ofType:@"json"];
    }
    else
    {
        configPath = [[NSBundle mainBundle] pathForResource:@"StandardConfig" ofType:@"json"];
    }
    
    WFDisplayConfiguration* config = [WFDisplayConfiguration instanceWithContentsOfFile:configPath];
    
    return config;
}

- (void) loadConfiguration
{
    [self.displayConnection loadConfiguration:[self displayConfiguration]];
}


#pragma mark -
#pragma mark Data updates

- (void) startUpdates
{
    if(self.startTime==nil)
    {
        self.startTime = [NSDate date];
    }
    
    self.updating = YES;
    [self updateDataTiggered];
}

- (void) stopUpdates
{
    self.updating = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateDataTiggered) object:nil];
}

- (void) setRandomValueForSlider:(UISlider*) slider animated:(BOOL) animated
{
    // Finds a random number that is +/- 5% of the range of the slider and
    // adds it to the old value to find the new value. Jiggle Jiggle Jiggle
    float diff = 0.05*(slider.maximumValue-slider.minimumValue);
    float random = ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(diff*2)+(-diff);
    float value = slider.value += random;
    
    [slider setValue:value animated:animated];
}

- (void) updateData
{
    // Update the iPhone UI with the new values
    self.workoutTimeLabel.text = [self workoutTimeString];
    self.heartrateLabel.text = [self heartrateString];
    self.speedLabel.text = [self speedString];
    self.powerLabel.text = [self powerString];
    self.cadenceLabel.text = [self cadenceString];
    
    // When doing multiple updates at the same time, it is best to tell the API,
    // much like you would with a UITableView. The API will cache the udpated
    // values until you call 'endUpdates', then package the data into the most
    // effecient manner before sending them to the device.
    //
    // The API optimizes communication and battery life by only sending updates
    // to elements visable on the current page. All other items are queued and sent
    // when a page becomes visable.
    //
    [self.displayConnection beginUpdates];
    
    [self.displayConnection setValue:self.workoutTimeLabel.text forElementWithKey:@"WorkoutTime.ValueString"];
    [self.displayConnection setValue:self.heartrateLabel.text forElementWithKey:@"Heartrate.ValueString"];
    [self.displayConnection setValue:self.powerLabel.text forElementWithKey:@"Power.ValueString"];
    [self.displayConnection setValue:self.cadenceLabel.text forElementWithKey:@"Cadence.ValueString"];
    [self.displayConnection setValue:self.speedLabel.text forElementWithKey:@"Speed.ValueString"];
    
    // Commit the changes and let the API start sending them before we move to the next step
    [self.displayConnection endUpdates];
}

- (void) updateDataTiggered
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateDataTiggered) object:nil];
    
    //Set some new random values
    [self setRandomValueForSlider:self.heartrateSlider animated:YES];
    [self setRandomValueForSlider:self.speedSlider animated:YES];
    [self setRandomValueForSlider:self.powerSlider animated:YES];
    [self setRandomValueForSlider:self.cadenceSlider animated:YES];
    
    [self updateData];
    
    // Finally, schedule the next update
    [self performSelector:@selector(updateDataTiggered) withObject:nil afterDelay:0.5];
}



- (void) showHiddenPage
{
    
    // When you want to show a hidden page, you force the API to send
    // the updates before setting the page visable, otherwise the updates would
    // just be queued and you will get a short delay between the page being
    // visable and the data getting populated
    //
    [self.displayConnection beginForcedUpdates];
    
    [self.displayConnection setValue:@"New PB!" forElementWithKey:@"MessageString1"];
    [self.displayConnection setValue:@"Joe Doe" forElementWithKey:@"MessageString2"];
    [self.displayConnection setValue:@"2:32" forElementWithKey:@"MessageString3"];
    
    [self.displayConnection endUpdates];
    
    // Finally show the page
    [self.displayConnection setPageVisibleWithKey:@"HiddenPage" timeout:10.0];
}

- (void) memoryCalculations
{
    // Display sensors are small, microcontroller based external displays. These devices normally have very limited memory resources.
    // You need to consider 2 types of resources,
    // 1 - Flash, this is amount of memory require to store the config in the deives flash storage.
    // 2 - RAM, this is the amount of RAM required when the config is loaded and in use.
    //
    // Generally you don't need to worry about Flash, devices should have heaps of room to store the config. Deivces can store multiple configs
    // at the same time. BITMAPS are normally the main contributor to Flash usage.
    //
    // RAM is normamly the limiting factor, the device normally uses RAM to store updates and is the main limiting factor on how many pages
    // the device can load at the same time.
    //
    // Different hardware and firmware versions have different resources availible. These requirements can change over time with new updates and devices.
    // The best way to keep track of the memory requirements is to use the WFDisplayMemoryCalculator helper class.
    //
    // If you have never connected to a Display device, but still allow the user to play with the configuration, you are best to grab the default
    // calcualtor for each subtype device.
    //
    WFDisplayMemoryCalculator* calcRFLKT = [WFDisplayMemoryCalculator displayMemoryCalculatorForSensorSubType:WF_SENSOR_SUBTYPE_DISPLAY_RFLKT];
    WFDisplayMemoryCalculator* calcECHO = [WFDisplayMemoryCalculator displayMemoryCalculatorForSensorSubType:WF_SENSOR_SUBTYPE_DISPLAY_ECHO];

    // If you have connected to a device, you can get the correct calculator using the device UUID string. You are best to store this UUID string
    // so you can always grab the correct calculator even when it is not connected.
    WFDisplayMemoryCalculator* current = [WFDisplayMemoryCalculator displayMemoryCalculatorForDeviceWithUUID:self.displayConnection.deviceUUIDString];
    
    //
    // All usage values are returned with a value between 0 and 1.0.
    //
    self.memoryCurrentLabel.text = [NSString stringWithFormat:@"%1.2f%%", 100*[current ramUsageForDisplayConfiguration:[self displayConfiguration]]];
    self.memoryRFLKTv1Label.text = [NSString stringWithFormat:@"%1.2f%%", 100*[calcRFLKT ramUsageForDisplayConfiguration:[self displayConfiguration]]];
    self.memoryEchoV1Label.text = [NSString stringWithFormat:@"%1.2f%%", 100*[calcECHO ramUsageForDisplayConfiguration:[self displayConfiguration]]];

}


#pragma mark -
#pragma mark - Data formatters

// Yep... nothing magic here... move along

- (NSString*) heartrateString
{
    return [NSString stringWithFormat:@"%1.0f", self.heartrateSlider.value];
}

- (NSString*) speedString
{
    return [NSString stringWithFormat:@"%1.1f", self.speedSlider.value];
}

- (NSString*) powerString
{
    return [NSString stringWithFormat:@"%1.0f", self.powerSlider.value];
}


- (NSString*) cadenceString
{
    return [NSString stringWithFormat:@"%1.0f", self.cadenceSlider.value];
}

- (NSString*) workoutTimeString
{
    NSString* retValue = nil;

    if(self.startTime == nil)
    {
        retValue = @"0:00:00";
    }
    else
    {

        unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.startTime toDate:[NSDate date] options:0];
        
        if ([components hour]>0) {
            retValue = [NSString stringWithFormat:@"%ld:%02ld:%02ld",
                        (long)[components hour],
                        (long)[components minute],
                        (long)[components second]];
        }
        else {
            retValue = [NSString stringWithFormat:@"%ld:%02ld",
                        (long)[components minute],
                        (long)[components second]];
        }
        
    }
    
    return retValue;
}

/// mmm.... a little magic... see: 'updateMediaDisplay'

- (void) setMusicString:(NSString *)musicString
{
    _musicString = [musicString copy];
    if(_musicString.length>14)
    {
        _musicString = [_musicString stringByAppendingString:@" | "];
    }
    
    self.musicStringLocation = 0;
}

- (NSString*) musicString
{
    NSString* retValue = _musicString;
    
    const int maxLength = 14;
    if(retValue.length>maxLength)
    {
        retValue = [_musicString substringFromIndex:self.musicStringLocation];
        
        if(retValue.length < maxLength)
        {
            retValue = [NSString stringWithFormat:@"%@%@", retValue, _musicString];
        }
        
        retValue = [retValue substringToIndex:14];
        
        self.musicStringLocation = (self.musicStringLocation+1) % _musicString.length;
    }

    return retValue;
}


#pragma mark -
#pragma mark Music Control

- (void) startMediaUpdates
{
    //Setup notifications for the iPod player controls
    MPMusicPlayerController* ipodPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(updateMediaInfo) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:ipodPlayer];
    [notificationCenter addObserver:self selector:@selector(updateMediaInfo) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:ipodPlayer];
    
    [ipodPlayer beginGeneratingPlaybackNotifications];

    [self updateMediaInfo];
    [self updateMediaDisplay];
}

- (void) stopMediaUpdates
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMediaInfo) object:nil];

    MPMusicPlayerController* ipodPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [ipodPlayer endGeneratingPlaybackNotifications];

    [notificationCenter removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:ipodPlayer];
    [notificationCenter removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:ipodPlayer];
}

- (void) updateMediaInfo
{
    MPMediaItem* mediaItem  = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    
    if(mediaItem)
    {
        self.artistLabel.text = [mediaItem valueForKey:MPMediaItemPropertyAlbumArtist];
        self.trackLabel.text = [mediaItem valueForKey:MPMediaItemPropertyTitle];
        
        self.musicString = [NSString stringWithFormat:@"%@ - %@", self.artistLabel.text, self.trackLabel.text];
        
    }
    else
    {
        self.artistLabel.text = @"";
        self.trackLabel.text = @"";
        self.musicString = @"";
    }
}

- (void) updateMediaDisplay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMediaDisplay) object:nil];

    // NOTE: The API / Device does not currently support scrolling text. If you have a string that
    // Could be longer than the area allocated, you will need to manually scroll the text. In this
    // Demo the string is shifted 1 character every 3 seconds. Look at the code in the 'musicString'
    // Property getter for more information.
    //
    // In the near furture I will add both hardware and API support for dealing with long strings...
    //
    
    // Since we only have one update, we don't need to bother with the begin/end calls.
    [self.displayConnection setValue:self.musicString forElementWithKey:@"Music.ValueString"];
    
    [self performSelector:@selector(updateMediaDisplay) withObject:nil afterDelay:2.0];
}


- (void) mediaPlayPause
{
    if([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying)
    {
        [[MPMusicPlayerController iPodMusicPlayer] pause];
    }
    else
    {
        [[MPMusicPlayerController iPodMusicPlayer] play];
    }
}

- (void) mediaSkipTrack
{
    if([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying)
    {
        [[MPMusicPlayerController iPodMusicPlayer] skipToNextItem];
    }
    else
    {
        [[MPMusicPlayerController iPodMusicPlayer] play];
    }
}

#pragma mark -
#pragma mark WFDisplayConnectionDelegate Implementation

- (WFDisplayConfiguration *)configurationForDisplayConnection:(WFDisplayConnection *)connection
{
    NSLog(@"configurationForDisplayConnection:");
    
    // In most cases this is the main delegate you want to implement to handle loading the display
    // configuration as soon as the display is ready. If Nil is returned, then "No Config" will
    // be displayed on the screen.
    //
    // Alternativly you can use the 'loadConfiguation' method to load a config at anytime. 
    
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
    
    if(buttonIndex==0) // RFLKT NORTH_EAST
    {
        [self mediaSkipTrack];
    }
    
    if(buttonIndex==1) // RFLKT NORTH_WEST
    {
        [self mediaPlayPause];
    }

    if(buttonIndex==2) // RFLKT SOUTH_EAST
    {
    }

    if(buttonIndex==3) // RFLKT SOUTH_WEST
    {
    }
}

- (void)displayConnection:(WFDisplayConnection *)connection visablePageChanged:(NSString *)visablePageKey
{
    NSLog(@"displayConnection:visablePageChanged:%@", visablePageKey);
}

- (void) displayConnection:(WFDisplayConnection*) connection didRespondBacklightOn:(BOOL) backlightOn error:(NSError*) error
{
    NSLog(@"displayConnection:didRespondBacklightOn: %@ error:%@", backlightOn ? @"ON" : @"OFF", error ? error : @"nil");
}

- (void) displayConnection:(WFDisplayConnection*) connection didRespondDisplayInverted:(BOOL) inverted error:(NSError*) error
{
    NSLog(@"displayConnection:didRespondDisplayInverted: %@ error:%@", inverted ? @"YES" : @"NO", error ? error : @"nil");
    
    self.invertedSwitch.on = inverted;
    self.invertedSwitch.enabled = YES;
}

- (void) displayConnection:(WFDisplayConnection*) connection didRespondPageVisableWithKey:(NSString*) pageKey error:(NSError*) error
{
    NSLog(@"displayConnection:didRespondPageVisableWithKey: %@ error:%@", pageKey, error ? error : @"nil");
}

- (void) displayConnection:(WFDisplayConnection*) connection didRespondDate:(NSDate*) date timeZone:(NSTimeZone*) timeZone error:(NSError*) error
{
    NSLog(@"displayConnection:didRespondDate: %@ timeZone: %@ error:%@", date, timeZone, error ? error : @"nil");
    
    [self showAlert:[NSString stringWithFormat:@"DateTime Set\n%@\n%@", date, timeZone]];
}

- (void) displayConnection:(WFDisplayConnection*) connection didRespondAutoPageScrollWithDelay:(NSTimeInterval) delay error:(NSError*) error
{
    NSLog(@"displayConnection:didRespondAutoPageScrollWithDelay %1.4f error:%@", delay, error ? error : @"nil");
    
    [self showAlert:[NSString stringWithFormat:@"Set Auto Page Scroll"]];
}

- (void) displayConnection:(WFDisplayConnection*) connection
      didRespondDateFormat:(wf_display_date_format_e) dateFormat
                timeFormat:(wf_display_time_format_e) timeFormat
            startDayOfWeek:(wf_display_day_e) startDayOfWeek
                     error:(NSError*) error
{
    NSLog(@"displayConnection:didRespondDateFormat:%d timeFormat:%d startDayOfWeek:%d error:%@", dateFormat,timeFormat,startDayOfWeek, error ? error : @"nil");
    
    [self showAlert:[NSString stringWithFormat:@"Date Time Formats\n\nDateFormat = %d\nTimeFormat=%d\nStartDayOfWeek=%d", dateFormat,timeFormat,startDayOfWeek]];
}


#pragma mark -
#pragma mark - UI Actions

- (IBAction)loadConfigTouched:(UIButton*)sender
{
    [self loadConfiguration];
}

- (IBAction)startUpdatesTouched:(UIButton*)sender
{
    if ( self.updating) {
        [self stopUpdates];
        [sender setTitle:@"Start Updates" forState:UIControlStateNormal];
    }
    else {
        [self startUpdates];
        [sender setTitle:@"Stop Updates" forState:UIControlStateNormal];
    }
}

- (IBAction)showHiddenPageTouched:(UIButton*)sender
{
    [self showHiddenPage];
}

- (IBAction)showAlertWithCustomSound:(id)sender {
    
    // the "CustomSoundPage" page has a "SoundKey" property set, the Echo watch will play this sound when the page is first displayed.
    [self.displayConnection setPageVisibleWithKey:@"CustomSoundPage" timeout:5.0];
}

- (IBAction)playSoundTouched:(id)sender {
    
    // Playing sounds on demand. The sound must be pre-defined in the sounds section of the config file.
    [self.displayConnection playSoundWithKey:@"PlaySoundKey"];
}

- (IBAction)sliderValueChanged:(UISlider*)sender
{
    [self updateData];
}

- (IBAction)backlightSwitchChanged:(UISwitch *)sender
{
    [self.displayConnection setBacklightOn:sender.on ? 100 : 0];
}

- (IBAction)invertedSwitchedChanged:(UISwitch *)sender
{
    [self.displayConnection setDisplayInverted:sender.on];
}

- (IBAction)setBacklightOnWithTimeoutTouched:(id)sender
{
    [self.displayConnection setBacklightOn:100 withTimeout:4.0];
}


- (IBAction)setAutoPageScroll:(id)sender
{
    [self.displayConnection setAutoPageScrollWithDelay:self.autoScrollSlider.value];
}

- (IBAction)autoPageSliderChanged:(UISlider *)sender
{
    NSString* value = (self.autoScrollSlider.value == 0.0) ? @"Off" : [NSString stringWithFormat:@"%1.2fs", sender.value];
    NSString* title = [NSString stringWithFormat:@"Set Auto Page Scroll (%@)", value];
    
    [self.autoScrollButton setTitle:title forState:UIControlStateNormal];
}

@end
