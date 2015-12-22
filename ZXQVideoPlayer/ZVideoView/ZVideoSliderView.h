//
//  ZVideoSliderView.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/20.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZVideoSliderView;

@protocol ZVideoSliderViewDelegate <NSObject>

@optional

- (void)videoSlideViewDidTap:(ZVideoSliderView *)slideView;
- (void)videoSlideViewDidBeginDragging:(ZVideoSliderView *)slideView;
- (void)videoSlideViewDidDragging:(ZVideoSliderView *)slideView;
- (void)videoSlideViewDidEndDragging:(ZVideoSliderView *)slideView;

@end

@interface ZVideoSliderView : UIView

@property (nonatomic, assign) id <ZVideoSliderViewDelegate> delegate;

@property(nonatomic) CGFloat trackHeight;

@property(nonatomic) CGFloat value;

@end
