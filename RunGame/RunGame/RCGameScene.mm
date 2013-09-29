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
#import "RCSPDownEntity.h"
#import "RCBulletEntity.h"
#import "RCSnakeEntity.h"
#import "RCBombEntity.h"
#import "RCSpringEntity.h"
#import "RCMoneyEntity.h"
#import "RCPauseLayer.h"
#import "RCResultLayer.h"


#define TERRACE_NUM 6
#define TERRACE_INTERVAL 200.0f
#define TOP_HEIGHT_LIMIT (winSize.height - 40)

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameover:) name:GAMEOVER_NOTIFICATION object:nil];
        
        //创建背景
        [self initParallaxBackground];
        
        [self initPhysics];
        
        [self initPanda];
        
        [self initTerraces];
        
        [self initBulletBathNode];
        
        //创建积分条
        [self initScoreBar];
        
        //创建按钮
        [self initButtons];
        
        [self schedule:@selector(tick:)];
        
        [self schedule:@selector(addEntityForTimes:) interval:0.5f];
        
        [RCTool playBgSound:MUSIC_BG];
        [RCTool preloadEffectSound:MUSIC_LAND];
        [RCTool preloadEffectSound:MUSIC_DEAD];
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(self.longTouchTimer)
    {
        [self.longTouchTimer invalidate];
        self.longTouchTimer = nil;
    }
    
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
    self.scoreBar = nil;
    self.actionSprite = nil;
    sharedInstance = nil;
    
    [super dealloc];
}

#pragma mark - Parallax Background

- (void)initParallaxBackground
{
    if(self.parallaxBg)
        [self.parallaxBg removeFromParentAndCleanup:YES];
    
    self.parallaxBg = [RCGameSceneParallaxBackground node];
    [self addChild:self.parallaxBg z:1];
}

#pragma mark - Score Bar

- (void)initScoreBar
{
    if(self.scoreBar)
        [self.scoreBar removeFromParentAndCleanup:YES];
    
    self.scoreBar = [RCScoreBar bar];
    self.scoreBar.panda = self.panda;
    self.scoreBar.anchorPoint = ccp(0,1);
    self.scoreBar.position = ccp(0,WIN_SIZE.height);
    [self addChild:self.scoreBar z:40];
}

#pragma mark - Buttons

- (void)initButtons
{
    CGSize winSize = WIN_SIZE;
    
    CCMenuItem* menuItem = [CCMenuItemImage itemWithNormalImage:@"pause_button.png" selectedImage:nil disabledImage:nil target:self selector:@selector(clickedPauseButton:)];
    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0,1);
    menu.position = ccp(30, winSize.height - 24);
    [self addChild: menu z:50];
    
    CCSprite* bulletButtonSprite = [CCSprite spriteWithSpriteFrameName:@"bullet_button.png"];
    bulletButtonSprite.position = ccp(winSize.width - 70, 60);
    bulletButtonSprite.tag = T_BULLET_BUTTON;
    [self addChild:bulletButtonSprite z:50];
    
    self.actionSprite = [CCSprite spriteWithSpriteFrameName:@"jump_button.png"];
    self.actionSprite.position = ccp(70, 60);
    [self addChild:self.actionSprite z:50];
}

- (void)updateActionSpriteImage:(int)type
{
    if(type == self.actionSpriteType)
        return;
    
    self.actionSpriteType = type;
    
    [self.actionSprite removeFromParentAndCleanup:YES];
    
    if(0 == type)
    {
        self.actionSprite = [CCSprite spriteWithSpriteFrameName:@"jump_button.png"];

//        [self.actionSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"jump_button.png"]];
    }
    else if(1 == type)
    {
        self.actionSprite = [CCSprite spriteWithSpriteFrameName:@"fly_button.png"];
//        [self.actionSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fly_button.png"]];
        
    }
    
    self.actionSprite.position = ccp(70, 60);
    [self addChild:self.actionSprite z:50];
}

