//
//  WFDisplayDemoStandard.h
//  DisplayDemo
//
//  Created by Murray Hughes on 4/01/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFDisplayDemoStandard : UITableViewController <WFDisplayConnectionDelegate>

@property (strong, nonatomic) WFDisplayConnection* displayConnection;

@property (weak, nonatomic) IBOutlet UISlider *heartrateSlider;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UISlider *powerSlider;
@property (weak, nonatomic) IBOutlet UISlider *cadenceSlider;

@property (weak, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerLabel;
@property (weak, nonatomic) IBOutlet UILabel *cadenceLabel;

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;

@property (weak, nonatomic) IBOutlet UILabel *memoryCurrentLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoryRFLKTv1Label;
@property (weak, nonatomic) IBOutlet UILabel *memoryRFLKTv2Label;
@property (weak, nonatomic) IBOutlet UILabel *memoryEchoV1Label;

@property (weak, nonatomic) IBOutlet UIButton *autoScrollButton;
@property (weak, nonatomic) IBOutlet UISlider *autoScrollSlider;

@property (weak, nonatomic) IBOutlet UISwitch *invertedSwitch;

- (void) showAlert:(NSString*) msg;

- (IBAction)loadConfigTouched:(UIButton*)sender;

- (IBAction)startUpdatesTouched:(UIButton*)sender;

- (IBAction)showHiddenPageTouched:(UIButton*)sender;
- (IBAction)showAlertWithCustomSound:(id)sender;
- (IBAction)playSoundTouched:(id)sender;

- (IBAction)sliderValueChanged:(UISlider*)sender;

- (IBAction)backlightSwitchChanged:(UISwitch *)sender;

- (IBAction)invertedSwitchedChanged:(UISwitch *)sender;

- (IBAction)setBacklightOnWithTimeoutTouched:(id)sender;

- (IBAction)setAutoPageScroll:(id)sender;
- (IBAction)autoPageSliderChanged:(UISlider *)sender;

@end
