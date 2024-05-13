//
//  BxlMPosControllerScannerPlugin.m
//  bxlflutterbgatelib
//
//  Created by OhDonggeon on 2023/11/02.
//

#import "BxlMPosControllerScannerPlugin.h"

@import frameworkMPosSDK;

static NSString* const PLATFORM_CHANNEL = @"com.bixolon.mposcontroller/scanner";
static NSString* const DATA_EVENT_CHANNEL = @"com.bixolon.mposcontroller/scanner/data";

@interface ScannerDataEvent : NSObject<FlutterStreamHandler>

@property(weak) BxlMPosControllerScannerPlugin* plugin;
@property FlutterEventSink eventSink;

@end

@implementation ScannerDataEvent

- (id)initWithPlugin:(BxlMPosControllerScannerPlugin*)plugin{
    if((self=[super init])){
        self.plugin = plugin;
        NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(deviceNotificationHandler:) name: @"DataEvent" object:nil];
    }
    return self;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events{
    self.eventSink = events;
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments{
    self.eventSink = nil;
    return nil;
}

- (void) deviceNotificationHandler:(NSNotification*) notification {
    if(self.plugin == NULL)
        return;
    
    NSNumber* deviceId = (NSNumber*)[notification object];
    
    if([deviceId integerValue] != [self.plugin getDeviceId])
        return;
    
    if ([[notification name] isEqualToString: @"DataEvent"]) {
        NSMutableArray *allKeys = [[[notification userInfo] allKeys] mutableCopy];
        
        for (NSString *key in allKeys) {
            NSData* data = [[notification userInfo] objectForKey: key];
            
            NSLog(@"%@, device id = %ld, data = %@", [notification name], (long)[deviceId integerValue], data);
            
            dispatch_async(dispatch_get_main_queue(),^{
                if (self.eventSink != nil)
                    self.eventSink([FlutterStandardTypedData typedDataWithBytes:data]);
            });
        }
    }
}
@end


@interface BxlMPosControllerScannerPlugin()
@property MPosControllerScanner* scanner;
@end

@implementation BxlMPosControllerScannerPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName: PLATFORM_CHANNEL
                                     binaryMessenger:[registrar messenger]];
    BxlMPosControllerScannerPlugin* instance = [[BxlMPosControllerScannerPlugin alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channel];
    
    // Data received channel
    FlutterEventChannel* eventChannel = [FlutterEventChannel
                                         eventChannelWithName:DATA_EVENT_CHANNEL
                                         binaryMessenger: [registrar messenger]];
    
    [eventChannel setStreamHandler:[[ScannerDataEvent alloc] initWithPlugin:instance]];
}

- (id)init {
    if ((self = [super init])) {
        self.scanner = [MPosControllerScanner new];
    }
    
    [MPosControllerScanner setEnableLog:YES saveFile:NO saveToHex:NO];
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // Device APIs
    if ([@"openService" isEqualToString:call.method])
        return [self openService:call result: result];
    
    else if ([@"closeService" isEqualToString:call.method])
        return [self closeService:call result: result];
    
    else if ([@"selectInterface" isEqualToString:call.method])
        return [self selectInterface:call result: result];
    
    else if ([@"selectCommandMode" isEqualToString:call.method])
        return [self selectCommandMode:call result: result];
    
    else if ([@"setTransaction" isEqualToString:call.method])
        return [self setTransaction:call result: result];
    
    else if ([@"directIO" isEqualToString:call.method])
        return [self directIO:call result: result];
    
    else if ([@"isOpen" isEqualToString:call.method])
        return [self isOpen:call result: result];
    
    else if ([@"getDeviceId" isEqualToString:call.method])
        return [self getDeviceId:call result: result];
    
    else if ([@"setReadMode" isEqualToString:call.method])
        return [self setReadMode:call result: result];
    
    else if ([@"setKeepNetworkConnection" isEqualToString:call.method])
        return [self setKeepNetworkConnection:call result: result];
    
    else if ([@"isUsbPeripheralPrinter" isEqualToString:call.method])
        return [self isUsbPeripheralPrinter:call result:result];
    
    else
        result(FlutterMethodNotImplemented);
}

// MARK: - MPosControllerDevices overrided APIs

- (void)openService:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = [call arguments];
    NSNumber* deviceId = arguments[@"device_id"] ? : @-1;
    NSNumber* timeout = arguments[@"time_out"] ? : @3;
    MPOS_RESULT nativeResult = [self.scanner openService:[deviceId integerValue] timeout:[timeout integerValue]];
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)closeService:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = [call arguments];
    NSNumber* timeout = arguments[@"time_out"] ? : @3;
    MPOS_RESULT nativeResult = [self.scanner closeService:[timeout integerValue]];
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)selectInterface:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = [call arguments];
    NSNumber* interfaceType = arguments[@"interface_type"] ? : @-1;
    NSString* address = arguments[@"address"] ? : @3;
    MPOS_RESULT nativeResult = [self.scanner selectInterface:[interfaceType integerValue] address:address];
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)selectCommandMode:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = [call arguments];
    NSNumber* commandMode = arguments[@"command_mode"] ? : @-1;
    MPOS_RESULT nativeResult = [self.scanner selectCommandMode:[commandMode integerValue]];
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)setTransaction:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = [call arguments];
    NSNumber* transaction = arguments[@"transaction"] ? : @-1;
    MPOS_RESULT nativeResult = [self.scanner setTransaction:[transaction integerValue]];
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)setReadMode:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = [call arguments];
    NSNumber* mode = arguments[@"read_mode"] ? : @-1;
    MPOS_RESULT nativeResult = [self.scanner setReadMode:[mode integerValue]];
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)directIO:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = [call arguments];
    NSArray<NSNumber*>* data = arguments[@"data_array"] ? : @[];
    
    NSMutableData* dataToSend = [NSMutableData data];
    for(NSNumber* number in data){
        char byte = [number charValue];
        [dataToSend appendBytes: &byte length:1];
    }
    MPOS_RESULT nativeResult = [self.scanner directIO:dataToSend];
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)isOpen:(FlutterMethodCall*)call result:(FlutterResult)result {
    MPOS_RESULT nativeResult = [self.scanner isOpen] ? 1 : 0;
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)getDeviceId:(FlutterMethodCall*)call result:(FlutterResult)result {
    MPOS_RESULT nativeResult = [self.scanner getDeviceId];
    result([NSNumber numberWithInteger:nativeResult]);
}

- (void)setKeepNetworkConnection:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (![self.scanner isOpen]) {
        NSDictionary* arguments = [call arguments];
        NSNumber* keep_connection = arguments[@"keep_connection"] ? : @0;
        [self.scanner setKeepNetworkConnection:[keep_connection integerValue]];
        result([NSNumber numberWithInteger: 0]);
    } else {
        result([NSNumber numberWithInteger: 1000]);
    }
}

- (void)isUsbPeripheralPrinter:(FlutterMethodCall*)call result:(FlutterResult)result {
    result([self.scanner isUSBPeripheralPrinter] ? @(YES) : @(NO));
}

- (NSInteger)getDeviceId {
    return [self.scanner getDeviceId];
}

@end