//
//  CCAnimation+Helper.h
//  RCGame
//
//  Created by xuzepei on 5/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCAnimation (Helper)

+ (CCAnimation*)animationWithFile:(NSString*)name frameCount:(int)frameCount delay:(float)delay;
+ (CCAnimation*)animationWithFrame:(NSString*)frame frameCount:(int)frameCount delay:(float)delay;
+ (CCAnimation*)animationWithFrame:(NSString*)frame indexArray:(NSArray*)indexArray delay:(float)delay;
+ (CCAnimation*)animationWithFile:(NSString*)filename itemSize:(CGSize)itemSize delay:(float)delay;

@end
