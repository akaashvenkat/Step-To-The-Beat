//
//  WFDisplayPageVC.m
//  DisplayViewOSX
//
//  Created by Murray Hughes on 30/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WFDisplayPageVC.h"
#import "WFDisplaySoundPlayer.h"

@interface WFDisplayPageVC ()

@property (strong) WFDisplayMemoryCalculator* memoryCalculator;
@property (nonatomic, strong) WFDisplayConfiguration* displayConfiguration;
@property (nonatomic, strong) WFDisplaySoundPlayer* soundPlayer;
@property (nonatomic, strong) NSView* infoView;

@end

@implementation WFDisplayPageVC


#pragma mark
#pragma mark - Properties

- (void) setSensorSubType:(WFSensorSubType_t)sensorSubType
{
    if(_sensorSubType != sensorSubType)
    {
        _sensorSubType = sensorSubType;
        
        // Update the subtype specfic settings
        self.memoryCalculator = [WFDisplayMemoryCalculator displayMemoryCalculatorForSensorSubType:sensorSubType];
        self.displayPageView.sensorSubType = sensorSubType;
    }
}


- (WFDisplaySoundPlayer *)soundPlayer
{
    if (_soundPlayer==nil) {
        _soundPlayer = [[WFDisplaySoundPlayer alloc] init];
    }
    
    return _soundPlayer;
}

#pragma mark
#pragma mark - Configuration Updates

- (IBAction)playButtongClicked:(NSButtonCell*)sender {

    WFDisplaySound* sound = [self.displayConfiguration.sounds objectAtIndex:sender.tag];
    [self.soundPlayer playSound:sound];
    
}



- (void) updateTimexPageIndicatorsInDisplayConfiguration:(WFDisplayConfiguration *)displayConfiguration
{
    NSInteger visablePageCount = [displayConfiguration.pages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hidden == %d",0]].count;
    
    NSInteger pageIdx = 0;
    for (WFDisplayPage* page in displayConfiguration.pages) {
        
        if(!page.hidden) {
            
            
            for (WFDisplayElement* element in page.elements) {
                if([element isKindOfClass:[WFDisplayElementGroup class]] && [element.key isEqualToString:@"TimexPageIndicators"])
                {
                    WFDisplayElementGroup* group = (WFDisplayElementGroup*)element;
                    [group removeAllElements];
                    
                    for(int i = 0; i<visablePageCount; i++)
                    {
                        BOOL currentPage = (i==pageIdx);
                        WFDisplayElementRect* rect = [WFDisplayElementRect new];
                        rect.frame = CGRectMake(120, 4 + (6*i), (currentPage) ? 8 : 1, 4);
                        rect.fillColor = (currentPage) ? WF_DISPLAY_COLOR_BLACK : WF_DISPLAY_COLOR_NONE;
                        [group addElement:rect];
                    }
                }
                
                if([element isKindOfClass:[WFDisplayElementGroup class]] && [element.key isEqualToString:@"TimexControlBar"])
                {
                    WFDisplayElementGroup* group = (WFDisplayElementGroup*)element;
                    [group removeAllElements];
                    
                    WFDisplayElementBitmap* music = [WFDisplayElementBitmap new];
                    music.frame = CGRectMake(0, 102, 26, 26);
                    music.key = @"musicIcon";
                    music.imageBase64 = @"///////////////////////w//////8P////////wP//////D/D/////PwD//////wPA/////z8A/P/////DAP////8PPPD/////wA//////D//w////P/DP/////wP/////AD/8////AADD////AwAA/P//PwAAwP///wMAAPz//z8AAPD///8DAAD/////AAD8////PwDw/////////////////////w==";
                    
                    WFDisplayElementBitmap* start = [WFDisplayElementBitmap new];
                    start.frame = CGRectMake(102, 102, 26, 26);
                    start.key = @"startIcon";
                    start.hidden = NO;
                    start.imageBase64 = @"///////////////////8//////8P/P//////AP//////DwD//////wAA/////w8AwP////8AAMD///8PAADA////AAAA8P//DwAAAPD//wAAAADw/w8AAAAA//8AAAAA//8PAAAA////AAAA/P//DwAA/P///wAA/P///w8A8P////8A8P////8P8P//////wP//////z////////////////////////w==";

                    WFDisplayElementBitmap* pause = [WFDisplayElementBitmap new];
                    pause.frame = CGRectMake(102, 102, 26, 26);
                    pause.key = @"pauseIcon";
                    pause.hidden = YES;
                    pause.imageBase64 = @"//////////////////8A8P8A8P8PAP8PAP//APD/APD/DwD/DwD//wDw/wDw/w8A/w8A//8A8P8A8P8PAP8PAP//APD/APD/DwD/DwD//wDw/wDw/w8A/w8A//8A8P8A8P8PAP8PAP//APD/APD/DwD/DwD//wDw/wDw/w8A/w8A//8A8P8A8P8PAP8PAP//APD/APD/DwD/DwD//////////////////w==";

                    WFDisplayElementString* topActionButton = [WFDisplayElementString new];
                    topActionButton.frame = CGRectMake(26, 106, 76, 16);
                    topActionButton.value = @"LAP";
                    topActionButton.align = WF_DISPLAY_ALIGNMENT_CENTER;
                    topActionButton.font = WF_DISPLAY_FONT_SYSTEM12;
                    topActionButton.key = @"topActionButton";
                    topActionButton.constant = NO;
                    
                    [group addElement:music];
                    [group addElement:start];
                    [group addElement:pause];
                    [group addElement:topActionButton];
                    
                }
                
            }
            pageIdx++;
        }
    }
}


- (void) updateDisplayConfiguration:(WFDisplayConfiguration *)displayConfiguration
{
    [self updateTimexPageIndicatorsInDisplayConfiguration:displayConfiguration];
    
    self.displayPageView.invert = (self.invertedCheckbox.state == NSOnState) ? YES : NO;
    
    if(_displayConfiguration==nil)
    {
        [self setDisplayConfiguration:displayConfiguration];
        self.displayPageView.page = [self.displayConfiguration.pages objectAtIndex:0];
        self.pageCommentTextField.stringValue = self.displayPageView.page.comment ?: @"";
    }
    else
    {
        NSString* selectedPageKey =  self.displayPageView.page.key;
        
        NSInteger selectedIndex = 0;

        _displayConfiguration = displayConfiguration;
        
        
        for (int i = 0; i<displayConfiguration.pages.count; i++) {
            WFDisplayPage* page = [displayConfiguration.pages objectAtIndex:i];
            
            if([page.key isEqualToString:selectedPageKey])
            {
                selectedIndex = i;
                break;
            }
        }
        
        [self.pageTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedIndex] byExtendingSelection:NO];
        [self tableViewSelectionDidChange:nil];
        
    }
    
    [self.pageTableView reloadData];
    [self.soundTableView reloadData];

    [self updateInfoView];
}

