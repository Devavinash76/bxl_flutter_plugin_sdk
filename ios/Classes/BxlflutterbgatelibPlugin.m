@import frameworkMPosSDK;

#import "BxlflutterbgatelibPlugin.h"
#import "BxlMPosLibVersionPlugin.h"
#import "BxlMPosLookupPlugin.h"
#import "BxlMPosControllerDevicePlugin.h"
#import "BxlMPosControllerConfigPlugin.h"
#import "BxlMPosControllerPrinterPlugin.h"
#import "BxlMPosControllerLabelPrinterPlugin.h"
#import "BxlMPosControllerBcdPlugin.h"
#import "BxlMPosControllerDallasKeyPlugin.h"
#import "BxlMPosControllerHidPlugin.h"
#import "BxlMPosControllerNfcPlugin.h"
#import "BxlMPosControllerRfidPlugin.h"
#import "BxlMPosControllerScalePlugin.h"
#import "BxlMPosControllerScannerPlugin.h"
#import "BxlMPosControllerTtyUsbPlugin.h"


@implementation BxlflutterbgatelibPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [BxlMPosLibVersionPlugin registerWithRegistrar:registrar];
    [BxlMPosLookupPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerDevicePlugin registerWithRegistrar:registrar];
    [BxlMPosControllerConfigPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerPrinterPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerLabelPrinterPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerBcdPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerDallasKeyPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerHidPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerNfcPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerRfidPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerScalePlugin registerWithRegistrar:registrar];
    [BxlMPosControllerScannerPlugin registerWithRegistrar:registrar];
    [BxlMPosControllerTtyUsbPlugin registerWithRegistrar:registrar];
}

@end
