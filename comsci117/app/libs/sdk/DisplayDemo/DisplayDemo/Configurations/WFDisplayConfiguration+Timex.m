//
// Created by Murray Hughes on 24/08/15.
// Copyright (c) 2015 Wahoo Fitness. All rights reserved.
//

#import "WFDisplayConfiguration+Timex.h"


@implementation WFDisplayConfiguration (Timex)


+ (WFDisplayConfiguration*) timeConfigurationWithContentsOfFile:(NSString*) filename
{
    WFDisplayConfiguration* config = [WFDisplayConfiguration instanceWithContentsOfFile:filename];

    // Get the number of non-hidden pages, this is so we can inject the right number of page indicators.
    NSUInteger visiblePageCount = [config.pages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hidden == NO"]].count;
    int pageIdx = 0;

    for(WFDisplayPage* displayPage in config.pages) {

        for (WFDisplayElement* element in displayPage.elements) {

            // ---------------------------------------------------------
            // Inject the Timex Page Indicators
            if (!displayPage.hidden) {
                if ([element isKindOfClass:[WFDisplayElementGroup class]] && [element.key isEqualToString:@"TimexPageIndicators"]) {

                    WFDisplayElementGroup *group = (WFDisplayElementGroup *) element;
                    [group removeAllElements];

                    for (int i = 0; i < visiblePageCount; i++) {
                        BOOL currentPage = (i == pageIdx);
                        WFDisplayElementRect *rect = [WFDisplayElementRect new];
                        rect.frame = CGRectMake(120, 4 + (6 * i), (currentPage) ? 8 : 1, 4);
                        rect.fillColor = (currentPage) ? WF_DISPLAY_COLOR_BLACK : WF_DISPLAY_COLOR_NONE;
                        [group addElement:rect];
                    }

                    pageIdx++;
                }
            }

            // ---------------------------------------------------------
            // Inject the Timex Control bar
            if([element isKindOfClass:[WFDisplayElementGroup class]] && [element.key isEqualToString:@"TimexControlBar"])
            {

                WFDisplayElementGroup* group = (WFDisplayElementGroup*)element;

                if(group.elements.count==0) {

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
        }
    }

    return config;
}

@end