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
@property (nonatomic, readonly) UIPanGestureRecognizer *verticalPan;

@end

@implementation ZVideoPanHandler


- (instancetype)initPanHandlerWithView:(ZVideoView *)view
{
  self = [super init];
  if (self) {
    _view = view;
    
    _horizontalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(horizontalPanAction)];
    
    _verticalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(verticalPanAction)];
    
    
    [_view addGestureRecognizer:_horizontalPan];
    [_view addGestureRecognizer:_verticalPan];
  }
  return self;
}

- (void)horizontalPanAction
{
  NSLog(@"我正在水平滑动--------");
}

- (void)verticalPanAction
{
  NSLog(@"我正在垂直滑动++++++++");
}

- (void)invalidate
{
  [_view removeGestureRecognizer:_horizontalPan];
  [_view removeGestureRecognizer:_verticalPan];
}

@end
