#import "NativeTabBarPlugin.h"
#if __has_include(<native_tab_bar/native_tab_bar-Swift.h>)
#import <native_tab_bar/native_tab_bar-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_tab_bar-Swift.h"
#endif

@implementation NativeTabBarPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
   [SwiftNativeTabBarPlugin registerWithRegistrar:registrar];
}

@end
