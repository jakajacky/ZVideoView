//
//  ZVideoTaphandler.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/23.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoTaphandler.h"
#import "ZVideoView.h"

@interface ZVideoTaphandler () <UIGestureRecognizerDelegate>

@property (nonatomic) UITapGestureRecognizer *singleTap;

@property (nonatomic) UITapGestureRecognizer *doubleTap;

@end

@implementation ZVideoTaphandler

- (instancetype)initTapHandlerWithView:(ZVideoView *)view
{
  self = [super init];
  if (self) {
    _view = view;
    
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    
    _singleTap.delegate = self;
    _doubleTap.delegate = self;
    
    [_singleTap requireGestureRecognizerToFail:_doubleTap];
    _doubleTap.numberOfTapsRequired = 2;
    [_view addGestureRecognizer:_singleTap];
    [_view addGestureRecognizer:_doubleTap];
  }
  return self;
}


#pragma mark -
#pragma mark 设置手势事件
- (void)singleTapAction:(UITapGestureRecognizer *)sender
{
  [_view showActionView];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)sender
{
  [_view doubleTapAction];
}

- (void)invalidate
{
  _singleTap.delegate = nil;
  _doubleTap.delegate = nil;
  
  [_view removeGestureRecognizer:_singleTap];
  [_view removeGestureRecognizer:_doubleTap];
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
