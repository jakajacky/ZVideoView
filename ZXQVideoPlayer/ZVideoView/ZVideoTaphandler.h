//
//  ZVideoTaphandler.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/23.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZVideoView;
@interface ZVideoTaphandler : NSObject

@property (nonatomic, readonly) ZVideoView *view;

- (instancetype)initTapHandlerWithView:(ZVideoView *)view;

- (void)invalidate;

@end

@interface ZVideoTaphandler (Unavailable)

- (id)init UNAVAILABLE_ATTRIBUTE;

@end