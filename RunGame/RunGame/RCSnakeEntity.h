//
//  RCSnakeEntity.h
//  RunGame
//
//  Created by xuzepei on 9/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPanda.h"
#import "RCGameScene.h"
#import "RCEntity.h"

@interface RCSnakeEntity : RCEntity {
    
}

@property(assign)ENTITY_TYPE type;
@property(assign)BOOL isCollided;
@property(assign)BOOL isShooted;
@property(assign)RCGameScene* gameScene;

+ (id)entity:(ENTITY_TYPE)type;
- (id)initWithType:(ENTITY_TYPE)type;

@end
