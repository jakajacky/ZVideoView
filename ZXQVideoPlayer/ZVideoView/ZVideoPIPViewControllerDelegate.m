//
//  ZVideoPIPViewControllerDelegate.m
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/30.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#import "ZVideoPIPViewControllerDelegate.h"

@interface ZVideoPIPViewControllerDelegate () 

@end

@implementation ZVideoPIPViewControllerDelegate

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

//=========================================
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
  if (_view.delegate && [_view.delegate respondsToSelector:@selector(pictureInPictureController:failedToStartPictureInPictureWithError:)]) {
    [_view.delegate pictureInPictureController:pictureInPictureController failedToStartPictureInPictureWithError:error];
  }
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler
{
  if (_view.delegate && [_view.delegate respondsToSelector:@selector(pictureInPictureController:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:)]) {
    [_view.delegate pictureInPictureController:pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:completionHandler];
  }
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
  if (_view.delegate && [_view.delegate respondsToSelector:@selector(pictureInPictureControllerDidStartPictureInPicture:)]) {
    [_view.delegate pictureInPictureControllerDidStartPictureInPicture:pictureInPictureController];
  }
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
  if (_view.delegate && [_view.delegate respondsToSelector:@selector(pictureInPictureControllerDidStopPictureInPicture:)]) {
    [_view.delegate pictureInPictureControllerDidStopPictureInPicture:pictureInPictureController];
  }
}

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
  if (_view.delegate && [_view.delegate respondsToSelector:@selector(pictureInPictureControllerWillStartPictureInPicture:)]) {
    [_view.delegate pictureInPictureControllerWillStartPictureInPicture:pictureInPictureController];
  }
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
  if (_view.delegate && [_view.delegate respondsToSelector:@selector(pictureInPictureControllerWillStopPictureInPicture:)]) {
    [_view.delegate pictureInPictureControllerWillStopPictureInPicture:pictureInPictureController];
  }
}
//


@end
