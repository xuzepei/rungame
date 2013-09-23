//
//  RCGameScene.m
//  RunGame
//
//  Created by xuzepei on 9/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCGameScene.h"
#import "RCTool.h"
#import "RCHomeScene.h"
#import "RCGameSceneParallaxBackground.h"
#import "RCSpeedUpEntity.h"
#import "RCSPUpEntity.h"

#define SCROLL_SPEED 8.0f
#define TERRACE_NUM 6
#define TERRACE_INTERVAL 200.0f

static RCGameScene* sharedInstance = nil;
@implementation RCGameScene

+ (id)scene
{
    CCScene* scene = [CCScene node];
    RCGameScene* layer = [RCGameScene node];
    [scene addChild:layer];
    return scene;
}

+ (RCGameScene*)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        sharedInstance = self;
        self.isTouchEnabled = YES;
        self.terraceSpeed = SCROLL_SPEED;
        self.entitySpeed = SCROLL_SPEED;
        _terraceArray = [[NSMutableArray alloc] init];
        _entityArray = [[NSMutableArray alloc] init];
        
        [RCTool addCacheFrame:@"game_scene_images.plist"];
        
        self.parallaxBg = [RCGameSceneParallaxBackground node];
        [self addChild:self.parallaxBg z:1];
        
        CCMenuItem* menuItem = [CCMenuItemImage itemWithNormalImage:@"back_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedBackButton:)];
        CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
        menu.anchorPoint = ccp(0,0);
        menu.position = ccp(20, 20);
        [self addChild: menu z:50];
        
        [self initPhysics];
        
        [self initPanda];
        
        [self initTerraces];
        
        [self schedule:@selector(tick:)];
        
        [self schedule:@selector(addEntityForTimes:) interval:0.5f];
        
        [RCTool playBgSound:MUSIC_BG];
        [RCTool preloadEffectSound:MUSIC_LAND];
        

    }
    
    return self;
}

- (void)dealloc
{
    [RCTool removeCacheFrame:@"game_scene_images.plist"];
    
    if(_debugDraw)
    {
        delete _debugDraw;
        _debugDraw = NULL;
    }
    
    if(_world)
    {
        if(_contactListener)
        {
            delete _contactListener;
            _contactListener = NULL;
        }
        
        if(_groundBody)
        {
            _world->DestroyBody(_groundBody);
            _groundBody = NULL;
        }
        
        delete _world;
        _world = NULL;
    }
    
    if(_groundBody)
        _groundBody = NULL;
    
    _groundFixture = NULL;
    
    self.terraceArray = nil;
    self.panda = nil;
    self.parallaxBg = nil;
    sharedInstance = nil;
    
    [super dealloc];
}

- (void)clickedBackButton:(id)sender
{
    CCScene* scene = [RCHomeScene scene];
    [DIRECTOR replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccWHITE]];
}

- (void)draw
{
	[super draw];

#ifdef DEBUG
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
	kmGLPushMatrix();
	_world->DrawDebugData();
	kmGLPopMatrix();
#endif
}

#pragma mark - Box2D

- (void)tick:(ccTime)dt
{
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	_world->Step(dt, velocityIterations, positionIterations);
    
    //移动Terrace
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
	for(RCTerrace* terrace in self.terraceArray)
	{
        if(terrace.position.x <  -1*(terrace.contentSize.width/2.0 + TERRACE_INTERVAL))
        {
            [tempArray addObject:terrace];
        }
        [terrace move:ccp(-1*_terraceSpeed,0)];
	}
    
    [self.terraceArray removeObjectsInArray:tempArray];
    
    if([self.terraceArray count])
    {
        RCTerrace* lastTerrace = [self.terraceArray lastObject];
        
        CGFloat offset_x = lastTerrace.position.x + lastTerrace.contentSize.width/2.0 + TERRACE_INTERVAL;
        for(RCTerrace* terrace in tempArray)
        {
            offset_x += terrace.contentSize.width/2.0;
            [terrace setPos:ccp(offset_x,terrace.position.y)];
            
            offset_x += terrace.contentSize.width/2.0 + TERRACE_INTERVAL;
        }
        
        [self.terraceArray addObjectsFromArray:tempArray];
    }
    
    [tempArray release];
    
    //移动道具
    for(CCSprite* entity in _entityArray)
    {
        if(entity.position.x <  -1*entity.contentSize.width)
        {
            [entity setVisible:NO];
            continue;
        }
        
        entity.position = ccp(entity.position.x - _entitySpeed,entity.position.y);
    }
    
    for(CCSprite* entity in _entityArray)
    {
        if(NO == [entity visible])
            [entity removeFromParentAndCleanup:YES];
    }
    
    //碰撞监测
    if([self.panda needCheckCollision])
    {
        //CCLOG(@"isFlying:%d",[self.panda isFlying]);
        [self checkCollision];
    }
    
    //调整镜头
    CGFloat pandaHeight = self.panda.contentSize.height;
    CGFloat pandaY = [self.panda getBody]->GetPosition().y * PTM_RATIO;
    CGSize winSize = WIN_SIZE;
    
    CGFloat cY = pandaY - pandaHeight - winSize.height/2.0f;
    if(cY < 0)
    {
        cY = 0;
    }
    
    // do some parallax scrolling
//    [objectLayer setPosition:ccp(0,-cY)];
//    [floorBackground setPosition:ccp(0,-cY*0.8)]; // move floor background slower
    [self.parallaxBg setPosition:ccp(self.parallaxBg.position.x,-cY)];      // move main background even slower
    
//    for(RCTerrace* terrace in self.terraceArray)
//    {
//        //CGFloat cY = pandaY - terrace.contentSize.height - terrace.position.y;
//        [terrace setPos:CGPointMake(terrace.position.x,200)];
//    }

}

