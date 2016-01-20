/*
 
 File: LeTemperatureAlarmService.h
 
 Abstract: Temperature Alarm Service Header - Connect to a peripheral 
 and get notified when the temperature changes and goes past settable
 maximum and minimum temperatures.
 
 Version: 1.0
 
 */



#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreGraphics/CoreGraphics.h>


/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
extern NSString *kDeviceServiceUUIDString;                 // DEADF154-0000-0000-0000-0000DEADF154     Service UUID
extern NSString *kTemperatureServiceUUIDString;
extern NSString *kBatteryServiceUUIDString;

extern NSString *kCurrentTemperatureCharacteristicUUIDString;   // CCCCFFFF-DEAD-F154-1319-740381000000     Current Temperature Characteristic
extern NSString *kMinimumTemperatureCharacteristicUUIDString;   // C0C0C0C0-DEAD-F154-1319-740381000000     Minimum Temperature Characteristic
extern NSString *kMaximumTemperatureCharacteristicUUIDString;   // EDEDEDED-DEAD-F154-1319-740381000000     Maximum Temperature Characteristic
extern NSString *kAlarmCharacteristicUUIDString;                // AAAAAAAA-DEAD-F154-1319-740381000000     Alarm Characteristic

extern NSString *kAlarmServiceEnteredBackgroundNotification;
extern NSString *kAlarmServiceEnteredForegroundNotification;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class LeTemperatureAlarmService;

typedef enum {
    kAlarmHigh  = 0,
    kAlarmLow   = 1,
} AlarmType;

@protocol LeTemperatureAlarmProtocol<NSObject>
- (void) alarmService:(LeTemperatureAlarmService*)service didSoundAlarmOfType:(AlarmType)alarm;
- (void) alarmServiceDidStopAlarm:(LeTemperatureAlarmService*)service;
- (void) alarmServiceDidChangeTemperature:(LeTemperatureAlarmService*)service;
- (void) alarmServiceDidChangeTemperatureBounds:(LeTemperatureAlarmService*)service;
- (void) alarmServiceDidChangeStatus:(LeTemperatureAlarmService*)service;
- (void) alarmServiceDidReset;
@end


/****************************************************************************/
/*						Temperature Alarm service.                          */
/****************************************************************************/
@interface LeTemperatureAlarmService : NSObject

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeTemperatureAlarmProtocol>)controller;
- (void) reset;
- (void) start;

/* Querying Sensor */
@property (readonly) CGFloat temperature;

/* Behave properly when heading into and out of the background */
- (void)enteredBackground;
- (void)enteredForeground;

@property (readonly) CBPeripheral *peripheral;
@end
