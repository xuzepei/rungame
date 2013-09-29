//
//  RCGameScene.h
//  RunGame
//
//  Created by xuzepei on 9/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLES-Render.h"
#import "Box2D.h"
#import "RCPanda.h"
#import "RCTerrace.h"
#import "MyContactListener.h"
#import "RCScoreBar.h"

@class RCGameSceneParallaxBackground;
@interface RCGameScene : CCLayer {
    
    GLESDebugDraw* _debugDraw;
    
    b2World* _world;
    b2Body* _groundBody;
    b2Fixture* _groundFixture;
    
    MyContactListener* _contactListener;
    
}

@property(nonatomic,retain)RCPanda* panda;
@property(nonatomic,retain)NSMutableArray* terraceArray;
@property(nonatomic,retain)NSMutableArray* entityArray;
@property(assign)CGFloat terraceSpeed;
@property(assign)CGFloat entitySpeed;
@property(nonatomic,retain)RCGameSceneParallaxBackground* parallaxBg;
@property(nonatomic,retain)RCScoreBar* scoreBar;
@property(nonatomic,retain)CCSprite* actionSprite;
@property(assign)int actionSpriteType;
@property(nonatomic,retain)CCSpriteBatchNode* bulletBatchNode;
@property(nonatomic,retain)NSTimer* longTouchTimer;

+ (id)scene;
+ (RCGameScene*)sharedInstance;


@end