- (void)clickedBackButton:(id)token
{
    //先设置熊猫为初始位置，否则tick将检测为gameover状态
    [self.panda setPos:ccp(100,200)];
    [self.panda getBody]->SetActive(false);
    
    if([DIRECTOR isPaused])
        [DIRECTOR resume];
    
    //[RCTool removeCacheFrame:@"game_scene_images.plist"];
    CCScene* scene = [RCHomeScene scene];
    [DIRECTOR replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccWHITE]];
}

- (void)clickedResumeButton:(id)token
{
    if([DIRECTOR isPaused])
    {
        [RCTool resumeBgSound];
        [DIRECTOR resume];
    }
}

- (void)clickedRestartButton:(id)token
{
    //先设置熊猫为初始位置，否则tick将检测为gameover状态
    [self.panda setPos:ccp(100,200)];
    [self.panda getBody]->SetActive(false);
    
    if([DIRECTOR isPaused])
    {
        [RCTool resumeBgSound];
        [DIRECTOR resume];
    }
    
    CCScene* scene = [RCGameScene scene];
    [DIRECTOR replaceScene:scene];
}

- (void)clickedPauseButton:(id)sender
{
    if(NO == [DIRECTOR isPaused])
    {
        [RCTool pauseBgSound];
        [DIRECTOR pause];
        
        RCPauseLayer* pauseLayer = [[[RCPauseLayer alloc] init] autorelease];
        pauseLayer.delegate = self;
        pauseLayer.tag = T_PAUSE_LAYER;
        [self addChild:pauseLayer z:100];
    }
}

- (void)clickedBulletButton:(id)sender
{
    CCLOG(@"clickedBulletButton");
    
    //[self clickedJumpButton];
    
    [self shoot];
}

- (void)clickedActionButton:(id)sender
{
    CCLOG(@"clickedActionButton");
    
    [self clickedJumpButton];
}



#pragma mark - Box2D

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

