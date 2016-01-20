//
//  TempDataEntity.h
//  
//
//  Created by KS on 7/12/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TempDataEntity : NSManagedObject

@property (nonatomic, retain) NSString * deviceid;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * value;

@end
