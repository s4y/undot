#import <AppKit/AppKit.h>

int main() {
  pid_t controlCenterPID = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.controlcenter"].firstObject.processIdentifier;
  AXUIElementRef controlCenter = AXUIElementCreateApplication(controlCenterPID);

  CFTypeRef cfWindows;
  AXUIElementCopyAttributeValue(controlCenter, kAXWindowsAttribute, &cfWindows);
  NSArray *windows = CFBridgingRelease(cfWindows);
  CGPoint newPosition = CGPointMake(-999999, -999999);
  AXValueRef positionValue = AXValueCreate(kAXValueTypeCGPoint, &newPosition);
  for (id window in windows)
    AXUIElementSetAttributeValue((AXUIElementRef)window, kAXPositionAttribute, positionValue);
}
