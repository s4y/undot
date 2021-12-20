#import <AppKit/AppKit.h>

int main() {
  NSLog(@"Trusted? %d", AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef) @{(__bridge id) kAXTrustedCheckOptionPrompt : @YES}));

  pid_t controlCenterPID = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.controlcenter"].firstObject.processIdentifier;
  NSLog(@"found control center: %d", controlCenterPID);
  AXUIElementRef controlCenter = AXUIElementCreateApplication(controlCenterPID);

  CFTypeRef cfWindows;
  AXError error = AXUIElementCopyAttributeValue(controlCenter, kAXWindowsAttribute, &cfWindows);
  NSArray *windows = CFBridgingRelease(cfWindows);
  NSLog(@"%d %@", error, windows);
  CGPoint newPosition = CGPointMake(-999999, -999999);
  AXValueRef positionValue = AXValueCreate(kAXValueTypeCGPoint, &newPosition);
  for (id window in windows)
    NSLog(@"%d", AXUIElementSetAttributeValue((AXUIElementRef)window, kAXPositionAttribute, positionValue));
}
