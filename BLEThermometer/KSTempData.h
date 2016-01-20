//
//  KSTempData.h
//  
//
//  Created by KS on 5/12/15.
//
//

/*
 NSUserDefaults to save below items:
 1. unit setting - C or F
 2. known devices - connected devices

 使用NSUserDefaults保存自定义对象 
 
 自定义对象：
 .h文件
 Objective-c代码  收藏代码
 #import <Foundation/Foundation.h>
 
 @interface MyObject : NSObject
 {
 NSNumber* lowValue;
 NSNumber* highValue;
 
 NSString* titleString;
 }
 @property(nonatomic, retain)NSNumber* lowValue;
 @property(nonatomic, retain)NSNumber* highValue;
 
 @property(nonatomic, retain)NSString* titleString;
 @end
 
 .m文件：
 Objective-c代码  收藏代码
 #import "MyObject.h"
 
 @implementation MyObject
 @synthesize lowValue, highValue, titleString;
 - (void)encodeWithCoder:(NSCoder *)encoder
 {
 [encoder encodeObject:self.lowValue forKey:@"lowValue"];
 [encoder encodeObject:self.highValue forKey:@"highValue"];
 [encoder encodeObject:self.titleString forKey:@"titleString"];
 }
 - (id)initWithCoder:(NSCoder *)decoder
 {
 if(self = [super init])
 {
 self.lowValue = [decoder decodeObjectForKey:@"lowValue"];
 self.highValue = [decoder decodeObjectForKey:@"highValue"];
 self.titleString = [decoder decodeObjectForKey:@"titleString"];
 }
 return  self;
 }
 
 @end
 
 
 保存单个MyObject方法:
 Objc代码  收藏代码
 - (void)saveCustomObject:(MyObject *)obj
 {
 NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 [defaults setObject:myEncodedObject forKey:@"myEncodedObjectKey"];
 }
 - (MyObject *)loadCustomObjectWithKey:(NSString *)key
 {
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 NSData *myEncodedObject = [defaults objectForKey:key];
 MyObject *obj = (MyObject *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
 return obj;
 }
 
 保存：
 MyObject* testObj = [[MyObject alloc] init];
 testObj.lowValue  =[NSNumber  numberWithFloat:122.2 ];
 testObj.highValue = [NSNumber numberWithFloat:19888 ];
 testObj.titleString = @“baoyu”;
 
 读取：
 MyObject* obj = [self loadCustomObjectWithKey:@"myEncodedObjectKey"];
 NSLog(@"%f, %f, %@", [obj.lowValue floatValue], [obj.highValue floatValue], obj.titleString);
 
 
 保存多个MyObject方法：
 Objc代码  收藏代码
 保存：
 NSMutableArray* array = [[NSMutableArray alloc] init];
 for(int i=0; i<3; i++)
 {
 MyObject* testObj = [[MyObject alloc] init];
 testObj.lowValue  =[NSNumber  numberWithFloat:122.2+i ];
 testObj.highValue = [NSNumber numberWithFloat:19888+i ];
 testObj.titleString = [NSString stringWithFormat:@"BAOYU%d", i];
 
 [array addObject:testObj];
 
 }
 [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:@"myarray"];
 
 
 读取：
 NSData* data  = [[NSUserDefaults standardUserDefaults] objectForKey:@"myarray"];
 
 
 NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
 for(MyObject* obj in oldSavedArray)
 {
 NSLog(@"%f, %f, %@", [obj.lowValue floatValue], [obj.highValue floatValue], obj.titleString);
 }
 
 */

/*
 Data Design:
 KSTempData {
   time
   value
   #no unit, save value as ONLY C, change value when needed in show time
 
 }
 
 
 arrayHistoryData[KSTempData]
 
 KSDevice {
   name
   sn
   lastConnectTime
   lastDisconnectTime
   arrayHistoryData
 }
 
 arrayKnownDevices[KSDevice]
 
 KSNotes {
   time
   comment
   pill
   sleep
 
 
 }
 
 
 
 
 
 */

#import <Foundation/Foundation.h>

@interface KSTempData : NSObject

//time
//YYYYMMDD HHMMSS: 20150309213403

//value
//"37", will be C ALL THE TIME



@end
