//
//  ZVideoPanHandler.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/24.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoPanHandler.h"

#import "ZVideoView.h"

@interface ZVideoPanHandler () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) UIPanGestureRecognizer *horizontalPan;

@end

@implementation ZVideoPanHandler

- (instancetype)initPanHandlerWithView:(ZVideoView *)view
{
  self = [super init];
  if (self) {
    _view = view;
    
    _horizontalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(horizontalPanAction:)];
    _horizontalPan.delegate = self;
    [_view addGestureRecognizer:_horizontalPan];
  }
  return self;
}

- (void)horizontalPanAction:(UIPanGestureRecognizer *)sender
{
  CGPoint locationPoint = [sender translationInView:_view];
  CGPoint speedPoint    = [sender velocityInView:_view];
//  NSLog(@"%f=--=%f", locationPoint.x, locationPoint.y);
//  NSLog(@"%f=-++-=%f", speedPoint.x, speedPoint.y);
  if (sender.state == UIGestureRecognizerStateBegan) { // pan开始
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidBeginPan)]) {
      [self.delegate videoViewDidBeginPan];
    }
  }
  
  CGFloat x = speedPoint.x > 0 ? speedPoint.x : speedPoint.x * -1;
  CGFloat y = speedPoint.y > 0 ? speedPoint.y : speedPoint.y * -1;
  if (x > y && locationPoint.y <= 15 && locationPoint.y >= -15) { // 横向滑动为主
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidHorizontalPanning:)]) {
      [self.delegate videoViewDidHorizontalPanning:locationPoint.x];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
      if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidEndHorizontalPan:)]) {
        [self.delegate videoViewDidEndHorizontalPan:locationPoint.x];
      }
    }
  }
  else if (x < y && locationPoint.x <= 5 && locationPoint.x >= -5) { // 纵向滑动
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidVerticalPanning:)]) {
      [self.delegate videoViewDidVerticalPanning:locationPoint.y * -1];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
      if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewDidEndVerticalPan:)]) {
        [self.delegate videoViewDidEndVerticalPan:locationPoint.y * -1];
      }
    }
  }
}

- (void)invalidate
{
  _horizontalPan.delegate = nil;
  [_view removeGestureRecognizer:_horizontalPan];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  CGPoint point = [gestureRecognizer locationInView:self.view];
  BOOL inControlView = CGRectContainsPoint(_view.controlView.frame, point);
  BOOL inNaviView    = CGRectContainsPoint(_view.naviBack.frame, point);
  return !(inControlView) && !(inNaviView);
}

@end
