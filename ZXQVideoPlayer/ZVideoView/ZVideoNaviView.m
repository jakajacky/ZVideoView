//
//  ZVideoNaviView.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoNaviView.h"

@interface ZVideoNaviView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZVideoNaviView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initBackButton];
    [self initTitleLabel];
  }
  return self;
}


#pragma mark - 返回按钮
- (void)initBackButton
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(15, 20, 30, 30);
  [button setBackgroundImage:[UIImage imageNamed:@"iconfont-back.png"]
                    forState:UIControlStateNormal];
  [self addSubview:button];
  [button addTarget:self
             action:@selector(backButtonAction)
   forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 视频标题
- (void)initTitleLabel
{
  CGRect frame = CGRectMake(45, 20, self.frame.size.width - 90, 30);
  _titleLabel = [[UILabel alloc] initWithFrame:frame];
  [_titleLabel setTextColor:[UIColor whiteColor]];
  [_titleLabel setTextAlignment:NSTextAlignmentCenter];
  
  [self addSubview:_titleLabel];
}

#pragma mark - 设置标题
- (void)setTitle:(NSString *)title
{
  [_titleLabel setText:title];
}

- (void)backButtonAction
{
  
}

#pragma mark -
#pragma mark 布局
- (void)layoutSubviews
{
  _titleLabel.frame = CGRectMake(45, 20, self.frame.size.width - 90, 30);
}

@end