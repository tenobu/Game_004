//
//  GameViewController.h
//  Game_002
//

//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <SceneKit/SceneKit.h>

@interface GameViewController : UIViewController < MCSessionDelegate >
{
	
}

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

@end