- (id)checkCollision
{
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin();
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        for(RCTerrace* terrace in _terraceArray)
        {
            if ((contact.fixtureA == [self.panda getFixture] && contact.fixtureB == [terrace getFixture]) ||
                (contact.fixtureA == [terrace getFixture] && contact.fixtureB == [self.panda getFixture]))
            {
                b2Vec2 temp0 = [self.panda getBody]->GetPosition();
                b2Vec2 temp1 = [terrace getBody]->GetPosition();
                
//                CCLOG(@"panda.y:%f,terrace.y:%f,ps:%f",temp0.y,temp1.y,temp1.y + [self.panda getBodySize].height/2.0 + [terrace getBodySize].height/2.0);
//                CCLOG(@"isFlying1:%d",[self.panda isFlying]);
                
                //减0.01的高度误差，用来判断on terrace
                if(temp0.y >= temp1.y + [self.panda getBodySize].height/2.0 + [terrace getBodySize].height/2.0 - 0.01)
                {
                    //CCLOG(@"Panda on terrace");
                    [self land:terrace];
                }
                else
                {
                    //CCLOG(@"Panda hit terrace");
                }
                
                return terrace;
            }
        }
        
        if((contact.fixtureA == [self.panda getFixture] && contact.fixtureB == _groundFixture) ||
            (contact.fixtureA == _groundFixture && contact.fixtureB == [self.panda getFixture]))
        {
            NSLog(@"Panda hit ground!");
            return nil;
        }
    }

    return NULL;
}

- (void)initPhysics
{
    CGSize winSize = WIN_SIZE;
    
    //创建world
    b2Vec2 gravity = b2Vec2(0.0f,-30.0f)
    ;
    _world = new b2World(gravity);
    _world->SetAllowSleeping(true);
    _world->SetContinuousPhysics(true);
    
    //碰撞监听
    _contactListener = new MyContactListener();
    _world->SetContactListener(_contactListener);

#ifdef DEBUG
    _debugDraw = new GLESDebugDraw(PTM_RATIO);
	_world->SetDebugDraw(_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	_debugDraw->SetFlags(flags);
#endif
    
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    _groundBody = _world->CreateBody(&groundBodyDef);
    
    //为屏幕的每一个边界创建一个多边形shape
    b2EdgeShape groundEdge;
    
    //top edge
    groundEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO),
                   b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
    _groundFixture = _groundBody->CreateFixture(&groundEdge,0);
    
    //bottom edge
    groundEdge.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, -winSize.height));
    _groundBody->CreateFixture(&groundEdge,-winSize.height);
    
    //left edge
    groundEdge.Set(b2Vec2(0,0), b2Vec2(0, 0/PTM_RATIO));
    _groundBody->CreateFixture(&groundEdge,0);
    
    //right edge
    groundEdge.Set(b2Vec2(winSize.width/PTM_RATIO,
                          0), b2Vec2(winSize.width/PTM_RATIO, 0/PTM_RATIO));
    _groundBody->CreateFixture(&groundEdge,0);
}

- (void)initPanda
{
    self.panda = [RCPanda panda];
    self.panda.position = ccp(100,200);
    [self addChild:self.panda z:10];
    [self.panda walk];
    
    //创建球的body
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(self.panda.position.x/PTM_RATIO, self.panda.position.y/PTM_RATIO);
    bodyDef.fixedRotation = true; // 不旋转
    b2Body* body = _world->CreateBody(&bodyDef);
    
    //定义形状
    b2PolygonShape box;
    box.SetAsBox(self.panda.contentSize.width/2.0/PTM_RATIO, self.panda.contentSize.height/2.0/PTM_RATIO);
    
    //定制器
    b2FixtureDef shapeDef;
    shapeDef.shape = &box;
    shapeDef.density = 1.0f; //密度,就是单位体积的质量。因此，一个对象的密度越大，那么它就有更多的质量，当然就会越难以移动。
    shapeDef.friction = 0.1f; //摩擦系数,它的范围是0-1.0, 0意味着没有摩擦，1代表最大摩擦，几乎移不动的摩擦。
    shapeDef.restitution = 0.0f; //补偿系数,它的范围也是0到1.0。 0意味着对象碰撞之后不会反弹，1意味着是完全弹性碰撞，会以同样的速度反弹。
    b2Fixture* fixture = body->CreateFixture(&shapeDef);
    [self.panda setFixture:fixture];
    
    //限制移动
    b2PrismaticJointDef jointDef;
    b2Vec2 worldAxis(0.0f, 1.0f);
    jointDef.collideConnected = true;
    jointDef.Initialize(body, _groundBody,
                        body->GetWorldCenter(), worldAxis);
    _world->CreateJoint(&jointDef);

    [self.panda setPhysicsBody:body];
}

