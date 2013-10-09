//
//  RCAchievementLayer.h
//  RunGame
//
//  Created by xuzepei on 10/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCAchievementLayerDelegate <NSObject>

- (void)clickedAchievementBackButton:(id)token;

@end

@interface RCAchievementLayer : CCLayer {
    
}

@property(assign)id delegate;

@end
