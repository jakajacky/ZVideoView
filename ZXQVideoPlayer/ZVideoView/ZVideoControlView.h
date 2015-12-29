//
//  ZVideoControlView.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZVideoSliderView.h"

#define kVideoControlHeight 55

#define kVideoSlideHeight 6.0

@interface ZVideoControlView : UIView

@property (nonatomic,assign ) NSTimeInterval   currentTime;
@property (nonatomic,assign ) NSTimeInterval   duration;

@property (nonatomic,strong ) ZVideoSliderView *slideView;
@property (nonatomic,strong ) UILabel          *currentTimeLabel;

@property (nonatomic,strong ) UIButton         *playButton;
@property (nonatomic,strong ) UIButton         *forwardButton;
@property (nonatomic, strong) UIProgressView   *progress;        // 缓冲

@end
