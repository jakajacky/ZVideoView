//
//  ViewController.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ViewController.h"
#import "ZVideoView.h"


@interface ViewController ()

@property (nonatomic, strong) ZVideoView *zView;

@end

@implementation ViewController

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
  NSString *path = [[NSBundle mainBundle] pathForResource:@"282M mp4" ofType:@"mp4"];
  [_zView setPath:path];
  [_zView setTitle:@"视频播放"];
  _zView.backgroundColor = [UIColor whiteColor];
  [_zView play];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
