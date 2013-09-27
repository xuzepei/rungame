//
//  RCTool.m
//  BeatMole
//
//  Created by xuzepei on 5/23/13.
//
//

#import "RCTool.h"
#import "CCAnimation+Helper.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "SimpleAudioEngine.h"

@implementation RCTool

+ (NSString*)getUserDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];	
}

+ (NSString *)getIpAddress
{
	
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

+ (NSString*)base64forData:(NSData*)theData
{
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
	NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
		NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
			
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
		
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

+ (UIWindow*)frontWindow
{
	UIApplication *app = [UIApplication sharedApplication];
    NSArray* windows = [app windows];
    
    for(int i = [windows count] - 1; i >= 0; i--)
    {
        UIWindow *frontWindow = [windows objectAtIndex:i];
        //NSLog(@"window class:%@",[frontWindow class]);
        //        if(![frontWindow isKindOfClass:[MTStatusBarOverlay class]])
        return frontWindow;
    }
    
	return nil;
}

#pragma mark - 兼容iOS6和iPhone5

+ (CGSize)getScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGRect)getScreenRect
{
    return [[UIScreen mainScreen] bounds];
}

+ (BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        if(568 == size.height)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isIpad
{
	UIDevice* device = [UIDevice currentDevice];
	if(device.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		return NO;
	}
	else if(device.userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		return YES;
	}
	
	return NO;
}

+ (RCNavigationController*)getRootNavigationController
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    return appDelegate.navigationController;
}

+ (void)showAlert:(NSString*)aTitle message:(NSString*)message
{
	if(0 == [aTitle length] || 0 == [message length])
		return;
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: aTitle
													message: message
												   delegate: self
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
    alert.tag = 110;
	[alert show];
	[alert release];
	
    
}

+ (CGFloat)systemVersion
{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return systemVersion;
}

+ (void)addCacheFrame:(NSString*)plistFile
{
    if(0 == [plistFile length])
        return;
    
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:plistFile];
}

+ (void)removeCacheFrame:(NSString*)plistFile
{
    if(0 == [plistFile length])
        return;
    
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache removeSpriteFramesFromFile:plistFile];
}

#pragma mark - Settings

+ (void)setBKVolume:(CGFloat)volume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setFloat:volume forKey:@"bk_volume"];
    [temp synchronize];
}

+ (CGFloat)getBKVolume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [temp objectForKey:@"bk_volume"];
    if(value)
        return [value floatValue];
    
    return 1.0;
}

+ (void)setEffectVolume:(CGFloat)volume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setFloat:volume forKey:@"effect_volume"];
    [temp synchronize];
}

+ (CGFloat)getEffectVolume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [temp objectForKey:@"effect_volume"];
    if(value)
        return [value floatValue];
    
    return 1.0;
}

#pragma mark - Network

+ (BOOL)isReachableViaWiFi
{
	Reachability* wifiReach = [Reachability reachabilityForLocalWiFi];
	[wifiReach startNotifier];
	NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return NO;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	return NO;
}

+ (BOOL)isReachableViaInternet
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

#pragma mark - Play Sound

+ (void)preloadEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:soundName];
}

+ (void)unloadEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[SimpleAudioEngine sharedEngine] unloadEffect:soundName];
}

+ (void)playEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[SimpleAudioEngine sharedEngine] playEffect:soundName];
}

+ (void)playBgSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:soundName loop:YES];
}

+ (void)pauseBgSound
{
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

+ (void)resumeBgSound
{
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

#pragma mark - Record

+ (int)getRecordByType:(int)type
{
//    RT_DISTANCE,
//    RT_MONEY,
//    RT_SHIELD,
//    RT_BAMBOO,
//    RT_MILK,
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    switch (type) {
        case RT_DISTANCE:
        case RT_MONEY:
        case RT_SHIELD:
        case RT_BULLET:
        case RT_MILK:
        {
            NSString* key = [NSString stringWithFormat:@"RT_%d",type];
            return [[defaults objectForKey:key] intValue];
        }
        default:
            break;
    }
}

+ (void)setRecordByType:(int)type value:(int)value
{
    NSString* key = [NSString stringWithFormat:@"RT_%d",type];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:value] forKey:key];
    [defaults synchronize];
}

#pragma mark - Core Data

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	return [appDelegate persistentStoreCoordinator];
}

+ (NSManagedObjectContext*)getManagedObjectContext
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	return [appDelegate managedObjectContext];
}

+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context

{
	if(0 == [entityName length] || nil == context)
		return nil;
	
    if(nil == context)
	   context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectIDResultType];
	
	
	//	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
	//															initWithFetchRequest:fetchRequest
	//															managedObjectContext:context
	//															sectionNameKeyPath:nil
	//															cacheName:@"Root"];
	//
	//	//[context tryLock];
	//	[fetchedResultsController performFetch:nil];
	//	//[context unlock];
	
	NSArray* objectIDs = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	if(objectIDs && [objectIDs count])
		return [objectIDs lastObject];
	else
		return nil;
}

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors
{
	if(0 == [entityName length])
		return nil;
	
	NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectResultType];
	
	NSArray* objects = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	return objects;
}

+ (id)insertEntityObjectForName:(NSString*)entityName
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(0 == [entityName length] || nil == managedObjectContext)
		return nil;
	
	NSManagedObjectContext* context = managedObjectContext;
	id entityObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
													inManagedObjectContext:context];
	
	
	return entityObject;
	
}

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(nil == objectID || nil == managedObjectContext)
		return nil;
	
	return [managedObjectContext objectWithID:objectID];
}

+ (void)saveCoreData
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	NSError *error = nil;
    if ([appDelegate managedObjectContext] != nil)
	{
        if ([[appDelegate managedObjectContext] hasChanges] && ![[appDelegate managedObjectContext] save:&error])
		{
            
        }
    }
}

+ (void)deleteOldData
{
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isHidden == NO"];
//    NSArray* translations = [RCTool getExistingEntityObjectsForName:@"Translation" predicate:nil sortDescriptors:nil];
//    NSManagedObjectContext* context = [RCTool getManagedObjectContext];
//    for(Translation* translation in translations)
//    {
//        [context deleteObject:translation];
//    }
//    [RCTool saveCoreData];
//    
//    NSString* recorDirectoryPath = [NSString stringWithFormat:@"%@/record",[RCTool getUserDocumentDirectoryPath]];
//    [RCTool removeFile:recorDirectoryPath];
//    
//    NSString* ttsDirectoryPath = [[RCTool getUserDocumentDirectoryPath] stringByAppendingString:@"/tts"];
//    [RCTool removeFile:ttsDirectoryPath];
}

@end
