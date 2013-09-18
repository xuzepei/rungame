//
//  Achievement.h
//  BeatMole
//
//  Created by xuzepei on 8/5/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Achievement : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * enable;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * repeat;
@property (nonatomic, retain) NSNumber * finished;
@property (nonatomic, retain) NSString * param;


@end
