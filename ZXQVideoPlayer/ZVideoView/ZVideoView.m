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

#import "ZVideoNaviView.h"

#import "ZVideoTaphandler.h"
#import "ZVideoPanHandler.h"

#define kIsPlayLocalVideo 1

@interface ZVideoView () <ZVideoSliderViewDelegate, ZVideoPanHandlerDelegate>

@property (nonatomic, strong) AVPlayer          *player;// 播放属性

@property (nonatomic, strong) AVPlayerItem      *playerItem;

@property (nonatomic, strong) AVPlayerLayer     *playerLayer;

@property (nonatomic, assign) CGFloat           width;// 坐标

@property (nonatomic, assign) CGFloat           height;// 坐标

@property (nonatomic, strong) ZVideoNaviView    *naviBack;// 返回

@property (nonatomic, strong) ZVideoTaphandler  *tapHandler;// tap手势

@property (nonatomic, strong) ZVideoPanHandler  *panHandler;// swipe手势

@property (nonatomic, assign) BOOL              isPlayingBeforeDrag;//滑动前是否是播放状态

@property (nonatomic, strong) NSTimer           *timer;// 进度时间器

@property (nonatomic, strong) NSTimer           *hiddenTimer;// 用于自动隐藏控制台的计数器

@property (nonatomic, strong) UISlider          *volumeSlider; // 系统音量

@property (nonatomic, assign) CGFloat           currentVolume; // 当前音量

//@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"

@end

@implementation ZVideoView

static int controlViewHideTime = 0;// timer运行中的计数，== 7执行隐藏

static int autoHiddenCount = 0;    // timer停止（player暂停），hiddenTimer开始，== 7 执行隐藏

static CGFloat currentTime = 0;

static int seekTime = 0;

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
    [self initGesture];
    [self initTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
  }
  return self;
}

#pragma mark 创建player
- (void)initPlayer
{
  // 创建AVPlayer
  _currentVolume = 0; // 初始化音量
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
  
  [_controlView.playButton addTarget:self
                              action:@selector(playOrPause)
                    forControlEvents:UIControlEventTouchUpInside];
  // 默认
  [_controlView.playButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn@2x.png"]
                                     forState:UIControlStateNormal];
  _controlView.playButton.selected = NO;
  
  
  [_controlView.forwardButton addTarget:self
                                 action:@selector(unKownAction)
                       forControlEvents:UIControlEventTouchUpInside];
  
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

#pragma mark 创建手势
- (void)initGesture
{
  _tapHandler = [[ZVideoTaphandler alloc] initTapHandlerWithView:self];
  
  _panHandler = [[ZVideoPanHandler alloc] initPanHandlerWithView:self];
  _panHandler.delegate = self;
}

#pragma mark 创建计时器
- (void)initTimer
{
  //计时器
  _timer = [NSTimer scheduledTimerWithTimeInterval:1.f
                                            target:self
                                          selector:@selector(timeRun)
                                          userInfo:nil
                                           repeats:YES];
}

#pragma mark -
#pragma mark 设置路径
- (void)setPath:(NSString *)path
{
#ifdef kIsPlayLocalVideo
  NSURL *sourceMovieUrl = [NSURL fileURLWithPath:path];
  AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
  self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
#else
  self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:path]];
#endif
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
  autoHiddenCount = 0;
  [_controlView.playButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn@2x.png"]
                                     forState:UIControlStateNormal];
  
  if (![_timer isValid]) {
    [self initTimer];
  }
  [_timer fire];
  
  [self.player play];
  
  //   注销hiddenTimer
  [_hiddenTimer invalidate];
}

- (void)pause
{
  controlViewHideTime = 0;
  autoHiddenCount = 0;
  [_controlView.playButton setBackgroundImage:[UIImage imageNamed:@"playBtn@2x.png"]
                                     forState:UIControlStateNormal];
  
  [_timer invalidate];
  
  [self.player pause];
  
  // 暂停后需自动隐藏控制台
  [self autoHiddenActionView];
  
}


