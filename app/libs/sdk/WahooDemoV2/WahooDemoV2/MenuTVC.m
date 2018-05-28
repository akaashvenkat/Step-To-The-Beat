//
//  ViewController.m
//  WahooDemoV2
//
//  Created by Murray Hughes on 3/12/2014.
//  Copyright (c) 2014 Wahoo Fitness. All rights reserved.
//

#import "MenuTVC.h"
#import <WFConnector/WFConnector.h>

@interface MenuTVC ()

@property (weak, nonatomic) IBOutlet UITableViewCell *apiVersionCell;
@end

@implementation MenuTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    self.apiVersionCell.detailTextLabel.text = [WFHardwareConnector sharedConnector].apiVersion;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
