//
//  ViewController.h
//  House
//
//  Created by yons on 15/8/13.
//  Copyright (c) 2015年 Leeds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "Definations.h"

@interface ViewController : UIViewController<GCDAsyncSocketDelegate>
@property (strong, nonatomic) IBOutlet UISwitch *lamp;
@property (weak, nonatomic) IBOutlet UISwitch *server;
@property (weak, nonatomic) IBOutlet UISwitch *realLamp;

#pragma mark - Buttons
@property (weak, nonatomic) IBOutlet UIButton *LightSwitch;
@property (weak, nonatomic) IBOutlet UIButton *WaterSwitch;

#pragma mark - Devices
@property (weak, nonatomic) IBOutlet UIImageView *lightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *waterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *routerImageView;

@property (weak, nonatomic) IBOutlet UILabel *connectionStaus;
@property (weak, nonatomic) IBOutlet UISwitch *water;

@end

