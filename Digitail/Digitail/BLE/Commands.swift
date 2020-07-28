//
//  Commands.swift

//

import UIKit
import CoreFoundation

let maxCount = 20

let endOFData = Data(bytes: [0x7d, 0x0a])

struct Constants {
    
    // BLE Lib Key
    static let kPeripheralUUIDKey = "peripheralUUID"
    static let kPropertyOperationWrite = "write"
    static let kPropertyOperationRead = "read"
    static let kPropertyOperationReadWait = "readWait"
    static let kDeviceName = "deviceName"
    
    static let kCharacteristic_WriteData = "writeData"
    static let kCharacteristic_ReadData = "readData"
    static let kCharacteristic_BatteryLevel = "batteryLevel"
    static let kCharacteristic_Response = "responseData"
    static let kServiceUUID = "FFE0"
    
    // Timeout Command
    static let kCommandPropertySetTimeout = 10.0
    static let kDisconnectTimeout = 10.0
    static let kLowPriorityTimeout = 2.0
    static let kCBPathDelimiter = "."
    
    static let kName = "name"
    static let kValue = "value"
    static let kData = "data"
    // Command Meta
    static let kCommand_SendData = "SendData"
    static let kIsVideoPlayed = "IsVideoPlayed"
}
struct CharName {
    static let kChar_batteryLevel : String = "batteryLevel"
}

struct BluetoothMessage {
    static let MsgWalletNotConnected = "Wallet is not connected"
}

public struct MyError: Error {
    let msg: String
    
}

class BasiPacketFormatter {
    var code : String
    var payload : String
    init(commandCode code:String,payloadData payload:String) {
        self.code = code
        self.payload = payload
    }
    
    public func packetBytes() -> Data {
        print("PacketBytes \(self.packetString().data(using: String.Encoding.utf8)!)")
        return self.packetString().data(using: String.Encoding.utf8)!
    }
    
    public func packetString () -> String{
        #if DEBUG
        print("PacketString \(String(format: "%@=%@", self.code,self.payload))")
        #endif
        return String(format: "%@=%@", self.code,self.payload)
    }
}

class AppVersionFormatter: BasiPacketFormatter {
    
    init(appVersion version:String) {
        super.init(commandCode: "00", payloadData:version)
    }
}

func buildPercentage(dataValue:Data) -> Data {
    if dataValue.count % 16 == 0 {
        print(#function,"16 = \(dataValue)")
        return dataValue //addPercentageToWrapTheData(dataValue)
    }else{
        var buildData = [UInt8](repeating: 25, count: 16)
        for i in 0..<buildData.count {
            if i < dataValue.count {
                buildData[i] = dataValue[i]
            }else{
                buildData[i] = 0x25
            }
        }
        let cmdData = Data.init(bytes: buildData)
        print(#function,"\(buildData)")
        return cmdData //addPercentageToWrapTheData(cmdData)
    }
}

func addPercentageToWrapTheData(_ dataValue:Data) -> Data {
    let payload = NSMutableData.init(data: Data.init(bytes: [0x25]))
    payload.append(dataValue)
    payload.append(Data.init(bytes: [0x25]))
    #if DEBUG
    print("Final Payload : \(payload)")
    #endif
    return payload as Data
}


class Commands: NSObject {
    
}
