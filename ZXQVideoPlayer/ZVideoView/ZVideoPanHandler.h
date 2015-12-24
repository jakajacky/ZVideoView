//
//  ZVideoPanHandler.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/24.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZVideoView;
@class ZVideoPanHandler;

@protocol ZVideoPanHandlerDelegate <NSObject>

- (void)videoViewDidBeginPan;

- (void)videoViewDidHorizontalPanning:(CGFloat)x;

- (void)videoViewDidVerticalPanning:(CGFloat)y;

- (void)videoViewDidEndHorizontalPan:(CGFloat)x;

- (void)videoViewDidEndVerticalPan:(CGFloat)y;

@end

@interface ZVideoPanHandler : NSObject

@property (nonatomic, readonly) ZVideoView *view;

@property (nonatomic, assign) id <ZVideoPanHandlerDelegate> delegate;

- (instancetype)initPanHandlerWithView:(ZVideoView *)view;

- (void)invalidate;

@end
