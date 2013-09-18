//
//  RCGameSceneParallaxBackground.h
//  RunGame
//
//  Created by xuzepei on 9/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RCGameSceneParallaxBackground : CCLayer {
    
}

@property(nonatomic,retain)CCSpriteBatchNode* batch;
@property(nonatomic,retain)CCArray* speedFactors;
@property(assign)float scrollSpeed;

@end