#pragma mark 响应轻拍事件
- (void)showActionView
{
  controlViewHideTime = 0;
  autoHiddenCount = 0;
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

//  if (_controlView.playButton.selected) {
//    [self autoHiddenActionView];
//  }
}

#pragma mark 响应双击事件
- (void)doubleTapAction
{
  controlViewHideTime = 0;
  autoHiddenCount = 0;
  [self playOrPause];
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
  if (![_hiddenTimer isValid]) {
    _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(hiddenCount)
                                   userInfo:nil
                                    repeats:YES];
  }
  [_hiddenTimer fire];
}

- (void)hiddenCount
{
  autoHiddenCount++;
  NSLog(@"%d", autoHiddenCount);
  if (autoHiddenCount == 7) {
    [self hiddenActionView];
    autoHiddenCount = 0;
  }
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
//  NSLog(@"--->%d", controlViewHideTime);
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
  autoHiddenCount = 0;
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
#pragma mark ZVideoPanHandlerDelegate
- (void)videoViewDidBeginPan
{
  _isPlayingBeforeDrag = !_controlView.playButton.selected;
}

- (void)videoViewDidHorizontalPanning:(CGFloat)x
{
  _isPlayingBeforeDrag = !_controlView.playButton.selected;
  [self pause];
  
  autoHiddenCount = 0;
  CGFloat total = _playerItem.duration.value / _playerItem.duration.timescale;
  if (total > 0) {
//    CGFloat currentTime = total * x / (10 * 2048.0);
    CGFloat increTime = total * x / (10 * 2048.0);
    
    CGFloat time = increTime + CMTimeGetSeconds(_player.currentTime);
    if (currentTime == CMTimeGetSeconds(_player.currentTime)) {
      time = seekTime + 1;
    }
    //      NSInteger time = floorf(currentTime + CMTimeGetSeconds(_player.currentTime));
    currentTime = CMTimeGetSeconds(_player.currentTime);
    seekTime = time;

    if (time < 0) {
      time = 0;
    }
    if (time > total) {
      time = total;
    }
    [_player seekToTime:CMTimeMake(time, 1)completionHandler:^(BOOL finished) {
      if (_isPlayingBeforeDrag) {
        [self play];
      }
    }];
  }
}

- (void)videoViewDidEndHorizontalPan:(CGFloat)x
{
//  if (_player.status == AVPlayerStatusReadyToPlay) {
//    CGFloat total = _playerItem.duration.value / _playerItem.duration.timescale;
//    if (total > 0) {
//      CGFloat increTime = total * x / (10 * 2048.0);
//      
//      
//      CGFloat time = increTime + CMTimeGetSeconds(_player.currentTime);
//      if (currentTime == CMTimeGetSeconds(_player.currentTime)) {
//        time = seekTime + 1;
//      }
////      NSInteger time = floorf(currentTime + CMTimeGetSeconds(_player.currentTime));
//      
//      
//      currentTime = CMTimeGetSeconds(_player.currentTime);
//      seekTime = time;
//
////      NSLog(@"%f+++%f+++%f", increTime, CMTimeGetSeconds(_player.currentTime), time);
//      [_player seekToTime:CMTimeMake(time, 1)completionHandler:^(BOOL finished) {
//        if (_isPlayingBeforeDrag) {
//          [self play];
//        }
//      }];
//    }
//  }
}

- (void)videoViewDidVerticalPanning:(CGFloat)y
{
  if (_isPlayingBeforeDrag) {
    [self play];
  }
  // 控制音量
  //获取系统音量
  MPVolumeView *volumeView = [[MPVolumeView alloc] init];
  
  for (UIView *view in [volumeView subviews]){
    if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
      _volumeSlider = (UISlider *)view;
      break;
    }
  }
  _currentVolume = _currentVolume + y / (3 * 768.0);
  if (_currentVolume < 0) {
    _currentVolume = 0;
  }
  if (_currentVolume > 1) {
    _currentVolume = 1;
  }
  [_volumeSlider setValue:_currentVolume];
  [_volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)videoViewDidEndVerticalPan:(CGFloat)y
{
  
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
  
  [_tapHandler invalidate];
}

@end
