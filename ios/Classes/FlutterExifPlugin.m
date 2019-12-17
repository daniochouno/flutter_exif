#import "FlutterExifPlugin.h"
#import <flutter_exif/flutter_exif-Swift.h>

@implementation FlutterExifPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterExifPlugin registerWithRegistrar:registrar];
}
@end