- (void)initTerraces
{
    CGFloat offset_x = 20;
    CGFloat offset_y = 80;
    
    for(int i = 0; i < TERRACE_NUM; i++)
    {
        RCTerrace* terrace = [RCTerrace terrace];
        
        CGFloat random = arc4random()%60;
        CGFloat random2 = MAX(20.0 + terrace.contentSize.width/2.0,arc4random()%100);
        offset_x += random2;
        terrace.position = ccp(offset_x,offset_y + random);
        
        [self.parallaxBg addChild:terrace z:10];
        
        //创建球的body
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(terrace.position.x/PTM_RATIO, terrace.position.y/PTM_RATIO);
        b2Body* body = _world->CreateBody(&bodyDef);
        
        //定义形状
        b2PolygonShape box;
        box.SetAsBox(terrace.contentSize.width/2.0/PTM_RATIO, terrace.contentSize.height/2.0/PTM_RATIO);
        
        //定制器
        b2FixtureDef shapeDef;
        shapeDef.shape = &box;
        shapeDef.density = 10.0f;
        shapeDef.friction = 0.1f;
        shapeDef.restitution = 0.0f;
        //shapeDef.isSensor =true; 
        b2Fixture* fixture = body->CreateFixture(&shapeDef);
        [terrace setFixture:fixture];
        
        [terrace setPhysicsBody:body];
        
        //限制移动
        b2PrismaticJointDef jointDef;
        b2Vec2 worldAxis(1.0f, 0.0f);
        jointDef.collideConnected = true;
        jointDef.Initialize(body, _groundBody,
                            body->GetWorldCenter(), worldAxis);
        _world->CreateJoint(&jointDef);
        
        offset_x += terrace.contentSize.width/2.0;
        
        [_terraceArray addObject:terrace];
    }

}

#pragma mark - Add Entity

- (void)addEntityByType:(int)type
{
    CGSize winSize = WIN_SIZE;
    if(ET_SPEEDUP == type)
    {
        RCTerrace* terrace = nil;
        for(RCTerrace* temp in _terraceArray)
        {
            CGPoint position = [temp getPos];
            if(position.x > winSize.width)
            {
                terrace = temp;
            }
        }
        
        CGFloat offset_x = 0.0;
        CGFloat offset_y = arc4random()%50 + 50;
        
        if(terrace)
        {
            CGPoint position = [terrace getPos];
            offset_x = winSize.width;
            offset_y += position.y + terrace.contentSize.height/2.0;
            
            RCSpeedUpEntity* entity = [RCSpeedUpEntity entity:ET_SPEEDUP];
            entity.position = ccp(offset_x,offset_y);
            entity.panda = self.panda;
            [self.parallaxBg addChild:entity z:10];
            [_entityArray addObject:entity];
        }
    }
    else if(ET_SPUP == type)
    {
        
        RCTerrace* terrace = nil;
        for(RCTerrace* temp in _terraceArray)
        {
            CGPoint position = [temp getPos];
            if(position.x > winSize.width)
            {
                terrace = temp;
            }
        }
        
        CGFloat offset_x = winSize.width;
        CGFloat offset_y = arc4random()%50 + 50;
        if(terrace)
        {
            CGPoint position = [terrace getPos];
            offset_x = winSize.width;
            offset_y += position.y + terrace.contentSize.height/2.0;
            
            RCSPUpEntity* entity = [RCSPUpEntity entity:ET_SPUP];
            entity.position = ccp(offset_x,offset_y);
            entity.panda = self.panda;
            [self.parallaxBg addChild:entity z:10];
            [_entityArray addObject:entity];
        }
    }
}

- (void)addEntityForTimes:(ccTime)delta
{
    int rand = arc4random()%(ET_SPUP + 1);
    [self addEntityByType:rand];
}

#pragma mark - Action

- (void)land:(RCTerrace*)terrace
{
    if(terrace)
    {
        if(NO == [self.panda isWalking] && NO == [self.panda isScrolling])
        {
            CCLOG(@"land");
            [RCTool playEffectSound:MUSIC_LAND];
            [terrace beHit];
        }
    }
    
    if([self.panda isRolling] || [self.panda isFlying])
        [self.panda scroll];
    else
        [self.panda walk];
}

- (void)clickedJumpButton
{
    [self.panda jump];
}

#pragma mark - Touch Event

- (void)registerWithTouchDispatcher
{
    [[DIRECTOR touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
   
    [self clickedJumpButton];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

@end
