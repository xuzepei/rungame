//
//  RCLoadingLayer.h
//  RCGame
//
//  Created by xuzepei on 4/27/13.
//
//

#import <UIKit/UIKit.h>

@interface RCLoadingLayer : CCLayer
{
    SCENE_TYPE _targetSceneType;
}

+ (CCScene*)goToScene:(SCENE_TYPE)targetSceneType;
- (id)initWithSceneType:(SCENE_TYPE)targetSceneType;

@end
