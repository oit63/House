//
//  ViewController.m
//  House
//
//  Created by yons on 15/8/13.
//  Copyright (c) 2015年 Leeds. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
{
    int lightIsOn;
}
@property (weak, nonatomic) IBOutlet UIButton *light;
@property (strong) GCDAsyncSocket *socket;
@property (nonatomic,retain) NSTimer *connectTimer;
@property (nonatomic) NSString *shortAddress;

@end

@implementation ViewController
@synthesize socket;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Make connection with server
    // if connected
//    [self connected];
    // Server would return the status of the lamp
    // If the lamp is lighed on, the switch must be on
    // else if it should be off
    // And the is the interaction between the server and the lamp switcher

    // try connected to the socket
//    [self.server addTarget:self action:@selector(switchIsChanged:) forControlEvents:UIControlEventValueChanged];
//    NSString *string = @"*LFD8820OFFOK";
//    NSLog(@"*LFD8820OFFOK %@", [ length]);
//    NSLog(@"%@",[@"*L123420ONOK/n" substringWithRange:NSMakeRange(0, 2)]);
    
}
#pragma mark - Socket
- (void)openSocket:(NSString *)host onPort:(int)port {
    socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    socket.delegate = self;
    NSError *err = nil;
    if (![socket connectToHost:host onPort:port error:&err]) {
        NSLog(@"%@",err.description);
        [self alertTitle:@"Warning" message:@"Connect failure, please try again later."];
    } else {
        NSLog(@"Open Port");
        [socket readDataWithTimeout:-1 tag:0];
        NSLog(@"Ready for I/O");
    }
}

#pragma mark Socket Callback Methods -

#pragma mark Connected
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"Did Connected");
    [self.routerImageView setImage:[UIImage imageNamed:@"device_router_mini_on_icon"]];
    [self requestShortAddress];
//    self.server.on = YES;
//    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(longConnect) userInfo:nil repeats:YES];
//    [self.connectTimer fire];
}

#pragma mark  ReadData
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{

    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Message writed is %@",message);
    [self messagePipe:message];

    [socket readDataWithTimeout:-1 tag:0];
}
#pragma mark  Disconnected
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"Did Disconnected");
    [self.routerImageView setImage:[UIImage imageNamed:@"device_router_mini_off_icon"]];
}


#pragma mark - Buttons

- (IBAction)lightButtonPressed:(id)sender {
    NSString *message;
    if (self.shortAddress) {
        if (!lightIsOn) {
            message = [NSString stringWithFormat:@"#L%@20ON",self.shortAddress];
        } else {
            message = [NSString stringWithFormat:@"#L%@20OFF",self.shortAddress];
        }
        [self writeMessage:message];
    } else {
        [self alertTitle:@"Warning" message:@"Server have not send short Adress back"];
    }
}
- (IBAction)waterButtonPressed:(id)sender {
//    [self.waterImageView setImage:[UIImage imageNamed:@"device_waterpurifier_on_icon"]];
}
- (IBAction)routerButtonPressed:(id)sender {
    [self openSocket:HOST onPort:PORT];
}
#pragma mark - I/O

#pragma mark - module

//- (void)dealWithMessage: (NSString *)recievedMessage {
//    BOOL (^judgeMessage) () = ^() {
//        if ([recievedMessage isEqualToString:@"*LDX41SF20ON"]) {
//            // Let the light on
//            return  YES;
//        } else {
//            return  NO;
//        }
//    };
//    self.lamp.on = judgeMessage();
//}

