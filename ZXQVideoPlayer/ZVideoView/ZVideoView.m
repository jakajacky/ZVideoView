//
//  ZVideoView.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ZVideoControlView.h"
#import "ZVideoNaviView.h"

@interface ZVideoView () <ZVideoSliderViewDelegate>

@property (nonatomic, strong) AVPlayer          *player;// 播放属性

@property (nonatomic, strong) AVPlayerItem      *playerItem;

@property (nonatomic, strong) AVPlayerLayer     *playerLayer;

@property (nonatomic, assign) CGFloat           width;// 坐标

@property (nonatomic, assign) CGFloat           height;// 坐标

@property (nonatomic, strong) ZVideoControlView *controlView;// 控制台

@property (nonatomic, strong) ZVideoNaviView    *naviBack;// 返回

@property (nonatomic, assign) BOOL              isPlayingBeforeDrag; //滑动前是否是播放状态

@property (nonatomic, strong) NSTimer           *timer;

//@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"

@end

@implementation ZVideoView

static int controlViewHideTime = 0;

#pragma mark -
#pragma mark Initializations
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _width = self.frame.size.width;
    _height = self.frame.size.height;
  
    [self initPlayer];
    [self initControlView];
    [self initNaviBackView];
    [self initTapGesture];
    [self initTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
  }
  return self;
}

#pragma mark 创建player
- (void)initPlayer
{
  // 创建AVPlayer
  
  self.player = [[AVPlayer alloc] init];
  
  _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
  _playerLayer.frame = CGRectMake(0, 0, _width, _height);
  _playerLayer.videoGravity = AVLayerVideoGravityResize;
  [self.layer addSublayer:_playerLayer];
  
}

#pragma mark 创建控制台
- (void)initControlView
{
  CGFloat y = CGRectGetMaxY(self.frame) - kVideoControlHeight;
  _controlView = [[ZVideoControlView alloc] initWithFrame:
                  CGRectMake(0, y, self.frame.size.width, kVideoControlHeight)];
  
  [_controlView.playButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
  // 默认
  [_controlView.playButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn@2x.png"] forState:UIControlStateNormal];
  _controlView.playButton.selected = NO;
  
  
  [_controlView.forwardButton addTarget:self action:@selector(unKownAction) forControlEvents:UIControlEventTouchUpInside];
  
  _controlView.slideView.delegate = self;
  
  [self addSubview:_controlView];
}

#pragma mark 创建返回栏
- (void)initNaviBackView
{
  _naviBack = [[ZVideoNaviView alloc] initWithFrame:
               CGRectMake(0, 0, self.frame.size.width, kVideoNaviHeight)];

  [self addSubview:_naviBack];
}

#pragma mark 创建轻拍手势
- (void)initTapGesture
{
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(showActionView:)];
  [self addGestureRecognizer:tap];
}

#pragma mark 创建计时器
- (void)initTimer
{
  //计时器
  _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
}

#pragma mark -
#pragma mark 设置路径
- (void)setPath:(NSString *)path
{
  self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:path]];
  [self.player replaceCurrentItemWithPlayerItem:_playerItem];
}

#pragma mark 设置标题
- (void)setTitle:(NSString *)title
{
  _naviBack.title = title;
}

