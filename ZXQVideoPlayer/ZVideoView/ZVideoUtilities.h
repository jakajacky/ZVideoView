//
//  ZVideoUtilities.h
//  ZXQVideoPlayer
//
//  Created by Xiaoqiang Zhang on 15/12/22.
//  Copyright © 2015年 Xiaoqiang Zhang. All rights reserved.
//

#ifndef ZVideoUtilities_h
#define ZVideoUtilities_h

NS_INLINE NSString * TimeStringWithSeconds(NSInteger seconds) {
  if (seconds < 0) {
    return @"-:-:-";
  }
  
  NSInteger s = seconds % 60;
  NSInteger m = ((seconds - s) / 60) % 60;
  NSInteger h = ((seconds - s - m * 60) / 60) / 60;
  
  if (h == 0) {
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)m, (long)s];
  }
  else {
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)h, (long)m, (long)s];
  }
}

#endif /* ZVideoUtilities_h */

