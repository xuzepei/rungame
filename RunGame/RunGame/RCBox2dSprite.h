//
//  RCBox2dSprite.h
//  RunGame
//
//  Created by xuzepei on 9/13/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

inline b2Vec2 b2Vec2FromCGPoint(CGPoint p)
{
    return b2Vec2(p.x/PTM_RATIO, p.y/PTM_RATIO);
}

inline b2Vec2 b2Vec2FromCGPoint(float x, float y)
{
    return b2Vec2(x/PTM_RATIO, y/PTM_RATIO);
}

inline CGPoint CGPointFromb2Vec2(b2Vec2 p)
{
    return CGPointMake(p.x * PTM_RATIO, p.y * PTM_RATIO);
}

@interface RCBox2dSprite : CCSprite
{
	b2Body *body_;	// strong ref
    b2Fixture* _fixture;
}

- (void)setPhysicsBody:(b2Body*)body;
- (b2Body*)getBody;

- (void)setFixture:(b2Fixture*)fixture;
- (b2Fixture*)getFixture;
- (CGSize)getBodySize;

//设置Body的位置
- (void)setBodyPos:(CGPoint)pos;
//同时设置Body的位置和精灵的位置
- (void)setPos:(CGPoint)pos;
- (CGPoint)getPos;

@end