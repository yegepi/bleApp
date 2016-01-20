/*

 File: LeDiscovery.m
 
 */



#import "LeDiscovery.h"


@interface LeDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate> {
	CBCentralManager    *centralManager;
    CBPeripheralManager *peripheralManager;
	BOOL				pendingInit;
}
@end


@implementation LeDiscovery

@synthesize foundPeripherals;
@synthesize connectedServices;
@synthesize discoveryDelegate;
@synthesize peripheralDelegate;



#pragma mark -
#pragma mark Init
/****************************************************************************/
/*									Init									*/
/****************************************************************************/
+ (id) sharedInstance
{
	static LeDiscovery	*this	= nil;

	if (!this)
		this = [[LeDiscovery alloc] init];

	return this;
}


- (id) init
{
    self = [super init];
    if (self) {
		pendingInit = YES;
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        //peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];

		foundPeripherals = [[NSMutableArray alloc] init];
		connectedServices = [[NSMutableArray alloc] init];
	}
    return self;
}


- (void) dealloc
{
    // We are a singleton and as such, dealloc shouldn't be called.
    assert(NO);
    [super dealloc];
}



#pragma mark -
#pragma mark Restoring
/****************************************************************************/
/*								Settings									*/
/****************************************************************************/
/* Reload from file. */
- (void) loadSavedDevices
{
	NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"No stored array to load");
        return;
    }
     
    for (id deviceUUIDString in storedDevices) {
        
        if (![deviceUUIDString isKindOfClass:[NSString class]])
            continue;
        
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)deviceUUIDString);
        if (!uuid)
            continue;
        
        [centralManager retrievePeripherals:[NSArray arrayWithObject:(__bridge id)uuid]];
        CFRelease(uuid);
    }

}


- (void) addSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"Can't find/create an array to store the uuid");
        return;
    }

    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    uuidString = CFUUIDCreateString(NULL, uuid);
    if (uuidString) {
        [newDevices addObject:(__bridge NSString*)uuidString];
        CFRelease(uuidString);
    }
    /* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) removeSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if ([storedDevices isKindOfClass:[NSArray class]]) {
		newDevices = [NSMutableArray arrayWithArray:storedDevices];

		uuidString = CFUUIDCreateString(NULL, uuid);
		if (uuidString) {
			[newDevices removeObject:(__bridge NSString*)uuidString];
            CFRelease(uuidString);
        }
		/* Store */
		[[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
	CBPeripheral	*peripheral;
	
	/* Add to list. */
	for (peripheral in peripherals) {
		[central connectPeripheral:peripheral options:nil];
	}
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
	[central connectPeripheral:peripheral options:nil];
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
	/* Nuke from plist. */
	[self removeSavedDevice:UUID];
}



#pragma mark -
#pragma mark Discovery
/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (void) startScanningForUUIDString:(NSString *)uuidString
{
	NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:kTemperatureServiceUUIDString], nil];
	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];

	//[centralManager scanForPeripheralsWithServices:uuidArray options:options];
    
    // if state is NULL, then wait for some seconds till it's 0x5
    
    //double delay = 2.0;
    //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay);
    //dispatch_after(popTime, dispatch_get_main_queue(),  ^(void){
    //    [centralManager scanForPeripheralsWithServices:nil options:nil];
    //});
    
    [centralManager scanForPeripheralsWithServices:uuidArray options:nil];
}


- (void) stopScanning
{
	[centralManager stopScan];
    
    CBCentralManagerState *s = (NSInteger)centralManager.state;
    NSLog(@"state");
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *CBName=[advertisementData valueForKeyPath:CBAdvertisementDataLocalNameKey];
    
	if (![foundPeripherals containsObject:peripheral]) {
		[foundPeripherals addObject:peripheral];
		[discoveryDelegate discoveryDidRefresh];
	}
}



#pragma mark -
#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
	if (![peripheral isConnected]) {
		[centralManager connectPeripheral:peripheral options:nil];
	}
}


- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
	[centralManager cancelPeripheralConnection:peripheral];
}


- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	LeTemperatureAlarmService	*service	= nil;
	
	/* Create a service instance. */
	service = [[[LeTemperatureAlarmService alloc] initWithPeripheral:peripheral controller:peripheralDelegate] autorelease];
	[service start];

	if (![connectedServices containsObject:service])
		[connectedServices addObject:service];

	if ([foundPeripherals containsObject:peripheral])
		[foundPeripherals removeObject:peripheral];

    [peripheralDelegate alarmServiceDidChangeStatus:service];
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"disconnect peripheral.");
    if (error) {
        NSLog(@"ERROR: %@", error.description);
    }
    
	LeTemperatureAlarmService	*service	= nil;

	for (service in connectedServices) {
		if ([service peripheral] == peripheral) {
			[connectedServices removeObject:service];
            [peripheralDelegate alarmServiceDidChangeStatus:service];
			break;
		}
	}

	[discoveryDelegate discoveryDidRefresh];
}


- (void) clearDevices
{
    LeTemperatureAlarmService	*service;
    [foundPeripherals removeAllObjects];
    
    for (service in connectedServices) {
        [service reset];
    }
    [connectedServices removeAllObjects];
}


- (void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    //TODO - what to do next after state's been updated?
    CBPeripheralManagerState state = [peripheral state];
    static NSString* strUUID = @"0A5F253F-D044-4E44-8919-8048B6E574AF";
    CBUUID *testServiceUUID;
    CBMutableService *testService;
    CBMutableCharacteristic *testChar;
    
    if ( state == CBPeripheralManagerStatePoweredOn) {
        testServiceUUID = [CBUUID UUIDWithString: strUUID];
        testChar =
            [[CBMutableCharacteristic alloc] initWithType:testServiceUUID
                    properties:CBCharacteristicPropertyRead
                    value:nil
                    permissions:CBAttributePermissionsReadable];
        testService = [[CBMutableService alloc] initWithType:testServiceUUID primary:YES];
        testService.characteristics = @[testChar];
        [peripheralManager addService:testService];
        [peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[testService.UUID], CBAdvertisementDataLocalNameKey: @"test_KS_Service"}];
    }
    
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"addServiceError: %@", error.localizedDescription);
    }
    
}

- (void) peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"startAdvError: %@", error.localizedDescription);
    }
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
	switch ([centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{
            [self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            
			/* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            if (previousState != -1) {
                [discoveryDelegate discoveryStatePoweredOff];
            }
			break;
		}
            
		case CBCentralManagerStateUnauthorized:
		{
			/* Tell user the app is not allowed. */
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
			/* Bad news, let's wait for another event. */
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
            [self startScanningForUUIDString:kTemperatureServiceUUIDString];
			pendingInit = NO;
			[self loadSavedDevices];
			[centralManager retrieveConnectedPeripherals];
			[discoveryDelegate discoveryDidRefresh];
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
			[self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            [peripheralDelegate alarmServiceDidReset];
            
			pendingInit = YES;
			break;
		}
	}
    
    previousState = [centralManager state];
}
@end
