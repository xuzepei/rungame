//
//  RCAchievement.h
//  BeatMole
//
//  Created by xuzepei on 8/5/13.
//
//

#import <Foundation/Foundation.h>

@interface RCAchievement : NSObject

@property(nonatomic,retain)NSMutableArray* itemArray;//需要判断的成就

+ (RCAchievement*)sharedInstance;
+ (NSArray*)getAchievements;

- (void)updateContent;
//- (NSArray*)checkAchievementByLevelIndex:(int)levelIndex;
//
//- (void)recordKillCount:(NSArray*)killCountArray;
//- (int)getAllEnemyKillCountById:(NSString*)enemyId;

@end
