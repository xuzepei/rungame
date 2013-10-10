//
//  GCHelper.m
//  BeatMole
//
//  Created by xuzepei on 8/12/13.
//
//

#import "GCHelper.h"
#import <UIKit/UIKit.h>
#import "RCTool.h"

@implementation GCHelper

+ (GCHelper*)sharedInstance
{
    static GCHelper* sharedInstance = nil;
    
    if(nil == sharedInstance)
    {
        @synchronized([GCHelper class])
        {
            if(nil == sharedInstance)
            {
                sharedInstance = [[GCHelper alloc] init];
            }
        }
    }
    
    return sharedInstance;
}

- (BOOL)isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    //check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    
    if (self = [super init])
    {
        _gameCenterAvailable = [self isGameCenterAvailable];
        if(_gameCenterAvailable)
        {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated){
        NSLog(@"Authentication changed: player authenticated.");
        _userAuthenticated = TRUE;
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        _userAuthenticated = FALSE;
    }
}

- (void)authenticateLocalUser
{
    if(!_gameCenterAvailable)
        return;
    
    if(_userAuthenticated)
        return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
}

- (BOOL)reportDistance:(int64_t)distance
{
    if(NO == _userAuthenticated)
        return NO;
    
    if(NO == [RCTool isReachableViaInternet])
        return NO;

    BOOL __block b = YES;
    GKScore* reporter = [[[GKScore alloc] initWithCategory:LEADERBOARD_DISTANCE_ID] autorelease];
    reporter.value = distance;
    [reporter reportScoreWithCompletionHandler: ^(NSError *error)
    {
        NSLog(@"reportScore,error:%@",error);
        
        if(error)
            b = NO;
    }];
    
    return b;
}

@end
