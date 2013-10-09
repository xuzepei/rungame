//
//  RCTerrace.h
//  RunGame
//
//  Created by xuzepei on 9/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBox2dSprite.h"

@interface RCTerrace : RCBox2dSprite {
    
}

@property(assign)CGFloat originalY;

+ (id)terrace;
- (void)move:(CGPoint)offset;
- (void)beHit;

@end
