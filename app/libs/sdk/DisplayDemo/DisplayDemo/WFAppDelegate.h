//
//  WFAppDelegate.h
//  RFLKDemo
//
//  Created by Murray Hughes on 7/09/12.
//  Copyright (c) 2012 Wahoo Fitness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFAppDelegate : UIResponder <UIApplicationDelegate, WFHardwareConnectorDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (NSString *)applicationDocumentsDirectory;

@end
