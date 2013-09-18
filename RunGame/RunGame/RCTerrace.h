//
//  RCTerrace.h
//  RunGame
//
//  Created by xuzepei on 9/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhysicsSprite.h"

@interface RCTerrace : PhysicsSprite {
    
}

+ (id)terrace;
- (void)setPos:(CGPoint)pos;
- (void)move:(CGPoint)offset;
- (void)beHit;

@end
