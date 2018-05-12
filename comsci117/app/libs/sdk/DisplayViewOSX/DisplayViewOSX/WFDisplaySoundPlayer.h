//
//  WFDisplaySoundPlayer.h
//  WFConnector
//
//  Created by Murray Hughes on 25/08/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WFConnector/hardware_connector_types.h>

@class WFDisplaySound;

@interface WFDisplaySoundPlayer : NSObject

@property (nonatomic, assign) WFSensorSubType_t sensorSubType;

@property (nonatomic, assign, readonly, getter = isPlaying) BOOL playing;

- (void) playSound:(WFDisplaySound*) sound;

- (void) playSoundValue:(NSString*) soundValue;

- (void) stop;


@end
