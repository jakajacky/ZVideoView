//
//  ZVideoSliderView.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoSliderView.h"

@interface ZVideoSliderView ()

@property (nonatomic, strong) UISlider *slider;

@end

@implementation ZVideoSliderView


- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _slider = [[UISlider alloc] initWithFrame:self.bounds];
    [_slider setThumbImage:[UIImage imageNamed:@"iconfont-yuan"] forState:UIControlStateNormal];
    
    _slider.minimumTrackTintColor = [UIColor colorWithRed:30 / 255.0 green:80 / 255.0 blue:100 / 255.0 alpha:1];
    _slider.maximumValue = 1;
    
    [_slider addTarget:self
                action:@selector(beginDragging)
      forControlEvents:UIControlEventTouchDown];
    
    [_slider addTarget:self
                action:@selector(dragging)
      forControlEvents:UIControlEventValueChanged];
    
    [_slider addTarget:self
                action:@selector(endDragging)
      forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    
    [self addSubview:_slider];
  }
  return self;
}

#pragma mark -
#pragma mark 布局
- (void)layoutSubviews
{
  _slider.frame = self.bounds;
}

#pragma mark -
#pragma mark 设置进度
- (void)setValue:(CGFloat)value
{
  _slider.value = value;
}

- (CGFloat)value
{
  return _slider.value;
}

#pragma mark -
#pragma mark Slide Events

- (void)beginDragging
{
  if ([_delegate respondsToSelector:@selector(videoSlideViewDidBeginDragging:)]) {
    [_delegate videoSlideViewDidBeginDragging:self];
  }
}

- (void)dragging
{
  if ([_delegate respondsToSelector:@selector(videoSlideViewDidDragging:)]) {
    [_delegate videoSlideViewDidDragging:self];

  }
}

- (void)endDragging
{
  if ([_delegate respondsToSelector:@selector(videoSlideViewDidEndDragging:)]) {
    [_delegate videoSlideViewDidEndDragging:self];

  }
}

@end
