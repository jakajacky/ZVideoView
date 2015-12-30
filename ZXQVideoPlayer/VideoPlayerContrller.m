//
//  VideoPlayerContrller.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/25.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "VideoPlayerContrller.h"

@interface VideoPlayerContrller () <ZVideoViewDelegate>

@end

@implementation VideoPlayerContrller

- (void)loadView
{
  [super loadView];
  _zView = [[ZVideoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.view = _zView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  //  ZVideoView *vi = [[ZVideoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  //  vi.backgroundColor = [UIColor redColor];
  //  [self.view addSubview:vi];
  //@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
  
  //  UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(300, 300, 50, 50)];
  //  b.backgroundColor = [UIColor redColor];
  //  b.titleLabel.text = @"button";
  //  [self.view addSubview:b];
  //
  //  [b addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
  //
  //  _playerVC = [[VideoPlayerController alloc] init];
  
//  _zView = [[ZVideoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//  [self.view addSubview:_zView];
  
  NSString *path = [[NSBundle mainBundle] pathForResource:@"282M mp4" ofType:@"mp4"];

  [_zView setPath:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"];
  [_zView setTitle:@"视频播放"];
  _zView.VideoBackgroundColor = [UIColor blackColor];
  _zView.supportPictureInpicture = YES;  // 支持画中画,则不支持后台暂停，反之。。。
  
  [_zView play];
  
  _zView.delegate = self;
  
}

- (void)videoView:(ZVideoView *)videoView didCloseAtTime:(NSTimeInterval)time
{
  [self dismissViewControllerAnimated:YES completion:^{
    
  }];
}

// 下面是关于画中画得代理，目的是：开始画中画时，关掉原视频VideoPlayerController，结束画中画时，还原原来的VideoPlayerController,并继续播放
// 如果不实现这几个代理，效果是：开始画中画后，VideoPlayerController还在，只是视频的playerLayer在画中画中，留下一个系统的layer；

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
  NSLog(@"开始");
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
  NSLog(@"完成");
  [_vc presentViewController:self animated:YES completion:nil];
  [_zView play];
}

- (void)dealloc
{
  _zView.delegate = nil;
  _zView = nil;
}

//#pragma mark 只支持横屏
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//  return UIInterfaceOrientationLandscapeRight;
//}
//
//- (BOOL)shouldAutorotate
//{
//  return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//  return UIInterfaceOrientationMaskLandscape;
//}

@end
