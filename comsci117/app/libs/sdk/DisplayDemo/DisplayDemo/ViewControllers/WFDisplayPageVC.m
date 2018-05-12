//
//  WFDisplayPageViewController.m
//  DisplayDemo
//
//  Created by Murray Hughes on 30/07/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFDisplayPageVC.h"

@interface WFDisplayPageVC ()

@property (nonatomic, assign) NSUInteger pageIndex;

@end

@implementation WFDisplayPageVC


#pragma mark -
#pragma mark View Life Cycle


- (void)viewDidUnload {
    [self setDisplayPageView:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateDisplayPageView];
}

#pragma mark -
#pragma mark UI Updates

- (void) updateDisplayPageView
{
    WFDisplayPage* page = [self.displayConfiguration.pages objectAtIndex:self.pageIndex];

    self.displayPageView.sensorSubType = self.sensorSubType;
    self.displayPageView.page = page;
}

#pragma mark -
#pragma mark UI Actions

- (IBAction)previousPageButtonTouched:(id)sender
{
    if(self.pageIndex==0)
    {
        self.pageIndex = [self.displayConfiguration.pages count]-1;
    }
    else
    {
        self.pageIndex--;
    }

    [self updateDisplayPageView];
}


- (IBAction)nextPageButtonTouched:(id)sender
{
    if(self.pageIndex==([self.displayConfiguration.pages count]-1))
    {
        self.pageIndex = 0;
    }
    else
    {
        self.pageIndex++;
    }
    
    [self updateDisplayPageView];
}
@end