- (IBAction)invertedCheckboxClicked:(id)sender {
    self.displayPageView.invert = (self.invertedCheckbox.state == NSOnState) ? YES : NO;
    
}

#pragma mark
#pragma mark - Info / Debug View

- (IBAction)infoViewCheckboxClicked:(id)sender {
    [self updateInfoView];
}

// Drawes frames of groups and strings to help laying out files.

- (NSView*) infoViewForPage:(WFDisplayPage*) page withFrame:(CGRect)frame
{
    
    NSView* infoView = [[NSView alloc] initWithFrame:frame];
    //iterate groups
    for (WFDisplayElement* element in page.elements)
    {
        if(!element.hidden) {
            
            CGRect labelFrame = [self translateFrame:element.frame fromReference:CGRectMake(0, 0, 128, 128) toReference:infoView.frame];
            
            NSView* outline = [[NSView alloc] initWithFrame:labelFrame];
            outline.wantsLayer = YES;
            outline.layer = [CALayer layer];
            outline.layer.backgroundColor = CGColorCreateGenericRGB(0, 0, 0, 0.1);
            outline.layer.borderWidth = 1.0;
            
            
            //set up label
            NSTextField* label = [[NSTextField alloc] initWithFrame:labelFrame];
            label.stringValue = @"";
            label.textColor = [NSColor redColor];
            [label setBezeled:NO];
            [label setDrawsBackground:NO];
            [label setEditable:NO];
            [label setSelectable:NO];
            
            [infoView addSubview:outline];
            [infoView addSubview:label];
            
            if ([element isKindOfClass:[WFDisplayElementGroup class]])
            {
                //create a label for each group
                WFDisplayElementGroup* groupElement = (WFDisplayElementGroup*)element;
                
                if(groupElement.groupId && groupElement.key) {
                    label.stringValue = [NSString stringWithFormat:@"%@ - %@", groupElement.groupId, groupElement.key];
                }
                else
                {
                    label.stringValue = groupElement.groupId ?: (groupElement.key ?: @"");
                }
                
                outline.layer.borderColor = CGColorCreateGenericRGB(1.0, 0, 0, 0.5);
                
                for (WFDisplayElement* innerElement in groupElement.elements) {
                    
                    if(![innerElement isKindOfClass:[WFDisplayElementRect class]]) {
                        CGRect innerFrame = [self translateFrame:innerElement.frame fromReference:CGRectMake(0, 0, 128, 128) toReference:infoView.frame];
                        
                        NSView* innerElementView = [[NSView alloc] initWithFrame:innerFrame];
                        innerElementView.wantsLayer = YES;
                        innerElementView.layer = [CALayer layer];
                        innerElementView.layer.backgroundColor = CGColorCreateGenericRGB(0, 0, 1.0, 0.05);
                        innerElementView.layer.borderColor = CGColorCreateGenericRGB(0.0, 0.0, 1.0, 0.2);
                        innerElementView.layer.borderWidth = 1.0;
                        
                        [infoView addSubview:innerElementView];
                    }
                }
                
            }
        }
        
    }
    
    
    return infoView;
}

