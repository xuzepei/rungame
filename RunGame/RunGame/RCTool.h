//
//  RCTool.h
//  BeatMole
//
//  Created by xuzepei on 5/23/13.
//
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@class RCMainViewController;
@class RCNavigationController;
@interface RCTool : NSObject

+ (NSString*)getUserDocumentDirectoryPath;
+ (NSString *)md5:(NSString *)str;
+ (NSString *)getIpAddress;
+ (NSString*)base64forData:(NSData*)theData;
+ (CGSize)getScreenSize;
+ (CGRect)getScreenRect;
+ (BOOL)isIphone5;
+ (BOOL)isIpad;
+ (UIWindow*)frontWindow;
+ (RCNavigationController*)getRootNavigationController;
+ (void)showAlert:(NSString*)aTitle message:(NSString*)message;
+ (CGFloat)systemVersion;

+ (void)addCacheFrame:(NSString*)plistFile;
+ (void)removeCacheFrame:(NSString*)plistFile;

#pragma mark - Settings

+ (void)setBKVolume:(CGFloat)volume;
+ (CGFloat)getBKVolume;

+ (void)setEffectVolume:(CGFloat)volume;
+ (CGFloat)getEffectVolume;

#pragma mark - Network
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaInternet;

#pragma mark - Play Sound
+ (void)preloadEffectSound:(NSString*)soundName;
+ (void)unloadEffectSound:(NSString*)soundName;
+ (void)playEffectSound:(NSString*)soundName;

+ (void)playBgSound:(NSString*)soundName;
+ (void)pauseBgSound;
+ (void)resumeBgSound;

#pragma mark - Record

+ (int)getRecordByType:(int)type;
+ (void)setRecordByType:(int)type value:(int)value;

#pragma mark - Achievement
+ (BOOL)checkAchievementByType:(int)type;
+ (void)setAchievementByType:(int)type value:(int)value;

#pragma mark - Core Data

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator;
+ (NSManagedObjectContext*)getManagedObjectContext;
+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context;

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors;

+ (id)insertEntityObjectForName:(NSString*)entityName
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (void)saveCoreData;

+ (void)deleteOldData;


@end
