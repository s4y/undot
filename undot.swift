import AppKit

let controlCenterPID = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.controlcenter").first!.processIdentifier
let controlCenter = AXUIElementCreateApplication(controlCenterPID)

var cfWindows: CFTypeRef?
AXUIElementCopyAttributeValue(controlCenter, kAXWindowsAttribute as CFString, &cfWindows)
let windows = cfWindows as! NSArray
var newPosition = CGPoint(x: -999999, y: 999999)
let positionValue = AXValueCreate(.init(rawValue: kAXValueCGPointType)!, &newPosition)!
for window in windows {
    AXUIElementSetAttributeValue(window as! AXUIElement, kAXWindowsAttribute as CFString, positionValue)
}
