//
//  ViewController.m
//  BLEThermometer
//
//  Created by KS on 5/12/15.
//  Copyright (c) 2015年 KS. All rights reserved.
//

#import "ViewController.h"

//BLE modules
#import "LeDiscovery.h"
#import "LeTemperatureAlarmService.h"

#import "KSDetailController.h"
#import "KSSettingsController.h"

static NSString *TableViewCellID = @"MyCells";

@interface ViewController () <LeDiscoveryDelegate, LeTemperatureAlarmProtocol, UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) LeTemperatureAlarmService *currentlyDisplayingService;
@property (retain, nonatomic) NSMutableArray            *connectedServices;
@property (retain, nonatomic) IBOutlet UIButton *BtnPurchase;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

@synthesize currentlyDisplayingService;
@synthesize connectedServices;

#pragma mark -
#pragma mark View Lifecycle
/***************************************************************************/
/*                       View Lifecycle                                    */
/***************************************************************************/

- (void)viewDidAppear:(BOOL)animated {
    [[LeDiscovery sharedInstance] startScanningForUUIDString:kTemperatureServiceUUIDString];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    connectedServices = [NSMutableArray new];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:kAlarmServiceEnteredBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:kAlarmServiceEnteredForegroundNotification object:nil];
    
    UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
    UIBarButtonItem *scan = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showDetails)];
    
    [self.navigationItem setLeftBarButtonItem:more];
    [self.navigationItem setRightBarButtonItem:scan];
    [self.navigationItem setTitle:@"体温计APP"];
    
    //[self.BtnPurchase.layer setMasksToBounds:YES];
    //[self.BtnPurchase.layer setCornerRadius:2.0];
    //[self.BtnPurchase.layer setBorderWidth:1.0];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TableViewCellID];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];

    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ( sysVer >= 7.0 ){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[LeDiscovery sharedInstance] setPeripheralDelegate:self];
//    [[LeDiscovery sharedInstance] startScanningForUUIDString:kTemperatureServiceUUIDString];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_BtnPurchase release];
    [_tableView release];
    [[LeDiscovery sharedInstance] stopScanning];
    [super dealloc];
}

- (void)showDetails{
    [[LeDiscovery sharedInstance] startScanningForUUIDString:kTemperatureServiceUUIDString];
    
    //push KSDetailController
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    KSDetailController *detail = (KSDetailController*)[sb instantiateViewControllerWithIdentifier:@"detail"];
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)showSettings{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    KSSettingsController *popup = (KSSettingsController*)[sb instantiateViewControllerWithIdentifier:@"settings"];
    
    [self.navigationController pushViewController:popup animated:NO];
}

- (void)scanPeripherals {
    [[LeDiscovery sharedInstance] stopScanning];
    [[LeDiscovery sharedInstance] startScanningForUUIDString:kTemperatureServiceUUIDString];
    
}


#pragma mark -
#pragma mark TableView Delegate
/****************************************************************************/
- (CGFloat)	tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self showDetails];
    [tableView reloadData];
    
    CBPeripheral	*peripheral;
    NSArray			*devices;
    NSInteger		row	= [indexPath row];
    
    devices = [[LeDiscovery sharedInstance] foundPeripherals];
    peripheral = (CBPeripheral*)[devices objectAtIndex:row];
    
    if (![peripheral isConnected]) {
        [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
        
    }    
}


