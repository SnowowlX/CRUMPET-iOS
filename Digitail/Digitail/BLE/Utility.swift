//
//  Utility.swift
//  Zacl
//
//  Created by Admin on 1/25/19.
//  Copyright © 2019 zacl. All rights reserved.
//

import UIKit
import SystemConfiguration
import CoreLocation

class Utility: UITableViewCell {
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
     }
    
    func installedFonts() {
        for family: String in UIFont.familyNames {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
    
    func storeUserProfileImg(image: UIImage, forKey key: String) {
        if let jpegRepresentation = image.jpegData(compressionQuality: 0.75) {
            UserDefaults.standard.set(jpegRepresentation, forKey: key)
        }
    }
    
    func retrieveUserProfileImage(forKey key: String) -> UIImage? {
        if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
            let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }

   
    func getDate(dateToBeConvert : Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let myString = formatter.string(from: dateToBeConvert)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "yyyy.MM.dd"
        let myStringafd = formatter.string(from: yourDate!)
        print(myStringafd)
        return myStringafd
    }
    
    func getCurrentDateAndTime() -> String? {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy.MM.dd hh:mm E"
        print(formatter3.string(from: Date()))
        return formatter3.string(from: Date())
    }
    
    func getCurrentTimeAndDay()  -> String? {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "hh:mm ,E"
        return formatter3.string(from: Date())
    }
    
    func openCustomUrl(strUrl: String) {
        if let url = URL(string: "https://\(strUrl)") {
            let application = UIApplication.shared
            guard application.canOpenURL(url) else {
                return
            }
            application.open(url, options: [:], completionHandler: nil)
        }
    }
   
    func getBatteryIconAccordingPercentage(batteryLevel : Int) -> UIImage {
        if batteryLevel >= 0 && batteryLevel <= 10 {
            return UIImage(named: "10")!
        } else if batteryLevel >= 11 && batteryLevel <= 20 {
            return UIImage(named: "20")!
        } else if batteryLevel >= 21 && batteryLevel <= 30 {
            return UIImage(named: "30")!
        } else if batteryLevel >= 31 && batteryLevel <= 40 {
            return UIImage(named: "40")!
        } else if batteryLevel >= 41 && batteryLevel <= 50 {
            return UIImage(named: "50")!
        } else if batteryLevel >= 51 && batteryLevel <= 60 {
            return UIImage(named: "60")!
        } else if batteryLevel >= 61 && batteryLevel <= 70 {
            return UIImage(named: "70")!
        } else if batteryLevel >= 71 && batteryLevel <= 80 {
            return UIImage(named: "80")!
        } else if batteryLevel >= 81 && batteryLevel <= 90 {
            return UIImage(named: "90")!
        } else if batteryLevel >= 91 && batteryLevel <= 100 {
            return UIImage(named: "100")!
        } else {
            return UIImage(named: "100")!
        }
    }
    
}


extension Date {
    static var currentTimeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
    
    static var currentTimeStampInMiliSeconds: Int64 {
        return Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    
    static func getTime(recent: Date, previous: Date) -> (Int?) {
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
        return second
    }
    
    func isGreater(than date: Date) -> Bool {
        return self > date
    }
    
    func isSmaller(than date: Date) -> Bool {
        return self < date
    }
    
    
    
    func offset(from date: Date)-> DateComponents {
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let differenceOfDate = Calendar.current.dateComponents(components, from: date, to: self)
        return differenceOfDate
    }
    
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    func GetDateInFormate(_ formate:String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        let myStringafd = formatter.string(from: self)
        print(myStringafd)
        return myStringafd
    }
    
   
}

func getDateFromEpochTimeStamp(_timestamp : Date,_ formate:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = DateFormatter.Style.medium
    dateFormatter.dateStyle = DateFormatter.Style.medium
    dateFormatter.timeZone = .current
    dateFormatter.dateFormat = formate
    let localDate = dateFormatter.string(from: _timestamp)
    return localDate
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class DeviceType{
    class func isIpad()->Bool {
        return UIDevice.current.userInterfaceIdiom == .pad ? true : false
    }
    
    class func isIphone5sAndBelow()->Bool{
        if UIScreen.main.bounds.height < 570 {
            return true
        }
        
        return false
    }
    
    class func isIphone6PlusAndAbove6()->Bool{
        if UIScreen.main.bounds.height > 660 && UIScreen.main.bounds.height < 740 {
            return true
        }
        
        return false
    }
    
    class func isIphoneXandAbove()->Bool{
        if UIScreen.main.bounds.height >= 812 {
            return true
        }
        
        return false
    }
    
    class func isIphone4sOrIpad()->Bool{
        if UIScreen.main.bounds.height < 481 || UIDevice.current.model.hasPrefix("iPad") {
            return true
        }
        
        return false
    }
}

extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)
        
        if let frame = frame {
            child.view.frame = frame
        }
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeChild(_ child : UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    
    func removeWhiteSpaces()->String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    var withoutSpecialCharacters: String {
        return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
    
    func removeSpecialCharsFromString(_ str: String) -> String {
        struct Constants {
            static let validChars = Set("1234567890")
        }
        return String(str.filter { Constants.validChars.contains($0) })
    }
    
    var trim: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isBlank: Bool {
        return self.trim.isEmpty
    }
    
    //([+]?\d{1,2}[.-\s]?)?(\d{3}[.-]?){2}\d{4}
    public func isPhoneNumber()->Bool {
        if self.isAllDigits() == true {
            let phoneRegex = "[235689][0-9]{6}([0-9]{3})?"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return  predicate.evaluate(with: self)
        }else {
            return false
        }
    }
    
    private func isAllDigits()->Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = self.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  self == filtered
    }
    
    var isValidPhoneNo: Bool {
        let phoneCharacters = CharacterSet(charactersIn: "+0123456789").inverted
        let arrCharacters = self.components(separatedBy: phoneCharacters)
        return self == arrCharacters.joined(separator: "")
    }
    
    var isValidPassword: Bool {
        let passwordRegex = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return predicate.evaluate(with:self)
    }
    
    var isValidPhone: Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{9,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    var isValidURL: Bool {
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }
    
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    func getDateTimeinFormate(_inFormate:String,_ outFormate:String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = _inFormate
        let yourDate = formatter.date(from: self)
        formatter.dateFormat = outFormate
        let myStringafd = formatter.string(from: yourDate!)
        print(myStringafd)
        return myStringafd
    }
    
}

func openAlert(title: String, message: String, alertStyle:UIAlertController.Style,actionTitles:[String],actionStyles:[UIAlertAction.Style], actions: [((UIAlertAction) -> Void)]) {
    if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated(){
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        rootVC.present(alertController, animated: true)
    }
}

func showAlert(alertTitle: String, message: String, vc: UIViewController) {
    let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    vc.present(alertController, animated: true, completion: nil)
}

func showAlertController(strTitle : String ,strMessage:String , viewController : UIViewController) {
    let alertController = UIAlertController.init(title: strTitle, message: strMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { action in
        alertController.dismiss(animated: true, completion: nil)
    }))
    viewController.present(alertController, animated: true, completion: nil)
}

func showAlertAndRedirectToSetting(strTitle : String, strMessage : String, viewController : UIViewController) {
    let alertController = UIAlertController.init(title: strTitle, message: strMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction.init(title: "Settings", style: .default, handler: { action in
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }))
    viewController.present(alertController, animated: true, completion: nil)
}


func noDataLabelForTableView(tableVw : UITableView) {
    let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableVw.bounds.size.width, height: tableVw.bounds.size.height))
    noDataLabel.text          = "No data available"
    noDataLabel.textColor     = UIColor.white
    noDataLabel.textAlignment = .center
    tableVw.backgroundView  = noDataLabel
    tableVw.separatorStyle  = .none
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

extension Int {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int>.size)
    }
}

