//
//  ZVideoControlView.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoControlView.h"
#import "ZVideoSliderView.h"

@implementation ZVideoControlView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {

    [self initSlider];
    [self initButton];
    [self initCurrentTimeLabel];
  }
  return self;
}

#pragma mark - 进度条
- (void)initSlider
{
  CGFloat y = CGRectGetHeight(self.frame) - 28;
  _slideView = [[ZVideoSliderView alloc] initWithFrame:
              CGRectMake(100, y, self.frame.size.width - 230, kVideoSlideHeight)];
  _slideView.value = 0.5;
  [self addSubview:_slideView];

}

#pragma mark - 播放和下一首按钮
- (void)initButton
{
  _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _playButton.frame = CGRectMake(15, CGRectGetHeight(self.frame) - 40, 30, 30);
  [self addSubview:_playButton];
  if (_rate == 1.0) {
    
    [_playButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn@2x.png"] forState:UIControlStateNormal];
  } else {
    [_playButton setBackgroundImage:[UIImage imageNamed:@"playBtn@2x.png"] forState:UIControlStateNormal];
    
  }
  
  _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _forwardButton.frame = CGRectMake(60, CGRectGetHeight(self.frame) - 38, 25, 25);
  [self addSubview:_forwardButton];
  [_forwardButton setBackgroundImage:[UIImage imageNamed:@"nextPlayer@3x.png"] forState:UIControlStateNormal];
  
  
}

#pragma mark - 创建播放时间label
- (void)initCurrentTimeLabel
{
  _currentTimeLabel = [[UILabel alloc]initWithFrame:
            CGRectMake(self.frame.size.width *0.88 - 25, CGRectGetHeight(self.frame) - 35.5, 150, 20)];
  [self addSubview:_currentTimeLabel];
  _currentTimeLabel.textColor = [UIColor whiteColor];
  //    _currentTimeLabel.backgroundColor = [UIColor blueColor];
  _currentTimeLabel.font = [UIFont systemFontOfSize:12];
  _currentTimeLabel.text = @"00:00:00/00:00:00";
  
  
}

#pragma mark -
#pragma mark 布局
- (void)layoutSubviews
{
  CGFloat y = CGRectGetHeight(self.frame) - 28;
  _slideView.frame = CGRectMake(100, y, self.frame.size.width - 230, kVideoSlideHeight);
  _playButton.frame = CGRectMake(15, CGRectGetHeight(self.frame) - 40, 30, 30);
  _forwardButton.frame = CGRectMake(60, CGRectGetHeight(self.frame) - 38, 25, 25);
  
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (UIInterfaceOrientationPortrait == orientation) {
    
    _currentTimeLabel.frame = CGRectMake(self.frame.size.width * 0.88 - 25, CGRectGetHeight(self.frame) - 35.5, 150, 20);
  }
  else {
    
    _currentTimeLabel.frame = CGRectMake(self.frame.size.width *0.88, CGRectGetHeight(self.frame) - 35.5, 150, 20);
  }

  [_slideView setNeedsLayout];
}

@end