- (void)tick:(ccTime)dt
{
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	_world->Step(dt, velocityIterations, positionIterations);
    
    CGFloat speed0;
    CGFloat speed1;
    if(self.panda.running)
    {
        speed0 = _terraceSpeed*MULTIPLE;
        speed1 = _entitySpeed*MULTIPLE;
    }
    else
    {
        speed0 = _terraceSpeed;
        speed1 = _entitySpeed;
    }
    
    //移动Terrace
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
	for(RCTerrace* terrace in self.terraceArray)
	{
        if(terrace.position.x <  -1*(terrace.contentSize.width/2.0 + TERRACE_INTERVAL))
        {
            [tempArray addObject:terrace];
        }
        
        [terrace move:ccp(-1*speed0,0)];
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
    
    //更新ActionMenuItem
    if(self.panda.jumpCount >= 2)
        [self updateActionSpriteImage:1];
    else
        [self updateActionSpriteImage:0];
    
    
    //移动道具
    for(CCSprite* entity in _entityArray)
    {
        if(entity.position.x <  -1*entity.contentSize.width)
        {
            [entity setVisible:NO];
            continue;
        }
        
        entity.position = ccp(entity.position.x - speed1,entity.position.y);
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
    
    //CCLOG(@"pandaY:%f,limit:%f",pandaY,winSize.height - 40);
    static float flyY = pandaY;
    if(pandaY > TOP_HEIGHT_LIMIT - 40)//大于限定高度，使用flyY记录高度
    {
        if(flyY < pandaY)
            flyY = pandaY;
        
        flyY += 1;
        
        //CCLOG(@"flyY:%f,pandaY2:%f",flyY,pandaY);
        
        pandaY = flyY;
    }
    else if(flyY > pandaY)//flyY 大于 pandaY 时，使用flyY
    {
        pandaY = flyY;
        flyY -= 10;
    }
    
    
    //CCLOG(@"pandaY3:%f",pandaY);
    CGFloat cY = pandaY - pandaHeight - winSize.height/2.0f;
    if(cY < 0)
    {
        cY = 0;
    }
    
    [self.parallaxBg setPosition:ccp(self.parallaxBg.position.x,-cY)];
    
    //判断游戏结束
    pandaY = [self.panda getBody]->GetPosition().y * PTM_RATIO;
    if(pandaY < -self.panda.contentSize.height/2.0)
    {
        if(NO == self.panda.isDeaded)
            [RCTool playEffectSound:MUSIC_DEAD];
        
        [self.panda dead];
        [self showResult:nil];
    }
    
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
    groundEdge.Set(b2Vec2(0, TOP_HEIGHT_LIMIT/PTM_RATIO),
                   b2Vec2(winSize.width/PTM_RATIO, TOP_HEIGHT_LIMIT/PTM_RATIO));
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
    if(self.panda)
        [self.panda removeFromParentAndCleanup:YES];
    
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
    //清理旧的Terraces
    for(RCTerrace* terrace in _terraceArray)
    {
        [terrace removeFromParentAndCleanup:NO];
    }
    [_terraceArray removeAllObjects];
    
    //创建新的Terraces
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
    else if(ET_SPDOWN == type)
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
            
            RCSPDownEntity* entity = [RCSPDownEntity entity:ET_SPDOWN];
            entity.position = ccp(offset_x,offset_y);
            entity.panda = self.panda;
            entity.gameScene = self;
            [self.parallaxBg addChild:entity z:10];
            [_entityArray addObject:entity];
        }
    }
    else if(ET_BULLET == type)
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
            
            RCBulletEntity* entity = [RCBulletEntity entity:ET_BULLET];
            entity.position = ccp(offset_x,offset_y);
            entity.panda = self.panda;
            [self.parallaxBg addChild:entity z:10];
            [_entityArray addObject:entity];
        }
    }
    else if(ET_MONEY == type)
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
            
            RCMoneyEntity* entity = [RCMoneyEntity entity:ET_MONEY];
            entity.position = ccp(offset_x,offset_y);
            entity.panda = self.panda;
            [self.parallaxBg addChild:entity z:10];
            [_entityArray addObject:entity];
        }
    }
    else if(ET_SPRING == type)
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
            
            RCSpringEntity* entity = [RCSpringEntity entity:ET_SPRING];
            entity.position = ccp(offset_x,offset_y);
            entity.panda = self.panda;
            [self.parallaxBg addChild:entity z:10];
            [_entityArray addObject:entity];
        }
    }
    else if(ET_SNAKE == type)
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
        
        CGFloat offset_x = 0;
        CGFloat offset_y = 0;
        if(terrace)
        {
            CGPoint position = [terrace getPos];
            offset_x = position.x - terrace.contentSize.width/2.0 + arc4random()%(int)(terrace.contentSize.width - 20);
            offset_y = position.y + terrace.contentSize.height/2.0 + 14;
            
            RCSnakeEntity* entity = [RCSnakeEntity entity:ET_SNAKE];
            entity.position = ccp(offset_x,offset_y);
            entity.panda = self.panda;
            entity.gameScene = self;
            [self.parallaxBg addChild:entity z:10];
            [_entityArray addObject:entity];
        }
    }
    else if(ET_BOMB == type)
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
            
            RCBombEntity* entity = [RCBombEntity entity:ET_BOMB];
            entity.position = ccp(offset_x,offset_y);
            entity.panda = self.panda;
            entity.gameScene = self;
            [self.parallaxBg addChild:entity z:10];
            [_entityArray addObject:entity];
        }
    }
}