extension UInt8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension UIView {
    func roundBottomCorners(cornerRadius: Double) {
        //        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let rectShape = CAShapeLayer()
        self.layer.mask = rectShape
        self.clipsToBounds = true
        
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20 , height: 20)).cgPath
        layer.mask = rectShape
        
        var shadowPath = UIBezierPath()
        layer.cornerRadius = 20.0
        shadowPath = UIBezierPath(roundedRect: CGRect.init(x: bounds.origin.x-2, y: bounds.origin.x, width: bounds.size.width+4, height: bounds.size.height), cornerRadius: 20.0)
        
        self.clipsToBounds = true
        layer.masksToBounds = false
        //        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        //        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        rectShape.path = shadowPath.cgPath
    }
    
    func roundCorners(cornerRadius: Double) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
    }
}

extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        return mapToDevice(identifier: identifier)
    }()
}

class Reachability {
    class func isAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}

class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 5.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIView {
    func applyRadiusMaskFor(topLeft: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0, topRight: CGFloat = 0) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width - topRight, y: 0))
        path.addLine(to: CGPoint(x: topLeft, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: topLeft), controlPoint: .zero)
        path.addLine(to: CGPoint(x: 0, y: bounds.height - bottomLeft))
        path.addQuadCurve(to: CGPoint(x: bottomLeft, y: bounds.height), controlPoint: CGPoint(x: 0, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.width - bottomRight, y: bounds.height))
        path.addQuadCurve(to: CGPoint(x: bounds.width, y: bounds.height - bottomRight), controlPoint: CGPoint(x: bounds.width, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.width, y: topRight))
        path.addQuadCurve(to: CGPoint(x: bounds.width - topRight, y: 0), controlPoint: CGPoint(x: bounds.width, y: 0))
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        layer.mask = shape
    }

}


func dataWithHexString(hex: String) -> Data {
    var hex = hex
    var data = Data()
    while(hex.count > 0) {
        let subIndex = hex.index(hex.startIndex, offsetBy: 2)
        let c = String(hex[..<subIndex])
        hex = String(hex[subIndex...])
        var ch: UInt32 = 0
        Scanner(string: c).scanHexInt32(&ch)
        var char = UInt8(ch)
        data.append(&char, count: 1)
    }
    return data
}


func removeSpecialCharsFromString1(text: String) -> String {
    let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
    return text.filter {okayChars.contains($0) }
}


extension URL {
    func download(to directory: FileManager.SearchPathDirectory, using fileName: String? = nil, overwrite: Bool = false, completion: @escaping (URL?, Error?) -> Void) throws {
        let directory = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destination: URL
        if let fileName = fileName {
            destination = directory
                .appendingPathComponent(fileName)
                .appendingPathExtension(self.pathExtension)
        } else {
            destination = directory
            .appendingPathComponent(lastPathComponent)
        }
        if !overwrite, FileManager.default.fileExists(atPath: destination.path) {
            completion(destination, nil)
            return
        }
        URLSession.shared.downloadTask(with: self) { location, _, error in
            guard let location = location else {
                completion(nil, error)
                return
            }
            do {
                if overwrite, FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.moveItem(at: location, to: destination)
                completion(destination, nil)
            } catch {
                print(error)
            }
        }.resume()
    }
}

func getFile(forResource fileName: String) { // -> Int
    var firmwareFileSize : Int = 0
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    print(path)
    
//    do {
//        let firmwareFileCountinBytes = try Data(contentsOf: path)
//        print(firmwareFileCountinBytes.count)
//        firmwareFileSize = firmwareFileCountinBytes.count
//    } catch {
//        print(error.localizedDescription)
//    }
//    return firmwareFileSize
}
