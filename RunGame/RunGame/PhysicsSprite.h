//
//  PhysicsSprite.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 1/4/12.
//  Copyright (c) 2012 Zynga. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

@interface PhysicsSprite : CCSprite
{
	b2Body *body_;	// strong ref
    b2Fixture* _fixture;
}

- (void)setPhysicsBody:(b2Body*)body;
- (b2Body*)getBody;

- (void)setFixture:(b2Fixture*)fixture;
- (b2Fixture*)getFixture;
- (CGSize)getBodySize;

@end