#pragma mark - 
#pragma mark 响应播放事件
- (void)playOrPause
{
  if (_controlView.playButton.selected) {
    [self play];
  } else {
    [self pause];
  }
  _controlView.playButton.selected =!_controlView.playButton.selected;
}
- (void)play
{
  controlViewHideTime = 0;
  [_controlView.playButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn@2x.png"] forState:UIControlStateNormal];
  
  if (![_timer isValid]) {
    [self initTimer];
  }
  [_timer fire];
  
  [self.player play];
}

- (void)pause
{
  controlViewHideTime = 0;
  [_controlView.playButton setBackgroundImage:[UIImage imageNamed:@"playBtn@2x.png"] forState:UIControlStateNormal];
  
  [_timer invalidate];
  
  [self.player pause];
  
  // 暂停后需自动隐藏控制台
  [self autoHiddenActionView];
  
}

#pragma mark 响应轻拍事件
- (void)showActionView:(UITapGestureRecognizer *)sender
{
  controlViewHideTime = 0;
  if (_controlView.alpha == 1) {
    [UIView animateWithDuration:0.5 animations:^{
      
      _controlView.alpha = 0;
      _naviBack.alpha = 0;
    }];
  } else if (_controlView.alpha == 0){
    [UIView animateWithDuration:0.5 animations:^{
      
      _controlView.alpha = 1;
      _naviBack.alpha = 1;
    }];
  }
  
  if (_controlView.playButton.selected) {
    [self autoHiddenActionView];
  }
}

#pragma mark 隐藏控制台
- (void)hiddenActionView
{
  [UIView animateWithDuration:0.5 animations:^{
    
    _controlView.alpha = 0;
    _naviBack.alpha = 0;
  }];
}

#pragma mark 7s之后自动隐藏
- (void)autoHiddenActionView
{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self hiddenActionView];
  });
}

#pragma mark 响应next事件
- (void)unKownAction
{
  //
}

#pragma mark 响应timer
- (void)timeRun
{
  controlViewHideTime++;
  if (_playerItem.duration.timescale != 0) {
    
    CMTime currentTime = self.player.currentTime;
    CMTime duration    = self.playerItem.duration;
    _controlView.currentTime = CMTimeGetSeconds(currentTime);
    _controlView.duration    = duration.value / duration.timescale;
    _controlView.value       = _controlView.currentTime / _controlView.duration;//当前进度
    
  }
  if (_player.status == AVPlayerStatusReadyToPlay) {
    // 等待加载中
  } else {
    
  }
  if (controlViewHideTime == 7) {
    controlViewHideTime = 0;
    [self hiddenActionView];
  }
  
}

#pragma mark -
#pragma mark ZVideoSliderDelegate
- (void)videoSlideViewDidBeginDragging:(ZVideoSliderView *)slideView
{
    [self pause];
    _isPlayingBeforeDrag = !_controlView.playButton.selected;
}

- (void)videoSlideViewDidDragging:(ZVideoSliderView *)slideView
{
    CGFloat total = _playerItem.duration.value / _playerItem.duration.timescale;
    CGFloat currentTime = total * slideView.value;
    NSInteger time = floorf(currentTime);

    [_player seekToTime:CMTimeMake(time, 1)];
}

- (void)videoSlideViewDidEndDragging:(ZVideoSliderView *)slideView
{
  if (_player.status == AVPlayerStatusReadyToPlay) {
    CGFloat total = _playerItem.duration.value / _playerItem.duration.timescale;
    if (total > 0) {
      CGFloat currentTime = total * slideView.value;
      NSInteger time = floorf(currentTime);
      [_player seekToTime:CMTimeMake(time, 1)completionHandler:^(BOOL finished) {
        if (_isPlayingBeforeDrag) {
          [self play];
        }
      }];
    }
  }
}

#pragma mark -
#pragma mark 布局
- (void)layoutSubviews
{
  _width = self.frame.size.width;
  _height = self.frame.size.height;
  CGFloat y;
  
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (UIInterfaceOrientationPortrait == orientation) {
    
    y = _width * _width / _height - kVideoControlHeight;
    
//    self.frame = CGRectMake(0, 0, _width, _width * _width / _height);
    _playerLayer.frame = CGRectMake(0, 0, _width, _width * _width / _height);
  }
  else {
    
    y = CGRectGetMaxY(self.frame) - kVideoControlHeight;
    
//    self.frame = CGRectMake(0, 0, _width, _height);
    _playerLayer.frame = CGRectMake(0, 0, _width, _height);
    
  }
  _controlView.frame = CGRectMake(0, y, self.frame.size.width, kVideoControlHeight);
  _controlView.backgroundColor = [UIColor redColor];
  _naviBack.frame    = CGRectMake(0, 0, self.frame.size.width, kVideoNaviHeight);
}

- (void)statusBarChanged:(NSNotification *)noti
{
  [self setNeedsLayout];
  [_controlView setNeedsLayout];
  [_naviBack setNeedsLayout];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
