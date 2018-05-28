//
//  WFDisplayPageVC.h
//  DisplayViewOSX
//
//  Created by Murray Hughes on 30/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WFConnector/WFConnector.h>

@interface WFDisplayPageVC : NSViewController

@property (weak) IBOutlet WFDisplayPageView *displayPageView;
@property (weak) IBOutlet NSTableView *pageTableView;

@property (weak) IBOutlet NSTableView *soundTableView;
@property (weak) IBOutlet NSButton *invertedCheckbox;

@property (weak) IBOutlet NSButton *infoViewCheckbox;

@property (weak) IBOutlet NSTextField *pageCommentTextField;

@property (nonatomic, assign) WFSensorSubType_t sensorSubType;

- (IBAction)playButtongClicked:(NSView*)sender;

- (void) updateDisplayConfiguration:(WFDisplayConfiguration*) displayConfiguration;
- (IBAction)invertedCheckboxClicked:(id)sender;

@end
