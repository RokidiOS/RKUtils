//
//  UIImage+RKExtension.swift
//  RKUtils
//
//  Created by chzy on 2021/11/4.
//

import Foundation
import ImageIO
import Accelerate

extension UIImage {

    /// 获得原图
    ///
    /// - Returns: cicleImage
    public func cicleImage() -> UIImage {

        // 开启图形上下文 false代表透明
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // 获取上下文
        let ctx = UIGraphicsGetCurrentContext()
        // 添加一个圆
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ctx?.addEllipse(in: rect)
        // 裁剪
        ctx?.clip()
        // 将图片画上去
        draw(in: rect)
        // 获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    /// 裁剪给定区域
    /// crop: 裁剪区域
    /// - Returns: cropImage
    public func cropWithCropRect( _ crop: CGRect) -> UIImage?
    {
        let cropRect = CGRect(x: crop.origin.x * self.scale, y: crop.origin.y * self.scale, width: crop.size.width * self.scale, height: crop.size.height *  self.scale)
        
        if cropRect.size.width <= 0 || cropRect.size.height <= 0 {
            return nil
        }
        var image:UIImage?
        autoreleasepool{
            let imageRef: CGImage?  = self.cgImage!.cropping(to: cropRect)
            if let imageRef = imageRef {
                image = UIImage(cgImage: imageRef)
            }
        }
        return image
    }
    
    /// 设置图片透明度
    /// alpha: 透明度
    /// - Returns: newImage
    func imageByApplayingAlpha(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -area.height)
        context?.setBlendMode(.multiply)
        context?.setAlpha(alpha)
        context?.draw(self.cgImage!, in: area)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    /// 按比例减少尺寸
    ///
    /// - Parameter sz: 原始图像尺寸.
    /// - Parameter limit:目标尺寸.
    /// - Returns: 函数按比例返回缩小后的尺寸
    func reduceSize(_ sz: CGSize, _ limit: CGFloat) -> CGSize {
        let maxPixel = max(sz.width, sz.height)
        guard maxPixel > limit else {
            return sz
        }
        var resSize: CGSize!
        let ratio = sz.height / sz.width;
        
        if (sz.width > sz.height) {
            resSize = CGSize(width:limit, height:limit*ratio);
        } else {
            resSize = CGSize(width:limit/ratio, height:limit);
        }
        
        return resSize;
    }

    
    /// 根据尺寸重新生成图片
     ///
     /// - Parameter size: 设置的大小
     /// - Returns: 新图
     public func imageWithNewSize(size: CGSize) -> UIImage? {
     
         if self.size.height > size.height {
             
             let width = size.height / self.size.height * self.size.width
             
             let newImgSize = CGSize(width: width, height: size.height)
             
             UIGraphicsBeginImageContext(newImgSize)
             
             self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
             
             let theImage = UIGraphicsGetImageFromCurrentImageContext()
             
             UIGraphicsEndImageContext()
             
             guard let newImg = theImage else { return  nil}
             
             return newImg
             
         } else {
             
             let newImgSize = CGSize(width: size.width, height: size.height)
             
             UIGraphicsBeginImageContext(newImgSize)
             
             self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
             
             let theImage = UIGraphicsGetImageFromCurrentImageContext()
             
             UIGraphicsEndImageContext()
             
             guard let newImg = theImage else { return  nil}
             
             return newImg
         }
     
     }
    
    //压缩图片到指定大小
    public class func compressWithMaxCount(origin:UIImage,maxCount:Int) -> Data? {
        var compression:CGFloat = 1
        guard var data = origin.jpegData(compressionQuality: compression) else { return nil }
        if data.count <= maxCount {
            return data
        }
        var max:CGFloat = 1,min:CGFloat = 0.8//最小0.8
        for _ in 0..<6 {//最多压缩6次
            compression = (max+min)/2
            if let tmpdata = origin.jpegData(compressionQuality: compression) {
                data = tmpdata
            } else {
                return nil
            }
            if data.count <= maxCount {
                return data
            } else {
                max = compression
            }
        }
        
        //压缩分辨率
        guard var resultImage = UIImage(data: data) else { return nil }
        var lastDataCount:Int = 0
        while data.count > maxCount && data.count != lastDataCount {
            lastDataCount = data.count
            let ratio = CGFloat(maxCount)/CGFloat(data.count)
            let size = CGSize(width: resultImage.size.width*sqrt(ratio), height: resultImage.size.height*sqrt(ratio))
            UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(Int(size.width)), height: CGFloat(Int(size.height))), true, 1)//防止黑边
            resultImage.draw(in: CGRect(origin: .zero, size: size))//比转成Int清晰
            if let tmp = UIGraphicsGetImageFromCurrentImageContext() {
                resultImage = tmp
                UIGraphicsEndImageContext()
            } else {
                UIGraphicsEndImageContext()
                return nil
            }
            if let tmpdata = resultImage.jpegData(compressionQuality: compression) {
                data = tmpdata
            } else {
                return nil
            }
        }
        return data
    }
    public class func resizedImage(at data: Data, for size: CGSize) -> UIImage? {
        // Decode the source image
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
            let imageWidth = properties[kCGImagePropertyPixelWidth] as? vImagePixelCount,
            let imageHeight = properties[kCGImagePropertyPixelHeight] as? vImagePixelCount
            else {
                return nil
        }
        
        // Define the image format
        var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                          bitsPerPixel: 32,
                                          colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          version: 0,
                                          decode: nil,
                                          renderingIntent: .defaultIntent)
        
        var error: vImage_Error
        
        // Create and initialize the source buffer
        var sourceBuffer = vImage_Buffer()
        defer { sourceBuffer.data.deallocate() }
        error = vImageBuffer_InitWithCGImage(&sourceBuffer,
                                             &format,
                                             nil,
                                             image,
                                             vImage_Flags(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        // Create and initialize the destination buffer
        var destinationBuffer = vImage_Buffer()
        error = vImageBuffer_Init(&destinationBuffer,
                                  vImagePixelCount(size.height),
                                  vImagePixelCount(size.width),
                                  format.bitsPerPixel,
                                  vImage_Flags(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        // Scale the image
        error = vImageScale_ARGB8888(&sourceBuffer,
                                     &destinationBuffer,
                                     nil,
                                     vImage_Flags(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        
        // Create a CGImage from the destination buffer
        guard let resizedImage =
            vImageCreateCGImageFromBuffer(&destinationBuffer,
                                          &format,
                                          nil,
                                          nil,
                                          vImage_Flags(kvImageNoAllocate),
                                          &error)?.takeRetainedValue(),
            error == kvImageNoError
            else {
                return nil
        }
        
        return UIImage(cgImage: resizedImage)
    }
}
