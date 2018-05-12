//
//  WFAppDelegate.h
//  DisplayViewOSX
//
//  Created by Murray Hughes on 30/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WFConnector/WFConnector.h>

#import "WFDisplayPageVC.h"

@interface WFAppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSComboBoxDataSource, NSComboBoxDelegate>
{
    FSEventStreamRef stream;
     NSNumber* lastEventId;
}

// IBOutlets
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *filePath;
@property (weak) IBOutlet NSButton *monitorFileCheckbox;
@property (weak) IBOutlet NSComboBox *deviceComboBox;


@property (unsafe_unretained) IBOutlet WFDisplayPageVC *displayRFLKTViewController;
@property (unsafe_unretained) IBOutlet WFDisplayPageVC *displayEchoViewController;
@property (unsafe_unretained) IBOutlet WFDisplayPageVC *displayTimexViewController;

@property (strong) WFDisplayConfiguration* displayConfiguration;

- (IBAction)monitorFileClicked:(id)sender;

@end
