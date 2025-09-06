#import "PitchDetectorPlusPlugin.h"
#if __has_include(<pitch_detector_plus/pitch_detector_plus-Swift.h>)
#import <pitch_detector_plus/pitch_detector_plus-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pitch_detector_plus-Swift.h"
#endif

@implementation PitchDetectorPlusPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPitchDetectorPlusPlugin registerWithRegistrar:registrar];
}
@end
