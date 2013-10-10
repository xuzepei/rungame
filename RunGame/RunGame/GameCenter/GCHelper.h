//
//  GCHelper.h
//  BeatMole
//
//  Created by xuzepei on 8/12/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GKMatchmakerViewController+LandscapeOnly.h"

@interface GCHelper : NSObject

@property(assign)BOOL userAuthenticated;
@property(assign, readonly)BOOL gameCenterAvailable;

+ (GCHelper*)sharedInstance;
- (void)authenticateLocalUser;
- (BOOL)reportDistance:(int64_t)distance;

@end
