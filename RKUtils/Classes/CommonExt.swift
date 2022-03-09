//
//  CommonExt.swift
//  RKUtils
//
//  Created by chzy on 2021/11/01.
//

import Foundation
import UIKit
import CommonCrypto

let appName = LocalizedString("app_name")

// MARK: - 全局常量
// MARK: UI
public let STATUSBAR_HEIGHT: CGFloat = 20
public class UI: NSObject {
    public static let ScreenWidth  = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    public static let ScreenHeight = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    public static let ScreenScale = ScreenWidth / 375.0
    public static let ScreenPixelScale = {return UIScreen.main.scale}()
    public static let ScreenHeightScale =  ScreenHeight / 667.0
    public static let SafeAreaInsets: UIEdgeInsets = {return ( Dev.IsIPhoneXScreen ? UIEdgeInsets.init(top: 24, left: 0, bottom: 24, right: 0) : UIEdgeInsets.zero)}()
    public static let SafeTopHeight: CGFloat = {return UI.SafeAreaInsets.top}()
    public static let SafeBottomHeight: CGFloat = {return UI.SafeAreaInsets.bottom}()
}

// MARK: 设备
public class Dev: NSObject {
    static let IsIPhoneNotch  = {
        return UI.ScreenHeight / UI.ScreenWidth > 17 / 9.0
    }()
    
    static let IsIPhone4  = {
        return UI.ScreenHeight < 481
    }()
    
    static let IsIPhone5  = {
        return UI.ScreenHeight < 600 && UI.ScreenHeight > 500
    }()
    
    static let IsIPhonePlus  = {
        return UI.ScreenWidth > 375 && UI.ScreenHeight > 667
    }()
    static let IsIPhoneXScreen = { () -> Bool in
        guard #available(iOS 11.0, *) else {
            return false
        }
        return UIApplication.shared.windows[0].safeAreaInsets.bottom > 0
    }()
    // 是否横屏
    static var IsLandscape: Bool {
        get { UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height }
    }
}

public func bundle(_ bundleName: String, _ aclass: AnyClass) -> Bundle {
    let curbundle =  Bundle(for: aclass)
    let resourcePath = curbundle.path(forResource: bundleName, ofType: "bundle") ?? ""
    let resourceBundle = Bundle(path: resourcePath)
    return resourceBundle ?? Bundle.main
}


public let RKResourceBundle: Bundle = {
    let resourcePath = Bundle.main.path(forResource: "RKSDKBundle", ofType: "bundle") ?? ""
    let resourceBundle = Bundle(path: resourcePath)
    return resourceBundle ?? Bundle.main
}()

public let SDKBundle: Bundle = {
    let currentLanguage = (UserDefaults.standard.object(forKey: "AppleLanguages") as! [String])[0]
    var bundle = Bundle.main
//    Bundle(for: RokidSDK.RKLoginViewController.classForCoder())
    var path: String = bundle.path(forResource: "zh-Hans", ofType: "lproj") ?? ""
    if currentLanguage.hasPrefix("en") {
        path = bundle.path(forResource: "", ofType: "lproj") ?? ""
    }
    return Bundle.init(path: path) ?? Bundle.main
}()

public func LocalizedString(_ string: String) -> String {
   return SDKBundle.localizedString(forKey: string, value: nil, table: nil)
}

public func currentLanguage () -> String {
    let currentLanguage = (UserDefaults.standard.object(forKey: "AppleLanguages") as! [String])[0]
    if !currentLanguage.hasPrefix("id") && !currentLanguage.hasPrefix("ru") && !currentLanguage.hasPrefix("pt") && !currentLanguage.hasPrefix("es") {
        return "en"
    }
    return currentLanguage
}
public func currentRegionCode() -> String {
    return Locale.current.regionCode ?? ""
}

