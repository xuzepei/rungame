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

@interface RCGameScene : CCLayer {
    
    GLESDebugDraw* _debugDraw;
    
    b2World* _world;
    b2Body* _groundBody;
    b2Fixture* _groundFixture;
    
    MyContactListener* _contactListener;
    
}

@property(nonatomic,retain)RCPanda* panda;
@property(nonatomic,retain)NSMutableArray* terraceArray;
@property(assign)CGFloat terraceSpeed;

+ (id)scene;
+ (RCGameScene*)sharedInstance;


@end
