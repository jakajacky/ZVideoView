//
//  ZVideoSliderView.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoSliderView.h"

@interface ZVideoSliderView ()

@end

@implementation ZVideoSliderView


- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _slider = [[UISlider alloc] initWithFrame:self.bounds];
    [_slider setThumbImage:[UIImage imageNamed:@"iconfont-yuan1"] forState:UIControlStateNormal];
    
    _slider.minimumTrackTintColor = [UIColor colorWithRed:76  / 255.0
                                                    green:130 / 255.0
                                                     blue:243 / 255.0
                                                    alpha:1];
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

- (void)setMaximumTrackImage:(UIImage *)image forState:(UIControlState)state
{
  [_slider setMaximumTrackImage:image forState:state];
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
