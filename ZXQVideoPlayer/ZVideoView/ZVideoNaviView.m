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
    self.backgroundColor = [UIColor colorWithWhite:0.122 alpha:0.5];
    
    [self initBackButton];
    [self initPipButton];
    [self initTitleLabel];
  }
  return self;
}


#pragma mark - 返回按钮
- (void)initBackButton
{
  _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _backButton.frame = CGRectMake(15, 20, 30, 30);
  [_backButton setBackgroundImage:[UIImage imageNamed:@"iconfont-back.png"]
                    forState:UIControlStateNormal];
  [self addSubview:_backButton];
}

#pragma mark - 画中画按钮
- (void)initPipButton
{
  _pipButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _pipButton.frame = CGRectMake(self.frame.size.width - 60, 20, 55, 20);
  [_pipButton setTitle:@"画中画" forState:UIControlStateNormal];
  [_pipButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
  _pipButton.titleLabel.font = [UIFont systemFontOfSize:12];
  
  [_pipButton.layer setMasksToBounds:YES];
  [_pipButton.layer setCornerRadius:8.0]; //设置矩圆角半径
  [_pipButton.layer setBorderWidth:1.0];   //边框宽度
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 74 / 255.0, 1, 1, 1 });
  [_pipButton.layer setBorderColor:colorref];//边框颜色
  
  [self addSubview:_pipButton];
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
