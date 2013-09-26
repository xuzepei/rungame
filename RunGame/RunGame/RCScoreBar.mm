//
//  RCScoreBar.m
//  RunGame
//
//  Created by xuzepei on 9/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCScoreBar.h"

#define DEFAULT_SP_VALUE 10.0f

@implementation RCScoreBar

+ (id)bar
{
	return [[[self alloc] initWithImage] autorelease];
}

- (id)initWithImage
{
	if((self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"scorebar_bg.png"]]))
	{
        self.scale = WIN_SIZE.width/568.0f;
 		
        self.spBar = [CCSprite spriteWithSpriteFrameName:@"sp_bar.png"];
        self.spBar.anchorPoint = ccp(0, 0.5);
        self.spBar.position = ccp(84,40);
        [self addChild:self.spBar];
        
        [self initLabels];
        
        [self scheduleUpdate];
	}
    
	return self;
}

- (void)dealloc
{
    self.panda = nil;
    self.spBar = nil;
    
    self.label0 = nil;
    self.label1 = nil;
    self.label2 = nil;
    self.label3 = nil;
    self.label4 = nil;
    
    [super dealloc];
}

- (void)update:(ccTime)delta
{
    [self updateSP];
    
    [self updateShieldCount];
    [self updateBulletCount];
    [self updateMilkCount];
    [self updateMoney];
    [self updateDistance];
}

- (void)updateSP
{
    if(nil == self.panda)
        return;
    
    CGFloat scaleX = self.panda.spValue / DEFAULT_SP_VALUE;
    //CCLOG(@"scaleX:%f",scaleX);
    self.spBar.scaleX = scaleX;
}

- (void)initLabels
{
    self.label0 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:12.5 itemHeight:12.5 startCharMap:'0'] autorelease];
    self.label0.anchorPoint = ccp(0, 0);
    self.label0.position = ccp(655.0/2.0, 11.6);
    [self addChild:self.label0];
    
    self.label1 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:12.5 itemHeight:12.5 startCharMap:'0'] autorelease];
    self.label1.anchorPoint = ccp(0, 0);
    self.label1.position = ccp(735.0/2.0, 11.6);
    [self addChild:self.label1];
    
    self.label2 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"light_number.png" itemWidth:12.5 itemHeight:12.5 startCharMap:'0'] autorelease];
    self.label2.anchorPoint = ccp(0, 0);
    self.label2.position = ccp(813.0/2.0, 11.6);
    [self addChild:self.label2];
    
    self.label3 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"bold_number.png" itemWidth:13 itemHeight:13 startCharMap:'0'] autorelease];
    self.label3.anchorPoint = ccp(1, 0);
    self.label3.position = ccp(1050.0/2.0, 28);
    [self addChild:self.label3];
    
    self.label4 = [[[CCLabelAtlas alloc] initWithString:@"0" charMapFile:@"bold_number.png" itemWidth:13 itemHeight:13 startCharMap:'0'] autorelease];
    self.label4.anchorPoint = ccp(1, 0);
    self.label4.position = ccp(1050.0/2.0, 4);
    [self addChild:self.label4];
}

- (void)updateShieldCount
{
    [self.label0 setString:[NSString stringWithFormat:@"%d", 0]];
}

- (void)updateBulletCount
{
    if(self.panda)
        [self.label1 setString:[NSString stringWithFormat:@"%d", self.panda.bulletCount]];
}

- (void)updateMilkCount
{
    [self.label2 setString:[NSString stringWithFormat:@"%d", 0]];
}

- (void)updateMoney
{
    if(self.panda)
        [self.label3 setString:[NSString stringWithFormat:@"%d", self.panda.money]];
}

- (void)updateDistance
{
    if(self.panda)
        [self.label4 setString:[NSString stringWithFormat:@"%d", self.panda.distance]];
}

@end
