#import <AppKit/AppKit.h>

static AXObserverRef observer = NULL;

CF_IMPLICIT_BRIDGING_ENABLED

void yeetWindow(AXUIElementRef window) {
  CFTypeRef sizeValue;
  if (AXUIElementCopyAttributeValue(window, kAXSizeAttribute, &sizeValue) != kAXErrorSuccess)
    return;
  CFAutorelease(sizeValue);

  CGSize size;
  if (!AXValueGetValue(sizeValue, kAXValueTypeCGSize, &size))
    return;

  if (!NSEqualSizes(size, CGSizeMake(8, 8)))
    return;

  CFTypeRef currentPositionValue;
  if (AXUIElementCopyAttributeValue(window, kAXPositionAttribute, &currentPositionValue) != kAXErrorSuccess)
    return;
  CFAutorelease(currentPositionValue);

  CGPoint currentPosition;
  if (!AXValueGetValue(currentPositionValue, kAXValueTypeCGPoint, &currentPosition))
    return;

  const CGPoint newPosition = CGPointMake(-999999, -999999);
  if (NSEqualPoints(currentPosition, newPosition))
    return;

  AXValueRef positionValue = AXValueCreate(kAXValueTypeCGPoint, &newPosition);
  AXUIElementSetAttributeValue(window, kAXPositionAttribute, positionValue);
  CFRelease(positionValue);
}

void handleNewWindow(AXUIElementRef window) {
  AXObserverAddNotification(observer, window, kAXWindowMovedNotification, NULL);
  AXObserverAddNotification(observer, window, kAXUIElementDestroyedNotification, NULL);
  yeetWindow(window);
}

void handleNotification(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, __unused void *refcon) {
  if (CFEqual(notification, kAXWindowCreatedNotification)) {
    handleNewWindow(element);
  } else if (CFEqual(notification, kAXUIElementDestroyedNotification)) {
    AXObserverRemoveNotification(observer, element, kAXWindowMovedNotification);
    AXObserverRemoveNotification(observer, element, kAXUIElementDestroyedNotification);
  }

  yeetWindow(element);
}

CF_IMPLICIT_BRIDGING_DISABLED

@interface LaunchObserver: NSObject
@property(strong) NSString* bundleIdentifier;
@property(strong) void (^block)(NSRunningApplication *);
@end

@implementation LaunchObserver
+ (instancetype)launchObserverFor:(NSString *)bundleIdentifier block:(void(^)(NSRunningApplication *app))block
{
  LaunchObserver *launchObserver = [LaunchObserver new];
  launchObserver.bundleIdentifier = bundleIdentifier;
  launchObserver.block = block;

  [NSWorkspace.sharedWorkspace addObserver:launchObserver
                                forKeyPath:@"runningApplications"
                                   options:NSKeyValueObservingOptionNew
                                   context:NULL];

  NSRunningApplication *currentlyRunningApplication = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier].firstObject;
  if (currentlyRunningApplication)
    block(currentlyRunningApplication);
  return launchObserver;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context
{
  NSArray *newRunningApplications = change[NSKeyValueChangeNewKey];
  for (NSRunningApplication *app in newRunningApplications) {
    if ([self.bundleIdentifier isEqualToString:app.bundleIdentifier])
      self.block(app);
  }
}
@end

int main() {
  for (;;) {
    __unused LaunchObserver *launchObserver = [LaunchObserver launchObserverFor:@"com.apple.controlcenter" block:^(NSRunningApplication *app){
      if (observer)
        CFRelease(observer);

      // This is the one little hack I'm leaving alone for right now: wait for Control Center to finish launching.
      // I'm sure there's a good notification to wait for instead; poke me if you know.
      sleep(1);

      AXObserverCreate(app.processIdentifier, handleNotification, &observer);
      AXUIElementRef controlCenter = AXUIElementCreateApplication(app.processIdentifier);
      AXObserverAddNotification(observer, controlCenter, kAXWindowCreatedNotification, NULL);
      CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);

      CFTypeRef cfWindows;
      AXUIElementCopyAttributeValue(controlCenter, kAXWindowsAttribute, &cfWindows);
      NSArray *windows = CFBridgingRelease(cfWindows);
      for (id window in windows)
        handleNewWindow((AXUIElementRef)window);
    }];

    CFRunLoopRun();
    break;
  }

}
