//
//  RCBox2dMoveTo.h
//  RunGame
//
//  Created by xuzepei on 9/19/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RCBox2dMoveTo : CCActionInterval{
	CGPoint endPosition_;
	CGPoint startPosition_;
	CGPoint delta_;
}

/** creates the action */
+(id) actionWithDuration:(ccTime)duration position:(CGPoint)position;
/** initializes the action */
-(id) initWithDuration:(ccTime)duration position:(CGPoint)position;

@end
