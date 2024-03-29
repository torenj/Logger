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
    var postProcessingProcess: Process?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = acquirePrivileges()
        setupListeners()
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = nil
        }
        constructMenuInitial()
    }
    
    func setupListeners() {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        var applicationSupportDirectory = urls[urls.count - 1] as URL
        applicationSupportDirectory = applicationSupportDirectory.appendingPathComponent(Constants.applicationDocumentsDirectoryName)
        do {
            try FileManager.default.createDirectory(atPath:applicationSupportDirectory.relativePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
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
                print("Unhandled modifier mask \(String(describing: event?.modifierFlags.rawValue))")
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
            var characterOutput = ""
            if let character = event?.charactersIgnoringModifiers {
                switch character {
                case String(Character(UnicodeScalar(NSCarriageReturnCharacter)!)):
                    characterOutput = "enter"
                case String(Character(UnicodeScalar(NSDeleteCharacter)!)):
                    characterOutput = "delete"
                case String(Character(UnicodeScalar(NSTabCharacter)!)):
                    characterOutput = "tab"
                default:
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
        constructRestOfMenu(menu: menu)
    }
    
    func constructMenuRecording() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Stop Recording", action: #selector(AppDelegate.recordingStopped), keyEquivalent: "s"))
        constructRestOfMenu(menu: menu)
    }
    
    func constructProcessing() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Processing...", action: nil, keyEquivalent: ""))
        constructRestOfMenu(menu: menu)
    }
    
    func constructRestOfMenu(menu: NSMenu) {
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Logger", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        menu.addItem(NSMenuItem.separator())
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"],  let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"]{
            menu.addItem(NSMenuItem(title: "Version \(appVersion) (\(buildVersion))", action: nil, keyEquivalent: ""))
        }
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
        constructProcessing()
        eventMonitorKeyboard?.stop()
        eventMonitorMouse?.stop()
        startPostProcessingTask()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func startPostProcessingTask() {
        guard let path = Bundle.main.path(forResource: "postProcessing",ofType:"sh") else {
          print("Unable to locate postProcessing.sh")
          return
        }
        
        copyFileToDocumentsFolder(nameForFile: "dot", extForFile: "py")
        copyFileToDocumentsFolder(nameForFile: "generateImageDiffs", extForFile: "py")
        
        let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var documentsPath = documentDirectoryUrl.absoluteString
        documentsPath.remove(at: documentDirectoryUrl.absoluteString.index(before: documentDirectoryUrl.absoluteString.endIndex))
        documentsPath = documentsPath.replacingOccurrences(of: "file://", with: "")
        
        postProcessingProcess = Process()
        postProcessingProcess?.launchPath = path
        postProcessingProcess?.arguments = [documentsPath]
        postProcessingProcess?.terminationHandler = {
          task in
          DispatchQueue.main.async(execute: {
            print("script terminated")
            self.constructMenuInitial()
          })
        }

        postProcessingProcess?.launch()
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

//MARK: Screenshot functionality
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

func copyFileToDocumentsFolder(nameForFile: String, extForFile: String) {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let destURL = documentsURL!.appendingPathComponent(nameForFile).appendingPathExtension(extForFile)
    guard let sourceURL = Bundle.main.url(forResource: nameForFile, withExtension: extForFile)
        else {
            print("Source File not found.")
            return
    }
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(at: sourceURL, to: destURL)
        } catch {
            print("Unable to copy file")
        }
}
