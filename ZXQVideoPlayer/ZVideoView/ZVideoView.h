//
//  ZVideoView.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZVideoControlView.h"
#import "ZVideoNaviView.h"
#define kVideoNaviHeight 64
@class ZVideoView;

@protocol ZVideoViewDelegate <NSObject>
@optional

- (void)videoView:(ZVideoView *)videoView didCloseAtTime:(NSTimeInterval)time;
- (void)videoViewDidStartCall:(ZVideoView *)videoView;
- (void)videoViewDidFinishPlay:(ZVideoView *)videoView;

@end

@interface ZVideoView : UIView

@property (nonatomic, strong  ) ZVideoControlView  *controlView;          // 控制台

@property (nonatomic, strong  ) ZVideoNaviView     *naviBack;             // 返回

@property (nonatomic, readonly) CGFloat            currentVolume;         // 当前音量

@property (nonatomic, readonly) CGFloat            currentTime;           // 当前播放时间

@property (nonatomic, strong  ) UIColor            *VideoBackgroundColor; // 视频背景色

@property (nonatomic, assign  ) id <ZVideoViewDelegate> delegate;

- (void)play;                          // 播放

- (void)pause;                         // 暂停

- (void)stop;                          // 停止

- (void)setPath:(NSString *)path;      // 设置资源路径

- (void)setTitle:(NSString *)title;    // 设置视频标题


- (void)showActionView;                // 显示控制台

- (void)playOrPause;                   // 开始/暂停(双击事件)

@end
