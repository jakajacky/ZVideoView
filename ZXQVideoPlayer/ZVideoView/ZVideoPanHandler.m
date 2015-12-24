//
//  ZVideoPanHandler.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/24.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoPanHandler.h"

#import "ZVideoView.h"

@interface ZVideoPanHandler ()

@property (nonatomic, readonly) UIPanGestureRecognizer *horizontalPan;
//@property (nonatomic, readonly) UIPanGestureRecognizer *verticalPan;

@end

@implementation ZVideoPanHandler


- (instancetype)initPanHandlerWithView:(ZVideoView *)view
{
  self = [super init];
  if (self) {
    _view = view;
    
    _horizontalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(horizontalPanAction:)];
    
    [_view addGestureRecognizer:_horizontalPan];
  }
  return self;
}

- (void)horizontalPanAction:(UIPanGestureRecognizer *)sender
{
  CGPoint point = [sender translationInView:_view];
  NSLog(@"%f=--=%f", point.x, point.y);
  if (sender.state == UIGestureRecognizerStateBegan) { // pan开始
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidBeginPan)]) {
      [self.delegate videoViewDidBeginPan];
    }
  }
  
  CGFloat x = point.x > 0 ? point.x : point.x * -1;
  CGFloat y = point.y > 0 ? point.y : point.y * -1;
  if (x >= y) { // 横向滑动为主
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidHorizontalPanning:)]) {
      [self.delegate videoViewDidHorizontalPanning:point.x];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
      if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidEndHorizontalPan:)]) {
        [self.delegate videoViewDidEndHorizontalPan:point.x];
      }
    }
    
  }
  else {                   // 纵向滑动
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidVerticalPanning:)]) {
      [self.delegate videoViewDidVerticalPanning:point.y];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
      if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidEndVerticalPan:)]) {
        [self.delegate videoViewDidEndVerticalPan:point.y];
      }
    }
  }
  
  
  
}

- (void)verticalPanAction
{
  NSLog(@"我正在垂直滑动++++++++");
}

- (void)invalidate
{
  [_view removeGestureRecognizer:_horizontalPan];
//  [_view removeGestureRecognizer:_verticalPan];
}

@end
