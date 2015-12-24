//
//  ZVideoPanHandler.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/24.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZVideoView;

@interface ZVideoPanHandler : NSObject

@property (nonatomic, readonly) ZVideoView *view;

- (instancetype)initPanHandlerWithView:(ZVideoView *)view;

- (void)invalidate;

@end