public extension Dictionary {
    func jsonString() -> String?{
        let data = try? JSONSerialization.data(withJSONObject: self, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        return str
    }
}

// MARK: - 类扩展
public extension UIColor {
    /// 将十六进制颜色转换为UIColor
    @objc public convenience init(hexColor: String, alpha: CGFloat = 1.0) {
        var pureHexString = hexColor
        if hexColor.hasPrefix("#") {
            pureHexString.remove(at: pureHexString.firstIndex(of: "#")!)
        }
        
        // 存储转换后的数值
        var red: UInt32 = 0, green: UInt32 = 0, blue: UInt32 = 0
        
        if pureHexString.count < 6 {
            self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
            return
        }
        
        // 分别转换进行转换
        Scanner(string: pureHexString[0..<2]).scanHexInt32(&red)
        
        Scanner(string: pureHexString[2..<4]).scanHexInt32(&green)
        
        Scanner(string: pureHexString[4..<6]).scanHexInt32(&blue)
        
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    convenience init(r: Int, g: Int, b: Int, a: Int = 255) {
        // 存储转换后的数值
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
    }
    
    // MARK: - 颜色转16进制字符串
    @objc public var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return ""
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}

public extension UIView {
    func takeScreenshot() -> UIImage? {
        guard frame.size.height > 0 && frame.size.width > 0 else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setCorner(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func superVC() -> UIViewController? {
        var view: UIView? = self
        
        while view != nil {
            let nextResponder = view?.next
            
            if nextResponder != nil && nextResponder!.isKind(of: UIViewController.self) {
                return nextResponder as? UIViewController
            }
            
            view = view?.superview
        }
        
        return nil;
    }
    
    // MARK: - 获取当前视图所在导航控制器
    func superNavViewController() -> UINavigationController? {
        var n = next
        while n != nil {
            if n is UINavigationController {
                return n as? UINavigationController
            }
            n = n?.next
        }
        return nil
    }
    
}

public extension String {
    /// String使用下标截取字符串
    /// 例: "示例字符串"[0..<2] 结果是 "示例"
    subscript (r: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
    
    // MARK: - Base64编码
    func base64Encode() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    // MARK: - Base64解码
    func base64Decode() -> String {
        guard let data = Data(base64Encoded: self) else {
            return ""
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    public static func uuid() -> String {
        return UUID().uuidString
    }
    
    func replacingLocalizedStringPlaceholder(with string: String) -> String {
        return self.replacingOccurrences(of: "---", with: string)
    }
    
    ///定位子字符串(NSRange)
    func nsRange(of string: String) -> NSRange {
        guard let range = self.range(of: string) else {return NSRange(location: 0, length: 0)}
        return NSRange(range, in: self)
    }
    
    func positionOf(sub: String, backwards: Bool = false) -> Int {
        // 如果没有找到就返回-1
        var pos = -1
        if let range = range(of: sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from: startIndex, to: range.lowerBound)
            }
        }
        return pos
    }
    
    func appendingPath(path: String) -> String {
        if let lastChar =  self.last {
            let pathFirstChar = path.first
            return (lastChar == "/" || pathFirstChar == "/") ? self.appending(path):self.appending("/\(path)")
        }
        return path
    }
    
    func estimatedSize(withFont font: UIFont, maxWidth: CGFloat ) -> CGSize {
        let string = self as NSString
        return string.boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
    
    func toDictionary() -> [String:AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    static func dateFormatString(timeStamp:Int64, formatStr: String? = "yyyy-MM-dd HH:mm:ss") ->String {
        let interval:TimeInterval=TimeInterval.init(timeStamp)
        let date = Date(timeIntervalSince1970: interval)
        let dateformatter = DateFormatter()
        //自定义日期格式
        dateformatter.dateFormat = formatStr
        return dateformatter.string(from: date)
    }
    
    static func formatTimeLong(timeStamp: Int64) ->String {
        if timeStamp < 60 {
            return String.init("0小时0分\(timeStamp)秒")
        } else if timeStamp < 3600 {
            return String.init("0小时\(timeStamp / 60)分\(timeStamp % 60)秒")
        }
        
        return String.init("\(timeStamp / 3600)小时\(timeStamp % 3600 / 60)分\(timeStamp % 60)秒")
    }
    
}

public extension Array where Element: Equatable {
    func count(ofElement element: Element) -> Int {
        return self.filter { (e) -> Bool in
            return e == element
        }.count
    }
}

public extension NSAttributedString {
    func estimatedSize(maxWidth: CGFloat = CGFloat(MAXFLOAT), maxHeight: CGFloat = CGFloat(MAXFLOAT), attributes: [NSAttributedString.Key: Any] =  [:] ) -> CGSize {
        return string.boundingRect(with: CGSize(width: maxWidth, height: maxHeight), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: attributes, context: nil).size
    }
}

public extension UILabel {
    open func set(text: String, textColor: UIColor = .white, textFont: UIFont = UIFont.systemFont(ofSize: 12), textAlignment: NSTextAlignment = .center) {
        self.text = text
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.font = textFont
    }
    
    open func estimatedHeight(withMaxWidth maxWidth: CGFloat ) -> CGFloat {
        return estimatedTextSize(withMaxWidth: maxWidth).height
    }
    
    open func estimatedWidth(withMaxWidth maxWidth: CGFloat ) -> CGFloat {
        return estimatedTextSize(withMaxWidth: maxWidth).width
    }
    
    open func estimatedTextSize(withMaxWidth maxWidth: CGFloat ) -> CGSize {
        guard let text = self.text else { return .zero }
        return text.estimatedSize(withFont: self.font, maxWidth: maxWidth)
    }
}

public extension UIImageView {
    open func getImageRect() -> CGRect {
        if self.contentMode == .scaleToFill || self.contentMode == .scaleAspectFill {
            return self.bounds
        }
        
        guard image != nil else {return CGRect.zero}
        var imageSize = image!.size
        let wScale = self.bounds.width / imageSize.width
        let hScale = self.bounds.height / imageSize.height
        let scale = min(wScale, hScale)
        
        imageSize.width *=  scale
        imageSize.height *= scale
        
        return CGRect(x: 0.5*(self.bounds.size.width - imageSize.width), y: 0.5*(self.bounds.size.height - imageSize.height), width: imageSize.width, height: imageSize.height)
    }
}

public extension UIButton {
    
    //    open func setImageName(_ imageName: String?, hightLightImageName hImageName: String?, selectedImageName sImageName: String?) {
    //        if let imageName = imageName {
    //            setImage(UIImage(named: imageName), for: .normal)
    //        }
    //
    //        if let hImageName = hImageName {
    //            setImage(UIImage(named: hImageName), for: .highlighted)
    //        }
    //
    //        if let sImageName = sImageName {
    //            setImage(UIImage(named: sImageName), for: .selected)
    //        }
    //    }
    
    open func setTitle(_ title: String, color: UIColor, font: UIFont, for state: UIControl.State) {
        self.setTitle(title, for: state)
        self.setTitleColor(color, for: state)
        self.titleLabel?.font = font
    }
    
    //    open func setCornerRadius(_ radius: CGFloat) {
    //        self.layer.cornerRadius = radius
    //        self.layer.masksToBounds = true
    //    }
    
    open func setAsTABStyle(titleImageSpace: CGFloat) {
        self.imageView?.contentMode = .scaleAspectFit
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -self.imageView!.frame.size.width, bottom: -(self.imageView?.frame.size.height ?? 0 + (titleImageSpace * 0.5)), right: 0)
        self.imageEdgeInsets = UIEdgeInsets(top: -(self.titleLabel?.intrinsicContentSize.height ?? 0) - titleImageSpace * 0.5, left: 0.0, bottom: 0.0, right: -(self.titleLabel?.intrinsicContentSize.width ?? 0))
    }
}

public extension URL {
    public static func returnFileSize(path: String) -> Double {
        let manager = FileManager.default
        var fileSize: Double = 0
        do {
            let attr = try manager.attributesOfItem(atPath: path)
            fileSize = Double(attr[FileAttributeKey.size] as! UInt64)
            let dict = attr as NSDictionary
            fileSize = Double(dict.fileSize())
        } catch {
            dump(error)
        }
        return fileSize/1024/1024
    }
    
    /**
     * 遍历所有子目录， 并计算文件大小
     */
    public static func forderSizeAtPath(folderPath: String) -> Double {
        let manage = FileManager.default
        if !manage.fileExists(atPath: folderPath) {
            return 0
        }
        let childFilePath = manage.subpaths(atPath: folderPath)
        var fileSize: Double = 0
        for path in childFilePath! {
            let fileAbsoluePath = folderPath+path
            fileSize += self.returnFileSize(path: fileAbsoluePath)
        }
        print(fileSize)
        return fileSize
    }
    
    public static func clearCacheWithPaht(folderPath: String) -> Bool {
        //拿到path路径的下一级目录的子文件夹
        do {
            let subarr = try FileManager.default.contentsOfDirectory(atPath: folderPath)
            for subpath in subarr {
                let filepath = folderPath.appendingPath(path: subpath)
                try FileManager.default.removeItem(atPath: filepath)
            }
            return true
        } catch {
            return false
        }
    }
    
    public static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first {
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
            return folderURL
        }
        return nil
    }
}

public extension NSDictionary {
    public static func convertToDic(jsonStr: String) -> NSDictionary {
        
        var dictonary: NSDictionary?
        if let data = jsonStr.data(using: String.Encoding.utf8) {
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
            } catch let error as NSError {
                print(error)
            }
        }
        return dictonary ?? [:]
    }
}

public extension Float {
    var cleanZeroString: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
}


public extension String {
    //获取文字的宽度
    func getStringWidth(_ font: UIFont) -> CGFloat {
        let textSize = self.size(withAttributes: [.font: font])
        return textSize.width
    }
    
    //获取文字的高度(需要一个最大宽度)
    func getStringHeight(font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: maxWidth, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return rect.height
    }
    
    func stringToNumber() -> Double {
        let str = self
        var number: Double = 0
        
        if let num = Double(str) {
            number = num
        }
        
        return number
    }
    
    func stringToPercent() -> Double {
        let str = self
        var number: Double = 0
        
        if let num = Double(str) {
            number = num
        }
        
        return number/100
    }
}

public extension NSMutableAttributedString {
    convenience init?(elements: [(str :String, attr : [NSAttributedString.Key:Any])]) {
        
        guard elements.count > 0 else {
            return nil
        }
        
        let allString:String = elements.reduce("") { (res, ele) ->String in
            return res + ele.str
        }
        
        self.init(string: allString)
        
        for ele in elements {
            let eleStr = ele.str
            if eleStr.isEmpty == false {
                let range: Range = allString.range(of: eleStr)!
                let nsRange: NSRange = NSRange(range, in: allString)
                self.addAttributes(ele.attr, range: nsRange)
            }
        }
    }
}

public extension UIColor {
    convenience init(hex:Int32) {
        self.init(hex: hex, alpha: 1)
    }
    //0x000000
    convenience init(hex:Int32, alpha:CGFloat = 1) {
        let r = CGFloat((hex & 0xff0000) >> 16) / 255
        let g = CGFloat((hex & 0xff00) >> 8) / 255
        let b = CGFloat(hex & 0xff) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

public extension UIImage {
    
    /// 加载bundle资源内
    convenience init?(named: String, aclass: AnyClass, bundleName: String? = nil) {
        let bund = bundleName ?? "RK"
        let path = bundle(bund, aclass)
        self.init(named: named, in: path, compatibleWith: nil)
    }
    
    
    convenience init?(named: String) {
        self.init(named: named, in: RKResourceBundle, compatibleWith: nil)
    }
    
    convenience init?(named: String, classObject: NSObject) {
        self.init(named: named, in: RKResourceBundle, compatibleWith: nil)
    }
    
    //用颜色生成图片
    convenience init(color: UIColor) {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let path = UIBezierPath(rect: CGRect(origin: .zero, size: size))
        color.set()
        path.fill()
        let image: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image.cgImage)!)
    }
    
    //将图片百分比缩放(不是指大小)
    func convevt(quality: Float) -> UIImage? {
        if let data = self.jpegData(compressionQuality: CGFloat(quality)), let photo = UIImage(data: data) {
            return photo
        }
        return nil
    }
    
    // MARK: - 将图片压缩到最大宽高 和指定大小 byte
    func compressToDataWith(maxWH: CGFloat, maxSize: Int = 2 * 1024 * 1024) -> UIImage{
        
        var newSize = self.size
        let tmpH = newSize.height / maxWH
        let tmpW = newSize.width / maxWH
        if tmpH > 0 && tmpW > tmpH{
            newSize = CGSize(width: self.size.width / tmpW, height: self.size.height / tmpW)
        } else if tmpH > 1.0 && tmpW < tmpH {
            newSize = CGSize(width: self.size.width / tmpH, height: self.size.height / tmpH)
        }
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img = newImg?.compressImageMidToImg(maxLength: maxSize){
            return img
        }
        return self
    }
    
    func compressImageMidToImg(maxLength: Int) -> UIImage {
        if let data = self.compressImageMid(maxLength: maxLength), let img = UIImage(data: data){
            return img
        }
        return self
    }
    
    func compressImageMid(maxLength: Int) -> Data? {
        var compression: CGFloat = 1
        guard var data = self.jpegData(compressionQuality: 1) else { return nil }
        if data.count < maxLength {
            return data
        }
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression)!
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        if data.count < maxLength {
            return data
        }
        return nil
    }
    
    //将图片缩放宽高(参数自定义)
    func reSizeImage(_ reSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale);
        self.draw(in: CGRect.init(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    //将图片裁成正方形(仍可自定义)
    func reCutImage() -> UIImage {
        let fixOrientationImage = self.fixOrientation()
        let cutFrame = CGRect.init(x: 0, y: (fixOrientationImage.size.height - fixOrientationImage.size.width) / 2, width: fixOrientationImage.size.width, height: fixOrientationImage.size.width)
        return UIImage.init(cgImage: (fixOrientationImage.cgImage?.cropping(to: cutFrame))!)
    }
    
    //调整图片的旋转方向   (回正)
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
            
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        default:
            break
        }
        
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
        
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
    
    // MARK: - 图片旋转
    func imageRotatedBy(radians: CGFloat) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        if let bitmap = UIGraphicsGetCurrentContext() {
            bitmap.setFillColor(UIColor.clear.cgColor)
            bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            bitmap.rotate(by: radians)
            bitmap.scaleBy(x: 1.0, y: -1.0)
            let rect = CGRect(x: -self.size.width / 2,
                              y: -self.size.height / 2,
                              width: self.size.width,
                              height: self.size.height)
            bitmap.draw(self.cgImage!, in: rect)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
}

public extension UIButton {
    func setBackgroundColor(_ color: UIColor, for states: UIControl.State) {
        self.setBackgroundImage(self.createImage(color), for: states)
    }
    
    private func createImage(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return colorImage!
    }
}

public extension UICollectionView {
    public func registerNib(_ nibName: String) {
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        register(nib, forCellWithReuseIdentifier: nibName)
    }
    
    public func registerClass(_ className: String) {
        register(NSClassFromString(className).self, forCellWithReuseIdentifier: className)
    }
    
    public func registerNib(_ nibName: String, identifier: String) {
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
}

public extension UITableView {
    public func registerNib(_ nibName: String) {
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        register(nib, forCellReuseIdentifier: nibName)
    }
    
    public func registerClass(_ className: String) {
        register(NSClassFromString(className), forCellReuseIdentifier: className)
    }
}

public extension UITextField {
    public func setPlaceHolder(text:String?, color:UIColor = UIColor.gray) {
        let attrStr = NSAttributedString.init(string: text ?? "", attributes: [NSAttributedString.Key.foregroundColor:color, NSAttributedString.Key.font: self.font])
        self.attributedPlaceholder = attrStr
    }
}

public extension UIDevice {
    @objc public static func deviceNewOrientation(_ interfaceOrientation: UIInterfaceOrientationMask) {
        
        // support
        deviceSupportOrientation(interfaceOrientation)
        
        // set new
        if interfaceOrientation == .landscape {
            // 设置横屏
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        } else if interfaceOrientation == .portrait {
            // 设置竖屏
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    
    @objc static func deviceSupportOrientation(_ interfaceOrientation: UIInterfaceOrientationMask) {
//        TODO
//        RKCooperation.shareInstance().interfaceOrientation = interfaceOrientation
        //        RKCooperation.shareInstance().supportRotationDelegate?.setNewOrientation(interfaceOrientation)
    }
}

public extension UIView {
    
    /// 添加子视图列表
    /// - Parameter arrary: 子试图列表
    func addSubViews(_ arrary: [UIView]) {
           _ =  arrary.map { view  in
                addSubview(view)
        }
    }
}
