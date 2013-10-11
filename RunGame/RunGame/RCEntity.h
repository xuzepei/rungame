//
//  RCEntity.h
//  RunGame
//
//  Created by xuzepei on 10/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPanda.h"

@interface RCEntity : CCSprite {
    
}

@property(assign)RCPanda* panda;
@property(assign)CGFloat originalY;

@end
