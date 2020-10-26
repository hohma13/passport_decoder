#import "PassportDecoderPlugin.h"
#if __has_include(<passport_decoder/passport_decoder-Swift.h>)
#import <passport_decoder/passport_decoder-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "passport_decoder-Swift.h"
#endif

@implementation PassportDecoderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPassportDecoderPlugin registerWithRegistrar:registrar];
}
@end