//to store the short address temperally
- (void)messagePipe:(NSString *)message {
    NSLog(@"message is %@",message);
    if ([[message substringToIndex:8] isEqualToString:@"*DEVADDR"]) {
        self.shortAddress = [message substringWithRange:NSMakeRange(8, 4)];
    }
    NSLog(self.shortAddress);
    
    NSString *status;
    if ([[message substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"*L"]) {
        
        status = [message substringWithRange:NSMakeRange(8, 4)];
    }
    
    NSLog(@"*DEVADDR status is %@",status);
    
    if ([status isEqualToString:@"ONOK"]) {
        lightIsOn = 1;
        [self.lightImageView setImage:[UIImage imageNamed:@"device_light_on_icon"]];
    } else if ([status isEqualToString:@"OFFO"] ) {
        lightIsOn = 0;
        [self.lightImageView setImage:[UIImage imageNamed:@"device_light_off_icon"]];
    }
    
//    
//    if ( [message isEqualToString:REAL_LAMP_ON]) {//@"来自S：灯已打开"
//        self.lamp.on = YES;
//    } else if ( [message isEqualToString:REAL_LAMP_OFF]) {//@"来自S：灯已关闭"
//        self.lamp.on = NO;
//    }
//    [self showStatus:message];
    
}
- (void)requestShortAddress {
    [self writeMessage:@"*REQDEVID"];
}
- (void)storeAddress:(NSString *)address {
    self.shortAddress = address;
}

// to show an alert when given a string
- (void)alertTitle:(NSString *)Title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
    [alert show];
}
- (void)writeMessage:(NSString *)message {
    NSLog(@"Message writed is %@",message);
    [socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [socket readDataWithTimeout:-1 tag:0];
}
#pragma mark - OldEdition Swithers
- (IBAction)pressButton:(UISwitch *)sender {
    [self openSocket:nil];
    NSString *message;
    if (sender.isOn) {
        message = CLIENT_LAMP_ON;//@"客户端请求开灯"
        //            self.realLamp.on = YES;
    } else {
        message = CLIENT_LAMP_OFF;//客户端请求关灯
        //            self.realLamp.on = NO;
    }
    [self sendMessageToRemote:message];
}
- (IBAction)touchWater:(UISwitch *)sender {
        [self openSocket:nil];

    NSString *message;
    if (sender.isOn) {
        message = WATER_LAMP_ON;//@"客户端请求开灯"
        //            self.realLamp.on = YES;
    } else {
        message = WATER_LAMP_OFF;//客户端请求关灯
        //            self.realLamp.on = NO;
    }
    [self sendMessageToRemote:message];
}


- (IBAction)touchSwitch:(UISwitch *)sender {
    //  Touch it and use it's value to judge whether it connected to server
    //  if it is off
    //  call sendMessage method to tell the server to light on the lamp
    // If the lamp is on, server would return a command that says lamp is lighted on
    //  Dealling with the messages
    //  If found the light on command
    //  set the switch value to be on
    // If the lamp is off, server would
//    void (^sendMessage) () = ^() {
        // call Socket message to write data to server
        // In socket method didReadData should call judgeMessage
//    };
//    [self dealWithMessage:nil];
    
    // If the server is connected
    // I could toggle the lamp switcher
    // when I do the things the real lamp should be do in the same way
    // else my toggling would be blocked
    
    /*
     after connected to the server
     when I toggled the switcher, it would send message to the server
     to told server to toggle the lamp
     when the lamp is on or off the server would return the result 
     and the client recieved it to determine reflecting the status of the real lamp
     */
    // make a string
    NSString *message;

    

    if (self.server.isOn) {
        if (sender.isOn) {
            message = CLIENT_LAMP_ON;//@"客户端请求开灯"
//            self.realLamp.on = YES;
        } else {
            message = CLIENT_LAMP_OFF;//客户端请求关灯
//            self.realLamp.on = NO;
        }
    } else {
        sender.on = NO;
        // the message would show the connection status
        // to tell the user why it can't be toggled
        self.connectionStaus.text = DISCONNECTED;
    }
    [self sendMessageToRemote:message];
//    message = [self sendMessage:message];
    self.connectionStaus.text = message;
    // if server haved done the actions, it would return a string named *LDX$1SF20ON
    // I should check the status of my switch, try to keep up with the status of real lamp
    // then after 3 seconds the text would be disapear
    
}

- (IBAction)openSocket:(id)sender {
    if (!self.server.isOn) {
        [self openSocket:HOST onPort:PORT];
        
    }
    [socket readDataWithTimeout:-1 tag:0];
    
}

#pragma mark - OldEdition I/O
// connected to server
/*if did connected*/
- (void)connected {
    // when connected to server
    // the switcher must be display it's status accoringding the message from server
    // I would send message to look up of the status of the lamp
    // Simulates that did read message
//    [self didReadMessage];
}


// ready for recieve message from server
/**/
- (void)didReadMessage:(NSString*)message{
    // when recieved the status message

    // the swither would display if the command is recieved
//    [self dealWithMessage:recievedMessage];
    // if read the data from the server that real lamp is on ,
    // it should tell the lamp turn to be on.

    if ( [message isEqualToString:REAL_LAMP_ON]) {//@"来自S：灯已打开"
        self.lamp.on = YES;

    } else if ( [message isEqualToString:REAL_LAMP_OFF]) {//@"来自S：灯已关闭"
        self.lamp.on = NO;
    }
    [self showStatus:message];
    // else is ok
}

// read message passed from server

// call dealSignal method to deal with judgeMessage Block commands


- (NSString *)sendMessage:(NSString *)message {
    return [self serverActionsAccordingMessage:message];
    
}
- (void)sendMessageToRemote:(NSString *)message {
    [socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [socket readDataWithTimeout:-1 tag:0];
}
#pragma mark - OldEdition Module
- (void)showStatus:(NSString *)message {
    if ( [message isEqualToString:REAL_LAMP_ON]) {//@"来自S：灯已打开"
        self.connectionStaus.text = @"来自S：灯已打开";//@"来自S：灯已打开"
    }
    if ( [message isEqualToString:REAL_LAMP_OFF]) {//@"来自S：灯已关闭"
        self.connectionStaus.text = @"来自S：灯已关闭";//@"来自S：灯已关闭"
    }
}


#pragma mark - Server
- (IBAction)toggleServer:(UISwitch *)sender {
    // seek the status of the real lamp
    // If the status of real lamp is on before turn on the server, it would turn the client on when connected
    // but when the server is disconnected to the client
    // it would do nothing
    // Once connected again it would say the status of the lamp to the client
    if (sender.isOn) {
        // Simulate that the server is connected
        // The client would display the message
        self.connectionStaus.text = @"已链接到服务器";//@"已链接到服务器"
        if (self.realLamp.isOn) {
            self.lamp.on = YES;
        } else {
            self.lamp.on = NO;
        }
    } else {
        self.connectionStaus.text = @"与服务器断开连接";//@"与服务器断开连接"
    }
}

- (IBAction)toggleRealLamp:(UISwitch *)sender {
    /* when the lamp is on and the server is connected and the command is right
     the lampcontroller is on
     else the lampController is off
     that would be judged when the real lamp is toglled or server is toggled
    */

    NSString *message;
    if (self.server.isOn) {
         if (sender.isOn) {
//             self.lamp.on = YES;
             // show in the client
             message = REAL_LAMP_ON;//@"灯已打开"
         } else {
//             self.lamp.on = NO;
             message = REAL_LAMP_OFF;//@"灯已关闭"
             // and would send the message to the client
         }
         [self serverSendMessage:message];
     }
}

- (void)serverSendMessage:(NSString *)message {
//    message = [NSString stringWithFormat:@"来自S：%@",message];//来自S：灯已关闭/灯已打开
    [self didReadMessage:message];
}

- (NSString *)serverActionsAccordingMessage:(NSString *)message {
    // make a string
    NSLog(@"%@",message);
    if ([message isEqualToString:CLIENT_LAMP_ON]) {//@"客户端请求开灯"
        self.realLamp.on = YES;
        message =  @"请求成功";//@"请求成功"
    } else if ([message isEqualToString:CLIENT_LAMP_OFF]) {//@"客户端请求关灯"
        self.realLamp.on = NO;
        message =  @"请求成功";//@"请求成功"
    } else {
        message =  @"请求失败";//@"请求成功"
    }
    
    return message;
;
}
#pragma mark - MemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
