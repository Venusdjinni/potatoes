#import "PotatoesPlugin.h"
#if __has_include(<potatoes/potatoes-Swift.h>)
#import <potatoes/potatoes-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "potatoes-Swift.h"
#endif

@implementation PotatoesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPotatoesPlugin registerWithRegistrar:registrar];
}
@end
