import Cocoa
import ApplicationServices


private struct Constants {
    static let applicationDocumentsDirectoryName = "dk.logging.ContextLogger"
}

var eventMonitorKeyboard: GlobalEventMonitor?
var eventMonitorMouse: GlobalEventMonitor?

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let fileManager = FileManager.default    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        var applicationSupportDirectory = urls[urls.count - 1] as URL
        
        let _ = acquirePrivileges()
        applicationSupportDirectory = applicationSupportDirectory.appendingPathComponent(Constants.applicationDocumentsDirectoryName)
        do {
            try FileManager.default.createDirectory(atPath:applicationSupportDirectory.relativePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = nil
        }
        constructMenuInitial()
        
        let folder = applicationSupportDirectory.path + "/"
        eventMonitorKeyboard = GlobalEventMonitor(mask: NSEvent.EventTypeMask.keyDown) { (event) in
            var modifierString = ""
            switch event?.modifierFlags.rawValue {
            case 256:
                modifierString = ""
            case 131330:
                modifierString = "(shift)+"
            case 262401:
                modifierString = "(control)+"
            case 1048840:
                modifierString = "(cmd)+"
            default:
                print("unhandled modifier mask \(event?.modifierFlags.rawValue)")
            }
            //                -- modifierMask = 131072    (shift)
            //                -- modifierMask = 262144    (control)
            //                -- modifierMask = 524288    (option)
            //                -- modifierMask = 1048576   (command)
            //                -- modifierMask = 786432    (control + option)
            //                -- modifierMask = 393216    (control + shift)
            //                -- modifierMask = 1310720   (control + command)
            //                -- modifierMask = 1572864   (option + command)
            //                -- modifierMask = 655360    (shift + option)
            //                -- modifierMask = 1179648   (command + shift)
            //                -- modifierMask = 917504    (control + shift + option)
            //                -- modifierMask = 1703936   (option + command + shift)
            //                -- modifierMask = 1835008   (control + option + command)
            let character = event?.charactersIgnoringModifiers
            var characterOutput = ""
            if let character = character {
                if character == "\r" {
                    characterOutput = "enter"
                }
                else if character == "\t" {
                    characterOutput = "tab"
                }
                else if character == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
                    characterOutput = "delete"
                }
                else {
                    characterOutput = character
                }
            }
            print("\(modifierString) \(characterOutput)")
            takeScreensShots(folderName: folder, eventString: modifierString + characterOutput)
        }
        
        eventMonitorMouse = GlobalEventMonitor(mask: NSEvent.EventTypeMask.leftMouseDown) { (event) in
            takeScreensShots(folderName: folder, eventString:"mouseDown(\(Int(event?.locationInWindow.x ?? 0)),\(Int(event?.locationInWindow.y ?? 0)))")
        }
    }

    func constructMenuInitial() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start Recording", action: #selector(AppDelegate.recordingStarted), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Logger", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    func constructMenuRecording() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Stop Recording", action: #selector(AppDelegate.recordingStopped), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Logger", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func recordingStarted() {
        print("Start recording")
        constructMenuRecording()
        eventMonitorKeyboard?.start()
        eventMonitorMouse?.start()
    }
    
    @objc func recordingStopped() {
        print("Stop Recording")
        constructMenuInitial()
        eventMonitorKeyboard?.stop()
        eventMonitorMouse?.stop()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

// MARK: Acquire Privleges
func acquirePrivileges() -> Bool {
    let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
    let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
    
    if accessibilityEnabled != true {
        print("You need to enable the ContextLogger in the System Preferences")
    }
    
    return accessibilityEnabled == true
}

func takeScreensShots(folderName: String, eventString: String) {
    var displayCount: UInt32 = 0;
    var result = CGGetActiveDisplayList(0, nil, &displayCount)
    if (result != CGError.success) {
        print("error: \(result)")
        return
    }
    let allocated = Int(displayCount)
    let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
    result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
    
    if (result != CGError.success) {
        print("error: \(result)")
        return
    }
    
    for i in 1...displayCount {
        if let appName = NSWorkspace.shared.frontmostApplication?.localizedName?.replacingOccurrences(of: " ", with: ""){
            let fileUrl = URL(fileURLWithPath: folderName + "\(formatCurrentDateTimeAsString())_\(i)_\(appName)_{\(eventString)}.jpg", isDirectory: true)
            
            let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[Int(i-1)])!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            
            do {
                try jpegData.write(to: fileUrl, options: .atomic)
            }
            catch {print("error: \(error)")}
        }
    }
}

func formatCurrentDateAsString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let d = Date()
    let s = dateFormatter.string(from: d)
    return s
}

func formatCurrentDateTimeAsString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss.SSS"
    let d = Date()
    let s = dateFormatter.string(from: d)
    return s
}