- (void)addEntityForTimes:(ccTime)delta
{
    int array[] = {0,0,0,0,0,1,1,1,1,2,3,3,3,3,3,4,4,4,4,4,4,4,4,5,6,7};
    
    int size = sizeof(array)/sizeof(int);
    //随机排序数组
    for (NSUInteger i = 0; i < size; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = size - i;
        int n = (arc4random() % nElements) + i;
        
        int temp = array[n];
        array[n] = array[i];
        array[i] = temp;
    }
    
    
    int rand = arc4random()%size;
    rand = array[rand];
    //CCLOG(@"rand:%d",rand);
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
            self.panda.jumpCount = 0;
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
    if(NO == self.panda.isFainting)
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
    
    CCLOG(@"touchLocation:%@",NSStringFromCGPoint(touchLocation));
    
    CGRect bulletButtonRect = CGRectMake(WIN_SIZE.width - 90, 40, 40, 40);
    CCLOG(@"bulletButtonRect:%@",NSStringFromCGRect(bulletButtonRect));
    if(CGRectContainsPoint(bulletButtonRect, touchLocation))
    {
        [self clickedBulletButton:nil];
    }

    if(NO == [self.panda isFlying])
        [self clickedJumpButton];
    else{
        
        CCLOG(@"long touch begin,state:%d",self.panda.state);

        if(nil == self.longTouchTimer)
        {
            self.longTouchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(longTouchTimer:) userInfo:self repeats:YES];
            [self.longTouchTimer fire];
        }
    }
    
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"long touch end,state:%d",self.panda.state);
    if(self.longTouchTimer)
    {
        [self.longTouchTimer invalidate];
        self.longTouchTimer = nil;
    }
}

- (void)longTouchTimer:(NSTimer*)timer
{
    if([self.panda isFlying])
    {
        [self clickedJumpButton];
    }
}

#pragma mark - GameOver

- (void)gameover:(NSNotification*)notification
{
    _terraceSpeed = 0.0;
    _entitySpeed = 0.0;
    
    [self unschedule:@selector(addEntityForTimes:)];
    
    //[self performSelector:@selector(showResult:) withObject:nil afterDelay:1.5];
}

- (void)showResult:(id)argument
{
    if(NO == [DIRECTOR isPaused])
    {
        [RCTool pauseBgSound];
        [DIRECTOR pause];
        
        RCResultLayer* resultLayer = [[[RCResultLayer alloc] init] autorelease];
        resultLayer.delegate = self;
        [resultLayer updateContent:self.panda.distance];
        [self addChild:resultLayer z:100];
        
        [self removeChildByTag:T_BULLET_BUTTON cleanup:YES];
        [self.actionSprite removeFromParentAndCleanup:YES];
    }
}

#pragma mark - Shoot Bullet

- (void)initBulletBathNode
{
    CCSpriteFrame* bulletFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"entity_3.png"];
    self.bulletBatchNode = [CCSpriteBatchNode batchNodeWithTexture:bulletFrame.texture];
    [self addChild:self.bulletBatchNode z:80];
}

- (void)shootAnimation:(CCSprite*)bullet
{
    CGPoint position = bullet.position;
    
    ccBezierConfig config;
    config.controlPoint_1 = ccp(position.x + 40, position.y + 40);
    config.controlPoint_2 = ccp(position.x + 60, position.y + 20);
    config.endPosition = ccp(position.x + 70,-20);
    CCBezierTo* bezierTo = [CCBezierTo actionWithDuration:1.0 bezier:config];
    CCRotateBy* rotateBy = [CCRotateBy actionWithDuration:1.0 angle:180];
    CCSpawn* spawn= [CCSpawn actions:bezierTo,rotateBy,nil];
    [bullet runAction:spawn];
}

- (void)shoot
{
    if(self.panda.bulletCount > 0)
    {
        CCSprite* bullet = [CCSprite spriteWithSpriteFrameName:@"entity_3.png"];
        CGPoint pandaPosition = [self.panda getPos];
        bullet.position = ccp(pandaPosition.x + self.panda.contentSize.width/2.0,pandaPosition.y + 20.0);
        [self.bulletBatchNode addChild:bullet];
        
        [self shootAnimation:bullet];
        
        self.panda.bulletCount--;
    }
}

@end
