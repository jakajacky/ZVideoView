//
//  ZVideoControlView.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoControlView.h"
#import "ZVideoSliderView.h"
#import "ZVideoUtilities.h"
#import <AVFoundation/AVFoundation.h>
@interface ZVideoControlView ()

@end

@implementation ZVideoControlView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor colorWithWhite:0.122 alpha:0.5];
    
    [self initSlider];
    [self initButton];
    [self initCurrentTimeLabel];
  }
  return self;
}

#pragma mark -
#pragma mark 进度条
- (void)initSlider
{
  CGFloat y = CGRectGetHeight(self.frame) - 28;
  
  // 缓冲区
  self.progress = [[UIProgressView alloc] initWithFrame:
                   CGRectMake(102, y + 2, self.frame.size.width - 234, kVideoSlideHeight)];
  [self addSubview:_progress];

  // 进度条
  _slideView = [[ZVideoSliderView alloc] initWithFrame:
              CGRectMake(100, y, self.frame.size.width - 230, kVideoSlideHeight)];
  _slideView.value = 0.0;
  [self addSubview:_slideView];

  [self customVideoSlider];
}

#pragma mark 播放和下一首按钮
- (void)initButton
{
  _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _playButton.frame = CGRectMake(15, CGRectGetHeight(self.frame) - 40, 30, 30);
  [self addSubview:_playButton];
  
  _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _forwardButton.frame = CGRectMake(60, CGRectGetHeight(self.frame) - 38, 25, 25);
  [self addSubview:_forwardButton];
  [_forwardButton setBackgroundImage:[UIImage imageNamed:@"nextPlayer@3x.png"]
                            forState:UIControlStateNormal];
  
  
}

#pragma mark 创建播放时间label
- (void)initCurrentTimeLabel
{
  _currentTimeLabel = [[UILabel alloc]initWithFrame:
            CGRectMake(self.frame.size.width *0.88, CGRectGetHeight(self.frame) - 35.5, 150, 20)];
  [self addSubview:_currentTimeLabel];
  _currentTimeLabel.textColor = [UIColor whiteColor];
  //    _currentTimeLabel.backgroundColor = [UIColor blueColor];
  _currentTimeLabel.font = [UIFont systemFontOfSize:12];
  _currentTimeLabel.text = @"00:00:00/00:00:00";
  
}

#pragma mark UISlider自定义
- (void)customVideoSlider {
  UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
  UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
//  [self.slideView.slider setMinimumTrackTintColor:[UIColor col]];
  //    [self.slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
  [self.slideView setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark 设置总时间
- (void)setDuration:(NSTimeInterval)duration
{
  _duration = duration;
  
  NSArray *ranges = [self getRangesWithString];
  
  _currentTimeLabel.text =
  [_currentTimeLabel.text stringByReplacingCharactersInRange:[ranges[1] rangeValue]
                                                  withString:TimeStringWithSeconds(_duration)];
  if (_duration > 0) {
    _slideView.value = _currentTime / _duration;
  }
  else {
    _slideView.value = 0;
  }
}

#pragma mark 设置当前时间
- (void)setCurrentTime:(NSTimeInterval)currentTime
{
  _currentTime = currentTime;
  
  NSArray *ranges = [self getRangesWithString];
  
  _currentTimeLabel.text =
  [_currentTimeLabel.text stringByReplacingCharactersInRange:[ranges[0] rangeValue]
                                                  withString:TimeStringWithSeconds(_currentTime)];
  if (_duration) {
    _slideView.value = _currentTime / _duration;
  }
  else {
    _slideView.value = 0;
  }
}

#pragma mark -
#pragma mark 布局
- (void)layoutSubviews
{
  CGFloat y = CGRectGetHeight(self.frame) - 28;
  _slideView.frame = CGRectMake(100, y, self.frame.size.width - 230, kVideoSlideHeight);
  _playButton.frame = CGRectMake(15, CGRectGetHeight(self.frame) - 40, 30, 30);
  _forwardButton.frame = CGRectMake(60, CGRectGetHeight(self.frame) - 38, 25, 25);
  _progress.frame = CGRectMake(102, y + 2, self.frame.size.width - 234, kVideoSlideHeight);
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (UIInterfaceOrientationPortrait == orientation) {
    
    _currentTimeLabel.frame = CGRectMake(self.frame.size.width * 0.88 - 25, CGRectGetHeight(self.frame) - 35.5, 150, 20);
  }
  else {
    
    _currentTimeLabel.frame = CGRectMake(self.frame.size.width *0.88, CGRectGetHeight(self.frame) - 35.5, 150, 20);
  }

  [_slideView setNeedsLayout];
}

#pragma mark -
#pragma mark private
- (NSArray *)getRangesWithString
{
  NSArray *timeLabel = [_currentTimeLabel.text componentsSeparatedByString:@"/"];
  NSRange range1 = [_currentTimeLabel.text rangeOfString:timeLabel[0]];
  NSRange range2 = [_currentTimeLabel.text rangeOfString:timeLabel[1]];
  
  NSValue *value1 = [NSValue valueWithRange:range1];
  NSValue *value2 = [NSValue valueWithRange:range2];
  
  return @[value1, value2];
}

@end
