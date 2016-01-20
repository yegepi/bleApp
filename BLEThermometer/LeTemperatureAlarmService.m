/*

 File: LeTemperatureAlarmService.m
 
 temprature:       1809
    value           2a1e
 deviceInfo:       180a
    systemID:       2a23
    sn:             2a25
 battery:          180f
    battery:        2a19
 Version: 1.0


 */

#import "LeTemperatureAlarmService.h"
#import "LeDiscovery.h"

NSString *kDeviceServiceUUIDString = @"180A";
NSString *kTemperatureServiceUUIDString = @"1809";
NSString *kBatteryServiceUUIDString = @"180F";

NSString *kAlarmCharacteristicUUIDString = @"AAAAAAAA-DEAD-F154-1319-740381000000";

NSString *kAlarmServiceEnteredBackgroundNotification = @"kAlarmServiceEnteredBackgroundNotification";
NSString *kAlarmServiceEnteredForegroundNotification = @"kAlarmServiceEnteredForegroundNotification";

@interface LeTemperatureAlarmService() <CBPeripheralDelegate> {
@private
    CBPeripheral		*servicePeripheral;
    
    CBService			*temperatureAlarmService;
    CBService           *batteryService;
    
    CBCharacteristic    *tempCharacteristic;
    CBCharacteristic	*minTemperatureCharacteristic;
    CBCharacteristic    *maxTemperatureCharacteristic;
    CBCharacteristic    *alarmCharacteristic;
    
    CBUUID              *temperatureAlarmUUID;
    CBUUID              *minimumTemperatureUUID;
    CBUUID              *maximumTemperatureUUID;
    CBUUID              *currentTemperatureUUID;


    id<LeTemperatureAlarmProtocol>	peripheralDelegate;
}
@end



@implementation LeTemperatureAlarmService


@synthesize peripheral = servicePeripheral;


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeTemperatureAlarmProtocol>)controller
{
    self = [super init];
    if (self) {
        servicePeripheral = [peripheral retain];
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        
//        temperatureAlarmUUID	= [[CBUUID UUIDWithString:kAlarmCharacteristicUUIDString] retain];
	}
    return self;
}


- (void) dealloc {
	if (servicePeripheral) {
		[servicePeripheral setDelegate:[LeDiscovery sharedInstance]];
		[servicePeripheral release];
		servicePeripheral = nil;
        
        [minimumTemperatureUUID release];
        [maximumTemperatureUUID release];
        [currentTemperatureUUID release];
        [temperatureAlarmUUID release];
    }
    [super dealloc];
}


- (void) reset
{
	if (servicePeripheral) {
		[servicePeripheral release];
		servicePeripheral = nil;
	}
}



#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) start
{
	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kTemperatureServiceUUIDString];
	NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID, nil];

    //[servicePeripheral discoverServices:serviceArray];
    [servicePeripheral discoverServices:nil];
    
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
	NSArray		*uuids	= [NSArray arrayWithObjects:currentTemperatureUUID, // Current Temp
								   minimumTemperatureUUID, // Min Temp
								   maximumTemperatureUUID, // Max Temp
								   temperatureAlarmUUID, // Alarm Characteristic
								   nil];

	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return ;
	}

	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}

	temperatureAlarmService = nil;
    
    
	for (CBService *service in services) {
      
        CBUUID *tempID = [service UUID];
        NSString *s = tempID.UUIDString;
        
        [peripheral discoverCharacteristics:nil forService:service];
        
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kBatteryServiceUUIDString]]) {
			batteryService = service;
			break;
		}
	}

	if (batteryService) {
//		[peripheral discoverCharacteristics:uuids forService:temperatureAlarmService];
        //[peripheral discoverCharacteristics:nil forService:batteryService];
	}
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
    
    CBUUID *tempID = [service UUID];
    NSString *s = tempID.UUIDString;
 
    
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
    NSLog(@"\n---SERVICE--- %@", s);
	for (characteristic in characteristics) {
        CBUUID *charID = [characteristic UUID];
        NSString *sCharID = charID.UUIDString;
        
        NSLog(@"discovered characteristic %@ %@", [characteristic UUID], sCharID);
        
        if ( [sCharID containsString:@"2A1E"]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        if ([sCharID containsString:@"2A23"]
            ||[sCharID containsString:@"2A25"]
            ||[sCharID containsString:@"2A19"]) {
        //if (sCharID == @"2A1E" || sCharID == @"2A23" || sCharID == @"2A25" || sCharID == @"2A19" ){
            [peripheral readValueForCharacteristic:characteristic];
        }
    
        //if ([[characteristic UUID] isEqual:currentTemperatureUUID]) { // Current Temp
        //    NSLog(@"Discovered Temperature Characteristic");
		//	tempCharacteristic = [characteristic retain];
		//	[peripheral readValueForCharacteristic:tempCharacteristic];
		//	[peripheral setNotifyValue:YES forCharacteristic:characteristic];
		//}
	}
}



#pragma mark -
#pragma mark Characteristics interaction

/** If we're connected, we don't want to be getting temperature change notifications while we're in the background.
 We will want alarm notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kTemperatureServiceUUIDString]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"2A1E"]] ) {
                    
                    // And STOP getting notifications from it
                    [servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
}

/** Coming back from the background, we want to register for notifications again for the temperature changes */
- (void)enteredForeground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kTemperatureServiceUUIDString]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"2A1E"]] ) {
                    
                    // And START getting notifications from it
                    [servicePeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (CGFloat) temperature
{
    CGFloat result  = NAN;
    int16_t	value	= 0;

	if (tempCharacteristic) {
        [[tempCharacteristic value] getBytes:&value length:sizeof (value)];
        result = (CGFloat)value / 10.0f;
    }
    return result;
}

//>>>
// update value
// will triger a notification(with data: peripheral id)
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Firstly check if ERROR!
    if ([error code] != 0) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    NSLog(@"%@ - %@", [characteristic UUID], characteristic.value);
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}

    /* Temperature change */
    if ([[characteristic UUID] isEqual:currentTemperatureUUID]) {
        [peripheralDelegate alarmServiceDidChangeTemperature:self];
        return;
    }
}

@end
