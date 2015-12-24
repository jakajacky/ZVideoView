//
//  ZVideoView.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kVideoNaviHeight 44

@interface ZVideoView : UIView

- (void)play;

- (void)setPath:(NSString *)path;

- (void)setTitle:(NSString *)title;

- (void)showActionView;

- (void)doubleTapAction;

@end
