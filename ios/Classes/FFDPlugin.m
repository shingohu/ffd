#import "FFDPlugin.h"
#import <ffd/ffd-Swift.h>

@implementation FFDPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFfdPlugin registerWithRegistrar:registrar];
}
@end
