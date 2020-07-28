
//  CBUtils.swift
//  iCoin-Wallet
//
//  Created by Iottive on 02/05/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import CoreFoundation
import CoreBluetooth


class CBUtils: NSObject {

}

var AppDelegate_ = (UIApplication.shared.delegate) as! AppDelegate

func getDefaultActor() -> BLEActor? {
    if (AppDelegate_.deviceActors.count) > 0 {
        return (AppDelegate_.deviceActors[0])
    }
    return nil
}

func reconnectWithActor(_ deviceActor: BLEActor) {
    let peripheral: CBPeripheral? = deviceActor.peripheralActor?.peripheral
    if peripheral == nil {
        let uuid = UUID(uuidString: deviceActor.state[Constants.kPeripheralUUIDKey] as! String)
        print(#function,"UUID \(String(describing: uuid?.uuidString))")
        AppDelegate_.centralManagerActor.centralManager?.retrievePeripherals(withIdentifiers: [uuid!]).forEach({ (p) in
            AppDelegate_.centralManagerActor.add(p)
        })
        return
    }
    AppDelegate_.centralManagerActor.centralManager?.connect(peripheral!, options: nil)
    AppDelegate_.centralManagerActor.centralManager?.retrieveConnectedPeripherals(withServices:[]).forEach({ (p) in
        if (p.identifier.uuidString == (deviceActor.state[Constants.kPeripheralUUIDKey]) as! String) {
            AppDelegate_.centralManagerActor.add(p)
        }
    })
}

func CBUUIDsFromNSStrings(strings: [String]) -> [CBUUID] {
    print(#function,"CBUUIDsFromNSStrings \(strings)")
    var finalUUID = [CBUUID]()
    for strUUID in strings {
        finalUUID.append(CBUUID(string: strUUID))
    }
    return finalUUID
}

func NSStringsFromCBUUIDs(cbUUIDs: [CBUUID]) -> [String] {
    var finalUUID = [String]()
    for strUUID in cbUUIDs {
        finalUUID.append(NSStringFromCBUUID(strUUID))
    }
    return finalUUID
}

func CharacteristicPathWithArray(_ arr: [String]) -> String {
    return (arr as NSArray).componentsJoined(by: Constants.kCBPathDelimiter)
}

func PropertyCharacteristicPath(property: String, servicesMeta: NSDictionary, actor: BLEActor) -> String? {
    var serviceUUIDStr: String? = nil
    var characteristicUUIDStr: String? = nil
    for serviceUUID in servicesMeta.allKeys {
        print(#function,"finding property \(serviceUUID)")
        serviceUUIDStr = serviceUUID as? String
        
        let charData = servicesMeta.value(forKey: serviceUUIDStr!) as! NSDictionary
        for charUUID in charData.allKeys {
            let dicData = charData .value(forKey: charUUID as! String) as! NSDictionary
            if (property == (dicData.value(forKey: "name") as! String)) {
                characteristicUUIDStr = charUUID as? String;
                break;
            }
        }
    
        if characteristicUUIDStr != nil {
            break
        }
    }
    if characteristicUUIDStr != nil {
        return ([serviceUUIDStr!, characteristicUUIDStr!] as NSArray).componentsJoined(by: Constants.kCBPathDelimiter)
    }
    return nil
}

extension Dictionary where Value: Equatable {
    func checkKey(value : Value) -> Bool {
        return self.contains { $0.1 == value }
    }
}

//extension NSMutableArray {
//    func shift() -> NSMutableDictionary! {
//        if count > 0 {
//            let obj = (self[0] as! NSMutableDictionary).retain
//            self.remove(at: 0)
//            return obj
//        }
//        return nil
//    }
//    
//    
//    func pop() -> Any? {
//        if count > 0 {
//            let obj: Any? = self.lastObject
//            self.removeLastObject()
//            return obj!
//        }
//        return nil
//    }
//    
//    func push(_ obj: Any) {
//        self.add(obj)
//    }
//}

extension Data {
    var hexString: String {
        var hexString = ""
        for byte in self {
            hexString += String(format: "%02X", byte)
        }
        return hexString
    }
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}

extension NSData {
    public var hexadecimalString: NSString {
        var bytes = [UInt8](repeating: 0, count: length)
        getBytes(&bytes, length: length)
        
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        return NSString(string: hexString)
    }
}

extension Data {
    init?(hexString: String) {
        let length = hexString.count / 2
        var data = Data(capacity: length)
        for i in 0 ..< length {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}

extension String {
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
    
    func capitalizingFirstLetter() -> String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

func NSStringFromCBUUID(_ uuid: CBUUID) -> String {
    return uuid.data.hexString;
}

func GetUUID() -> String {
    let theUUID: CFUUID = CFUUIDCreate(nil)
    let string: CFString = CFUUIDCreateString(nil, theUUID)
    return (string as? String)!
}

func DictFromFile(_ filename: String) -> NSMutableDictionary {
    let filepathData: String? = Bundle.main.path(forResource: filename, ofType: nil)
    return NSMutableDictionary.init(contentsOfFile: filepathData!)!;
}

func ArrayFromFile(_ filename: String) -> NSMutableArray {
    let filepathData: String? = Bundle.main.path(forResource: filename, ofType: nil)
    return NSMutableArray.init(contentsOfFile: filepathData!)!;
}

func ReadValue(_ storageKey: String) -> Any {
    return UserDefaults.standard.value(forKey: storageKey) as Any
}

func StoreValue(_ storageKey:String,_ value : Any) {
    UserDefaults.standard.setValue(value, forKey: storageKey)
    UserDefaults.standard.synchronize();
}

func LoadObjects(_ storageKey: String) -> [Any] {
    let archived: Data? = ReadValue(storageKey) as? Data
    print(#function,"archived: \(String(describing: archived))")
    if archived == nil {
        return []
    }
    let objects: [Any]? = NSKeyedUnarchiver.unarchiveObject(with: archived!) as? [Any]
    print(#function,"Key \(storageKey) Value: \(String(describing: objects))")
    return objects!
}

func StoreObjects(_ storageKey: String, _ objects: [Any]) {
    let archived:Data = NSKeyedArchiver.archivedData(withRootObject: objects)
    print(#function,"\(storageKey) : \(objects), archived: \(String(describing: archived))")
    StoreValue(storageKey, archived)
}


func PostNoteBLE(_ key: String, _ object: Any) {
    NSLog("posting notification \(key) with object \(object)")
    DispatchQueue.main.async(execute: {() -> Void in
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: key), object: object)
    })
}

func PostNoteWithInfo(_ key: String, _ object: Any, _ info: NSMutableDictionary) {
   NSLog("posting notification \(key) with object \(object), info: \(info)")
    
    DispatchQueue.main.async(execute: {() -> Void in
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: key),object: object, userInfo: (info as! [String : Any]))
    })
}

func RegisterForNotes(_ selector:Selector, _ noteKeys: [Any], _ observer: Any) {
    noteKeys .forEach { (strKey) in
        RegisterForNote(selector,strKey as! String, observer)
    }
}

func RegisterForNotesFromObject(_ selector:Selector, _ noteKeys: [Any], _ observer: Any, _ object: Any) {
    noteKeys .forEach { (key) in
        RegisterForNoteFromObject(selector,key as! String, observer, object)
    }
}

func RegisterForNoteFromObject(_ selector:Selector, _ key: String, _ observer: Any, _ object: Any) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(key), object: nil)
}

func RegisterForNoteWithObject(_ selector:Selector, _ key: String, _ observer: Any, _ object: Any) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(key), object: object)
}

func RegisterForNote(_ selector:Selector, _ key: String, _ observer: Any) {
    RegisterForNoteFromObject(selector,key, observer, NSNull())
}

 
func UnregisterFromNotes(_ observer: Any) {
    NotificationCenter.default.removeObserver(observer)
}

func UnregisterFromNotesFromObject(_ observer: Any, _ object: Any) {
    NotificationCenter.default.removeObserver(observer, name: nil, object: object)
}

func UnregisterFromNotesFromObjectWithName(_ observer: Any, _ object: Any,_ name: String) {
    NotificationCenter.default.removeObserver(observer, name: NSNotification.Name.init(rawValue: name), object: object)
}




