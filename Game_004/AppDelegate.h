//
//  AppDelegate.h
//  Game_004
//
//  Created by 寺内 信夫 on 2014/09/29.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MCPeerID *myPeerID;
@property (strong, nonatomic) MCSession *session;

@property (strong, nonatomic) NSMutableArray *array_ServerID;
@property (strong, nonatomic) NSMutableArray *array_ClientID;

@end

