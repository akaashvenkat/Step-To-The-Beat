//
//  WFDisplaySoundsDemoVC.m
//  DisplayDemo
//
//  Created by Murray Hughes on 10/10/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFDisplaySoundsDemoVC.h"

@interface WFDisplaySoundsDemoVC ()

@end

@implementation WFDisplaySoundsDemoVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.displayConnection loadConfiguration:[self displayConfiguration]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (WFDisplayConfiguration*) displayConfiguration
{
    static WFDisplayConfiguration* config = nil;
    
    if(config==nil)
    {
        NSString* configPath = nil;
        
        if(self.displayConnection.sensorSubType == WF_SENSOR_SUBTYPE_DISPLAY_CASIO_TYPE1)
        {
            configPath = [[NSBundle mainBundle] pathForResource:@"Sounds-Casio" ofType:@"json"];
        }
        else if(self.displayConnection.sensorSubType == WF_SENSOR_SUBTYPE_DISPLAY_ECHO)
        {
            configPath = [[NSBundle mainBundle] pathForResource:@"Sounds-Echo" ofType:@"json"];
        }
        else if(self.displayConnection.sensorSubType == WF_SENSOR_SUBTYPE_DISPLAY_TIMEX_RUN_X50)
        {
            configPath = [[NSBundle mainBundle] pathForResource:@"Sounds-Dev1" ofType:@"json"];
        }

        config = [WFDisplayConfiguration instanceWithContentsOfFile:configPath];
    }
    
    return config;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self displayConfiguration].sounds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    WFDisplaySound* sound = [self displayConfiguration].sounds[indexPath.row];
    
    cell.textLabel.text = sound.key;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WFDisplaySound* sound = [self displayConfiguration].sounds[indexPath.row];
    
    [self.displayConnection playSoundWithKey:sound.key];
    
}


@end
