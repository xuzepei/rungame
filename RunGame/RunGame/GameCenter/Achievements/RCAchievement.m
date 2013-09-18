//
//  RCAchievement.m
//  BeatMole
//
//  Created by xuzepei on 8/5/13.
//
//

#import "RCAchievement.h"
#import "RCTool.h"
#import "Achievement.h"

@implementation RCAchievement

+ (RCAchievement*)sharedInstance
{
    static RCAchievement* sharedInstance = nil;
    
    if(nil == sharedInstance)
    {
        @synchronized([RCAchievement class])
        {
            if(nil == sharedInstance)
            {
                sharedInstance = [[RCAchievement alloc] init];
            }
        }
    }
    
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        _itemArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    self.itemArray = nil;
    [super dealloc];
}

- (void)updateContent
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"enable == YES && (finished == NO || (finished == YES && repeat == NO))"];
    NSArray* array = [RCTool getExistingEntityObjectsForName:@"Achievement" predicate:predicate sortDescriptors:nil];
    
    if([array count])
    {
        [_itemArray removeAllObjects];
        [_itemArray addObjectsFromArray:array];
    }
    else
    {
        NSArray* array = [RCTool getExistingEntityObjectsForName:@"Achievement" predicate:nil sortDescriptors:nil];
        if(0 == [array count])
        {
            [_itemArray removeAllObjects];
            NSString* path = [[NSBundle mainBundle] pathForResource:@"achievement" ofType:@"plist"];
            NSArray* array = [NSArray arrayWithContentsOfFile:path];
            
            for(NSDictionary* item in array)
            {
                BOOL enable = [[item objectForKey:@"enable"] boolValue];
                if(enable)
                {
                    Achievement* achievement = [RCTool insertEntityObjectForName:@"Achievement" managedObjectContext:[RCTool getManagedObjectContext]];
                    if(achievement)
                    {
                        achievement.enable = [NSNumber numberWithBool:enable];
                        achievement.id = [item objectForKey:@"id"];
                        achievement.desc = [item objectForKey:@"desc"];
                        achievement.repeat = [item objectForKey:@"repeatedly_display"];
                        achievement.name = [item objectForKey:@"name"];
                        achievement.param = [item objectForKey:@"param"];
                        
                        [_itemArray addObject:achievement];
                    }
                }
                
                
            }
            
            [RCTool saveCoreData];
        }
    }
}

+ (NSArray*)getAchievements
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"enable == YES && finished == YES"];
   return [RCTool getExistingEntityObjectsForName:@"Achievement" predicate:predicate sortDescriptors:nil];
}


@end