- (CGRect)translateFrame:(CGRect)originalFrame fromReference:(CGRect)fromReference toReference:(CGRect)toReferece
{
    double xScale = toReferece.size.width / fromReference.size.width;
    double yScale = toReferece.size.height / fromReference.size.height;
    
    CGRect translatedFrame;
    translatedFrame.origin = CGPointMake(originalFrame.origin.x * xScale, originalFrame.origin.y * yScale);
    translatedFrame.size = CGSizeMake(originalFrame.size.width * xScale, originalFrame.size.height * yScale);
    
    translatedFrame.origin.y = toReferece.size.height - translatedFrame.origin.y - translatedFrame.size.height;
    
    return translatedFrame;
}

- (void) updateInfoView
{
    [self.infoView removeFromSuperview];
    
    if(self.infoViewCheckbox.state == NSOnState) {
        self.displayPageView.pixelAlpha = 0.05;
        self.infoView = [self infoViewForPage:self.displayPageView.page withFrame:self.displayPageView.frame];
        [self.displayPageView.superview addSubview:self.infoView];
    } else {
        self.displayPageView.pixelAlpha = 1.0;
    }
}

#pragma mark
#pragma mark - TableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if(self.pageTableView.selectedRow>=0 && self.pageTableView.selectedRow <self.displayConfiguration.pages.count)
    {
        self.displayPageView.page = [self.displayConfiguration.pages objectAtIndex:self.pageTableView.selectedRow];
        self.pageCommentTextField.stringValue = self.displayPageView.page.comment ?: @"";
        [self updateInfoView];
    }
}


// The only essential/required tableview dataSource method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    if(tableView==self.pageTableView)
    {
        return [self.displayConfiguration.pages count];
    }
    else
    {
        return [self.displayConfiguration.sounds count];
    }
    
}


// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString* key = nil;
    double ram = 0;
    double flash = 0;

    if(tableView==self.pageTableView)
    {
        WFDisplayPage* displayPage = [self.displayConfiguration.pages objectAtIndex:row];

        key = displayPage.key;
        ram = [self.memoryCalculator ramUsageForDisplayPage:displayPage];
        flash = [self.memoryCalculator flashUsageForDisplayPage:displayPage];
    }
    else
    {
        WFDisplaySound* displaySound = [self.displayConfiguration.sounds objectAtIndex:row];
        key = displaySound.key;
    }
    
    
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"MainCell"]) {
        
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = key;
        return cellView;
        
    } else if ([identifier isEqualToString:@"RAMSizeCell"]) {
        
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [NSString stringWithFormat:@"%1.1f%%", ram*100.0];;
        return textField;
        
    } else if ([identifier isEqualToString:@"FlashSizeCell"]) {
        
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [NSString stringWithFormat:@"%1.1f%%", flash*100.0];
        return textField;
        
    } else if ([identifier isEqualToString:@"PlayerCell"]) {
        
        NSButton *button = [tableView makeViewWithIdentifier:identifier owner:self];
        button.tag = row;
        return button;
        
    } else {
       // NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }    
    
    return nil;
}



@end