#pragma mark -
#pragma mark TableView Datasource
/****************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger	res = 0;
    

        //res = [[[LeDiscovery sharedInstance] connectedServices] count];

        res = [[[LeDiscovery sharedInstance] foundPeripherals] count];
    
    return res;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    CBPeripheral	*peripheral;
    NSArray			*devices;
    NSInteger		row	= [indexPath row];
    static NSString *cellID = @"DeviceList";
    
    //cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
 
    //cell.imageView.image = [UIImage imageNamed:@"ble"];
    //cell.imageView.frame = CGRectMake(0.0f, 0.0f, 10.0f, 10.0f);
    
    //cell.textLabel.text = [NSString stringWithFormat: @"Device %ld being connected.", (long)indexPath.row];
    //cell.detailTextLabel.text = @"temprature: 37℃ | battery: 30%";
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //<<<<<<<<<
    
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    
    //if ([indexPath section] == 0) {
    //    devices = [[LeDiscovery sharedInstance] connectedServices];
    //    peripheral = [(LeTemperatureAlarmService*)[devices objectAtIndex:row] peripheral];
        
    //} else {
        devices = [[LeDiscovery sharedInstance] foundPeripherals];
        peripheral = (CBPeripheral*)[devices objectAtIndex:row];
    //}
    
    if ([[peripheral name] length])
        [[cell textLabel] setText:[peripheral name]];
    else
        [[cell textLabel] setText:@"Unknown Peripheral"];
    
    [[cell detailTextLabel] setText: [peripheral isConnected] ? @"Connected" : @"Not connected"];
    
    return cell;
    
}

#pragma mark -
#pragma mark LeDiscoveryDelegate
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void) discoveryDidRefresh
{
    [self.tableView reloadData];
}

- (void) discoveryStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark -
#pragma mark LeTemperatureAlarm Interactions
/****************************************************************************/
/*                  LeTemperatureAlarm Interactions                         */
/****************************************************************************/
- (LeTemperatureAlarmService*) serviceForPeripheral:(CBPeripheral *)peripheral
{
    for (LeTemperatureAlarmService *service in connectedServices) {
        if ( [[service peripheral] isEqual:peripheral] ) {
            return service;
        }
    }
    
    return nil;
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered background notification called.");
    for (LeTemperatureAlarmService *service in self.connectedServices) {
        [service enteredBackground];
    }
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered foreground notification called.");
    for (LeTemperatureAlarmService *service in self.connectedServices) {
        [service enteredForeground];
    }
}

#pragma mark -
#pragma mark LeTemperatureAlarmProtocol Delegate Methods
/****************************************************************************/
/*				LeTemperatureAlarmProtocol Delegate Methods					*/
/****************************************************************************/

/**peripheral:didUpdateValueForCharacteristic:error*/


/** Broke the high or low temperature bound */
- (void) alarmService:(LeTemperatureAlarmService*)service didSoundAlarmOfType:(AlarmType)alarm
{
    if (![service isEqual:currentlyDisplayingService])
        return;
    
    NSString *title;
    NSString *message;
    
    switch (alarm) {
        case kAlarmLow:
            NSLog(@"Alarm low");
            title     = @"Alarm Notification";
            message   = @"Low Alarm Fired";
            break;
            
        case kAlarmHigh:
            NSLog(@"Alarm high");
            title     = @"Alarm Notification";
            message   = @"High Alarm Fired";
            break;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


/** Back into normal values */
- (void) alarmServiceDidStopAlarm:(LeTemperatureAlarmService*)service
{
    NSLog(@"Alarm stopped");
}


/** Current temp changed */
- (void) alarmServiceDidChangeTemperature:(LeTemperatureAlarmService*)service
{
    if (service != currentlyDisplayingService)
        return;
    
    NSInteger currentTemperature = (int)[service temperature];
}


/** Max or Min change request complete */
- (void) alarmServiceDidChangeTemperatureBounds:(LeTemperatureAlarmService*)service
{
    if (service != currentlyDisplayingService)
        return;
    
    //[maxAlarmLabel setText:[NSString stringWithFormat:@"MAX %dº", (int)[currentlyDisplayingService maximumTemperature]]];
    //[minAlarmLabel setText:[NSString stringWithFormat:@"MIN %dº", (int)[currentlyDisplayingService minimumTemperature]]];

}


/** Peripheral connected or disconnected */
- (void) alarmServiceDidChangeStatus:(LeTemperatureAlarmService*)service
{
    if ( [[service peripheral] isConnected] ) {
        NSLog(@"Service (%@) connected", service.peripheral.name);
        if (![connectedServices containsObject:service]) {
            [connectedServices addObject:service];
        }
    }
    
    else {
        NSLog(@"Service (%@) disconnected", service.peripheral.name);
        if ([connectedServices containsObject:service]) {
            [connectedServices removeObject:service];
        }
    }
}


/** Central Manager reset */
- (void) alarmServiceDidReset
{
    [connectedServices removeAllObjects];
}

#pragma mark -
#pragma mark Helper
/****************************************************************************/
/*                              Helper Methods                              */
/****************************************************************************/
/** Helpers */
- (void)alert:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TITLE" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}
@end
