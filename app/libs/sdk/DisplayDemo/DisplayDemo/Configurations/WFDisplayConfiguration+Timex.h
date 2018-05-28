//
// Created by Murray Hughes on 24/08/15.
// Copyright (c) 2015 Wahoo Fitness. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFDisplayConfiguration (Timex)


// Loads a JSON config from file and injects a few specific Timex elements
+ (WFDisplayConfiguration*) timeConfigurationWithContentsOfFile:(NSString*) filename;

@end