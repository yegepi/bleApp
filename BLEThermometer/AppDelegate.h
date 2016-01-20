//
//  AppDelegate.h
//  BLEThermometer
//
//  Created by KS on 5/12/15.
//  Copyright (c) 2015年 KS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

#pragma mark NotificationCenter
/*
通知栏相关资料
 //register Notify of temprature
 //[[NSNotificationCenter defaultCenter] postNotificationName:@"valueChanged" object:self];}
 //- (void)postNotificationName:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempChanged:) name:@"valueChanged" object:nil];
 }
 
 1、发通知
 NSDictionary *myDictionary = [NSDictionary dictionaryWithObject:@"sendValue" forKey:@"sendKey"];
 [[NSNotificationCenter defaultCenter] postNotificationName:@"myNotice" object:nil userInfo:myDictionary];
 
 2、接受通知
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeMethod:) name:@"myNotice" object:nil];
 
 3、调用方法，接受信息。
 - (void)noticeMethod:(NSNotification *)notification
 {
 NSString *getsendValue = [[notification userInfo] valueForKey:@"sendKey"];
 }

 */

#pragma mark Structure
//
//

#pragma mark BLE
/*
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 The bluetooth-central Background Execution Mode
 
 The Core Bluetooth background execution modes are declared by adding the UIBackgroundModes key to your Info.plist:
 bluetooth-central—The app communicates with Bluetooth low energy peripherals using the Core Bluetooth framework.
 bluetooth-peripheral—The app shares data using the Core Bluetooth framework.
  (To display the actual key names: Control-click any of the keys in the editor window and enable the Show Raw Keys/Values item in the contextual window.)
 
 When an app that implements the central role includes the UIBackgroundModes key with the bluetooth-central value in its Info.plist file, the Core Bluetooth framework allows your app to run in the background to perform certain Bluetooth-related tasks. While your app is in the background you can still discover and connect to peripherals, and explore and interact with peripheral data. In addition, the system wakes up your app when any of the CBCentralManagerDelegate or CBPeripheralDelegate delegate methods are invoked, allowing your app to handle important central role events, such as when a connection is established or torn down, when a peripheral sends updated characteristic values, and when a central manager’s state changes.
 
 Although you can perform many Bluetooth-related tasks while your app is in the background, keep in mind that scanning for peripherals while your app is in the background operates differently than when your app is in the foreground. In particular, when your app is scanning for device while in the background:
 
 The CBCentralManagerScanOptionAllowDuplicatesKey scan option key is ignored, and multiple discoveries of an advertising peripheral are coalesced into a single discovery event.
 If all apps that are scanning for peripherals are in the background, the interval at which your central device scans for advertising packets increases. As a result, it may take longer to discover an advertising peripheral.
 These changes help minimize radio usage and improve the battery life on your iOS device.
 
 Any app that declares support for either of the Core Bluetooth background executions modes must follow a few basic guidelines:
 
 Apps should be session based and provide an interface that allows the user to decide when to start and stop the delivery of Bluetooth-related events.
 Upon being woken up, an app has around 10 seconds to complete a task. Ideally, it should complete the task as fast as possible and allow itself to be suspended again. Apps that spend too much time executing in the background can be throttled back by the system or killed.
 Apps should not use being woken up as an opportunity to perform extraneous tasks that are unrelated to why the app was woken up by the system
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 State Preservation and Restoration
 
 connectPeripheral:options: method
 ..causing the connection to the lock to be lost. At this point, the app can simply call the connectPeripheral:options: method of the CBCentralManager class, and because connection requests do not time out, the iOS device will reconnect when the user returns home.
 
 for a given CBCentralManager object, the system keeps track of:
 
 The services the central manager was scanning for (and any scan options specified when the scan started)
 The peripherals the central manager was trying to connect to or had already connected to
 The characteristics the central manager was subscribed to
 
 When your app is relaunched into the background by the system (because a peripheral your app was scanning for is discovered, for instance), you can reinstantiate your app’s central and peripheral managers and restore their state. T
 
 
 */

@end

