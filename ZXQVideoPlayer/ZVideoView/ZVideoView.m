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

#import "ZVideoTaphandler.h"
#import "ZVideoPanHandler.h"
#import "ZVideoPIPViewControllerDelegate.h"

#define kIsPlayLocalVideo 1

@interface ZVideoView ()
<ZVideoSliderViewDelegate, ZVideoPanHandlerDelegate, AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) AVPlayer                     *player;            // 播放属性

@property (nonatomic, strong) AVPlayerItem                 *playerItem;

@property (nonatomic, strong) AVPlayerLayer                *playerLayer;

@property (nonatomic, assign) CGFloat                      width;              // 坐标

@property (nonatomic, assign) CGFloat                      height;             // 坐标

@property (nonatomic, strong) ZVideoTaphandler             *tapHandler;        // 轻拍手势

@property (nonatomic, strong) ZVideoPanHandler             *panHandler;        // 滑动手势

@property (nonatomic, assign) BOOL                         isPlayingBeforeDrag;// 滑动前是否是播放状态

@property (nonatomic, strong) NSTimer                      *timer;// 进度计时器、播放中自动隐藏控制台计数

@property (nonatomic, strong) NSTimer                      *hiddenTimer; // 暂停后自动隐藏控制台的计时器

@property (nonatomic, strong) UISlider                     *volumeSlider;     // 获取系统音量

@property (nonatomic, strong) AVPictureInPictureController *pipViewController;// 画中画

@property (nonatomic, strong) ZVideoPIPViewControllerDelegate *pipDelegate;

@end

@implementation ZVideoView

static int controlViewHideTime = 0;// timer运行中的计数，== 7执行隐藏

static int autoHiddenCount     = 0;// timer停止（player暂停），hiddenTimer开始，== 7 执行隐藏

#pragma mark -
#pragma mark Initializations
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _width = self.frame.size.width;
    _height = self.frame.size.height;
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
      NSLog(@"error = %@",[error description]);
    }

    [self initPlayer];
    [self initControlView];
    [self initNaviBackView];
    [self initGesture];
    [self initTimer];
    [self initNotification];
    
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
  _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;  // 适配视频尺寸
  _playerLayer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
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
//  _controlView.rate = 1;
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

  [_naviBack.backButton addTarget:self
                           action:@selector(didCloseVideoView:)
                 forControlEvents:UIControlEventTouchUpInside];
  
  // 画中画开关
  [_naviBack.pipButton addTarget:self
                           action:@selector(didOpenPipMode)
                 forControlEvents:UIControlEventTouchUpInside];
  
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

#pragma mark 创建Notification
- (void)initNotification
{
  // 屏幕旋转通知
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(statusBarChanged:)
                                               name:UIApplicationDidChangeStatusBarOrientationNotification
                                             object:nil];
  
  // 后台通知
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(enterBackground:)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
  
  //AVPlayer播放完成通知
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(moviePlayDidEnd:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:_player.currentItem];
}

#pragma mark 创建画中画VC
- (void)initPicInPicViewController
{
  _pipViewController = [[AVPictureInPictureController alloc] initWithPlayerLayer:_playerLayer];
  _pipDelegate = [[ZVideoPIPViewControllerDelegate alloc] init];
  _pipViewController.delegate = _pipDelegate;
  _pipDelegate.view = self;
  [_pipViewController startPictureInPicture];
}

#pragma mark -
#pragma mark 设置路径
- (void)setPath:(NSString *)path
{
#if kIsPlayLocalVideo
  NSURL *sourceMovieUrl = [NSURL fileURLWithPath:path];
  AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
  self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
#else
  self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:path]];
#endif
  [self.playerItem addObserver:self
                    forKeyPath:@"loadedTimeRanges"
                       options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
  [self.player replaceCurrentItemWithPlayerItem:_playerItem];

}

#pragma mark 设置标题
- (void)setTitle:(NSString *)title
{
  _naviBack.title = title;
}

#pragma mark 设置背景色
- (void)setVideoBackgroundColor:(UIColor *)VideoBackgroundColor
{
  self.backgroundColor = VideoBackgroundColor;
}

#pragma mark 设置是否支持画中画
- (void)setSupportPictureInpicture:(BOOL)supportPictureInpicture
{
  if (supportPictureInpicture) {
    [self initPicInPicViewController];
    _naviBack.pipButton.enabled = YES;
    
    // 取消后台暂停通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
  }
  else {
    _naviBack.pipButton.enabled = NO;
  }
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
  
}
- (void)play
{
  controlViewHideTime = 0;
  autoHiddenCount = 0;
  [_controlView.playButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn@2x.png"]
                                     forState:UIControlStateNormal];
  _controlView.playButton.selected =!_controlView.playButton.selected;
  
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
  _controlView.playButton.selected =!_controlView.playButton.selected;
  
  [_timer invalidate];
  
  [self.player pause];
  // 暂停后需自动隐藏控制台
  [self autoHiddenActionView];
}

