//
//  RCStoreLayer.h
//  RunGame
//
//  Created by xuzepei on 10/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RCStoreLayerDelegate <NSObject>

- (void)clickedStoreBackButton:(id)token;

@end

@interface RCStoreLayer : CCLayer {
    
}

@property(assign)id delegate;
@property(nonatomic,retain)CCLabelAtlas* moneyLabel;
@property(nonatomic,retain)CCLabelAtlas* shieldLabel;
@property(nonatomic,retain)CCLabelAtlas* bambooLabel;
@property(nonatomic,retain)CCLabelAtlas* milkLabel;
@property(nonatomic,retain)CCLabelAtlas* shieldLabel2;
@property(nonatomic,retain)CCLabelAtlas* bambooLabel2;
@property(nonatomic,retain)CCLabelAtlas* milkLabel2;
@property(assign)CGRect clickedButtonRect;
@property(nonatomic,retain)CCSprite* clickedButtonEffect;
@property(assign)int shieldPrice;
@property(assign)int bambooPrice;
@property(assign)int milkPrice;

@end
