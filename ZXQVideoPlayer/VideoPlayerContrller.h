//
//  VideoPlayerContrller.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/25.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "ZVideoView.h"

@interface VideoPlayerContrller : UIViewController

@property (nonatomic, strong) ZVideoView *zView;

@property (nonatomic, assign)   ViewController *vc;

@end