- (void)stop
{
  [_timer invalidate];
  [_hiddenTimer invalidate];
  
  [_player replaceCurrentItemWithPlayerItem:nil];
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
}

#pragma mark 关闭
- (void)didCloseVideoView:(UIButton *)sender
{
  if (_delegate && [_delegate respondsToSelector:@selector(videoView:didCloseAtTime:)]) {
    [_delegate videoView:self didCloseAtTime:0];
    [self stop];
  }
}

#pragma mark 开启画中画
- (void)didOpenPipMode
{
  [_pipViewController startPictureInPicture];
}

#pragma mark 播放完成
- (void)moviePlayDidEnd:(NSNotification *)noti
{
  if (_delegate && [_delegate respondsToSelector:@selector(videoViewDidFinishPlay:)]) {
    [_delegate videoViewDidFinishPlay:self];
  }
}

#pragma mark 进入后台
- (void)enterBackground:(NSNotification *)noti
{
  if (_player.rate == 1) {
    [self pause];
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
  NSLog(@"暂停后自动隐藏计数：%d", autoHiddenCount);
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
  NSLog(@"播放中自动隐藏计数：%d", controlViewHideTime);
  if (_playerItem.duration.timescale != 0) {
    CMTime currentTime = self.player.currentTime;
    CMTime duration    = self.playerItem.duration;
    _controlView.currentTime     = CMTimeGetSeconds(currentTime);
    _controlView.duration        = duration.value / duration.timescale;
    _controlView.slideView.value = _controlView.currentTime / _controlView.duration;//当前进度
    
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

#pragma mark 播放状态
- (CGFloat)rate
{
  return _player.rate;
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
  _currentTime = CMTimeGetSeconds(_player.currentTime);
}

- (void)videoViewDidHorizontalPanning:(CGFloat)x
{
  [self pause];
  
  autoHiddenCount = 0;
  CGFloat total = _playerItem.duration.value / _playerItem.duration.timescale;
  if (total > 0) {
//    CGFloat currentTime = total * x / (10 * 2048.0);
    CGFloat increTime = total * x / (20 * 2048.0);
    _currentTime = _currentTime + increTime;
    
    if (_currentTime < 0) {
      _currentTime = 0;
    }
    if (_currentTime > total) {
      _currentTime = total;
    }
//    NSLog(@"+++++++++%f++++%f", CMTimeGetSeconds(_playerItem.currentTime), increTime);
    [_player seekToTime:CMTimeMake(floorf(_currentTime), 1)];
  }
}

- (void)videoViewDidEndHorizontalPan:(CGFloat)x
{
//  if (_player.status == AVPlayerStatusReadyToPlay) {
    CGFloat total = _playerItem.duration.value / _playerItem.duration.timescale;
    if (total > 0) {
      CGFloat increTime = total * x / (10 * 2048.0);
      _currentTime = _currentTime + increTime;
      
      if (_currentTime < 0) {
        _currentTime = 0;
      }
      if (_currentTime > total) {
        _currentTime = total;
      }
      //      NSLog(@"%f+++%f+++%f", increTime, CMTimeGetSeconds(_player.currentTime), time);
      [_player seekToTime:CMTimeMake(floorf(_currentTime), 1)completionHandler:^(BOOL finished) {
        if (_isPlayingBeforeDrag) {
          [self play];
        }
      }];
    }
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
#pragma mark 计算缓冲进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
    NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
    //        NSLog(@"Time Interval:%f",timeInterval);
    CMTime duration = self.playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    [self.controlView.progress setProgress:timeInterval / totalDuration animated:NO];
  }
}

- (NSTimeInterval)availableDuration {
  NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
  CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
  float startSeconds = CMTimeGetSeconds(timeRange.start);
  float durationSeconds = CMTimeGetSeconds(timeRange.duration);
  NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
  return result;
}


#pragma mark -
#pragma mark 布局
- (void)layoutSubviews
{
  _width = self.frame.size.width;
  _height = self.frame.size.height;
  CGFloat y;
  
  self.backgroundColor = [UIColor blackColor];
  
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
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidChangeStatusBarOrientationNotification
                                                object:nil];
  
  [_tapHandler invalidate];
  [_panHandler invalidate];
  
  [_timer invalidate];
  [_hiddenTimer invalidate];
}

@end
