//
//  ZVideoPIPViewControllerDelegate.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/30.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

#import "ZVideoView.h"

@interface ZVideoPIPViewControllerDelegate : NSObject
<AVPictureInPictureControllerDelegate>

@property (nonatomic, weak) ZVideoView *view;

- (instancetype)init;

@end
