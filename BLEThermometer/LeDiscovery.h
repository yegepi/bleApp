/*

 File: LeDiscovery.h
 
 Abstract: Scan for and discover nearby LE peripherals with the 
 matching service UUID.
 
 Version: 1.0

 
 */



#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "LeTemperatureAlarmService.h"



/****************************************************************************/
/*							UI protocols									*/
/****************************************************************************/
@protocol LeDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
@end



/****************************************************************************/
/*							Discovery class									*/
/****************************************************************************/
@interface LeDiscovery : NSObject

+ (id) sharedInstance;


/****************************************************************************/
/*								UI controls									*/
/****************************************************************************/
@property (nonatomic, assign) id<LeDiscoveryDelegate>           discoveryDelegate;
@property (nonatomic, assign) id<LeTemperatureAlarmProtocol>	peripheralDelegate;


/****************************************************************************/
/*								Actions										*/
/****************************************************************************/
- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) stopScanning;

- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;


/****************************************************************************/
/*							Access to the devices							*/
/****************************************************************************/
@property (retain, nonatomic) NSMutableArray    *foundPeripherals;
@property (retain, nonatomic) NSMutableArray	*connectedServices;	// Array of LeTemperatureAlarmService
@end
