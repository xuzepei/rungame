//
//  RCSpringEntity.h
//  RunGame
//
//  Created by xuzepei on 9/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPanda.h"
#import "RCEntity.h"

@interface RCSpringEntity : RCEntity {
    
}

@property(assign)ENTITY_TYPE type;
@property(assign)RCPanda* panda;
@property(assign)BOOL isCollided;

+ (id)entity:(ENTITY_TYPE)type;
- (id)initWithType:(ENTITY_TYPE)type;

@end
