//
//  ViewController.h
//  Game_004
//
//  Created by 寺内 信夫 on 2014/09/29.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController : UIViewController < MCSessionDelegate >

@property (weak, nonatomic) IBOutlet UILabel *label_MyTensu;

@property (weak, nonatomic) IBOutlet UILabel *label_Other_1;
@property (weak, nonatomic) IBOutlet UILabel *label_OthersTensu_1;
@property (weak, nonatomic) IBOutlet UILabel *label_Other_2;
@property (weak, nonatomic) IBOutlet UILabel *label_OthersTensu_2;
@property (weak, nonatomic) IBOutlet UILabel *label_Other_3;
@property (weak, nonatomic) IBOutlet UILabel *label_OthersTensu_3;
@property (weak, nonatomic) IBOutlet UILabel *label_Other_4;
@property (weak, nonatomic) IBOutlet UILabel *label_OthersTensu_4;
@property (weak, nonatomic) IBOutlet UILabel *label_Other_5;
@property (weak, nonatomic) IBOutlet UILabel *label_OthersTensu_5;
@property (weak, nonatomic) IBOutlet UILabel *label_Other_6;
@property (weak, nonatomic) IBOutlet UILabel *label_OthersTensu_6;
@property (weak, nonatomic) IBOutlet UILabel *label_Other_7;
@property (weak, nonatomic) IBOutlet UILabel *label_OthersTensu_7;

@property (weak, nonatomic) IBOutlet UILabel *label_Error;

@end

