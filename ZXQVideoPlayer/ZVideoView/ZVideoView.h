//
//  ZVideoView.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZVideoControlView.h"
#define kVideoNaviHeight 44

@interface ZVideoView : UIView

@property (nonatomic, strong) ZVideoControlView *controlView;// 控制台

- (void)play;

- (void)setPath:(NSString *)path;

- (void)setTitle:(NSString *)title;

- (void)showActionView;

- (void)doubleTapAction;

@end
