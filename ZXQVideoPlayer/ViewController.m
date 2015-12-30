//
//  ViewController.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ViewController.h"
#import "ZVideoView.h"

#import "VideoPlayerContrller.h"

@interface ViewController ()

@property (nonatomic, strong) VideoPlayerContrller *playerVC;

@end

@implementation ViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
//  ZVideoView *vi = [[ZVideoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//  vi.backgroundColor = [UIColor redColor];
//  [self.view addSubview:vi];
  //@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
  
  UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(300, 300, 50, 50)];
  b.backgroundColor = [UIColor redColor];
  b.titleLabel.text = @"button";
  [self.view addSubview:b];
  
  [b addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
  
  _playerVC = [[VideoPlayerContrller alloc] init];


}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)test
{
  _playerVC.vc = self;
  if (_playerVC.zView.rate == 0) {
    [self presentViewController:_playerVC animated:YES completion:^{
      
    }];
  }
}

@end
