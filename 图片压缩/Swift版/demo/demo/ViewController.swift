//
//  ViewController.swift
//  demo
//
//  Created by SuperDanny on 16/1/20.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate {
    
    var lowImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //降质量图片
        let da = self.resetSizeOfImageData(source_image: UIImage(named: "世界地图.jpg")!, maxSize: 200)
        
        let formatter = ByteCountFormatter()
        formatter.countStyle   = .file
        formatter.allowedUnits = .useKB
        
        let sourceKB = formatter.string(fromByteCount: Int64((UIImagePNGRepresentation(UIImage(named: "世界地图.jpg")!)?.count)!))
        let lowKB = formatter.string(fromByteCount: Int64(da.length))
        
        print("\(sourceKB),\(lowKB)")
        
        let image = UIImage(data: da as Data)
        
        lowImg = UIImageView(image: image)
        lowImg.frame = CGRect(x: 0, y: 0, width: 240, height: 320)
        
        self.view.addSubview(lowImg)
        
        //原图片
        let imgSource = UIImageView(image: UIImage(named: "世界地图.jpg"))
        imgSource.frame = CGRect(x: 0, y: 330, width: 240, height: 320)
        
        self.view.addSubview(imgSource)
        
        //图片增加保存本地功能
        let btn = UIButton(frame: CGRect(x: lowImg.frame.maxX+10, y: 100, width: 120, height: 40))
        btn.addTarget(self, action: #selector(save), for: .touchUpInside)
        btn.setTitle("保存压缩图片", for: .normal)
        btn.backgroundColor = UIColor.orange
        self.view.addSubview(btn)
    }
    
    // MARK: - 保存图片后到相册后，调用的相关方法，查看是否保存成功
    @objc private func imageWasSavedSuccessfully(paramImage: UIImage, didFinishSavingWithError paramError: NSError?, contextInfo paramContextInfo: UnsafeMutableRawPointer) {
        if paramError == nil {
            print("Image was saved successfully.")
        } else {
            print("An error happened while saving the image.Error = \(paramError)")
        }
    }
    
    // MARK: - 保存到相册
    @objc private func save() {
        // 保存图片到相册中
        let selectorToCall = #selector(imageWasSavedSuccessfully(paramImage:didFinishSavingWithError:contextInfo:))
//            Selector("imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:")
        UIImageWriteToSavedPhotosAlbum(lowImg.image!, self, selectorToCall, nil)
    }
    
    // MARK: - 降低质量
    func resetSizeOfImageData(source_image: UIImage, maxSize: Int) -> NSData {
        //先调整分辨率
        var newSize = CGSize(width: source_image.size.width, height: source_image.size.height)
        
        let tempHeight = newSize.height / 1024
        let tempWidth  = newSize.width / 1024
        
        if tempWidth > 1.0 && tempWidth > tempHeight {
            newSize = CGSize(width: source_image.size.width / tempWidth, height: source_image.size.height / tempWidth)
        }
        else if tempHeight > 1.0 && tempWidth < tempHeight {
            newSize = CGSize(width: source_image.size.width / tempHeight, height: source_image.size.height / tempHeight)
        }
        
        UIGraphicsBeginImageContext(newSize)
        source_image.drawAsPattern(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //先判断当前质量是否满足要求，不满足再进行压缩
        var finallImageData = UIImageJPEGRepresentation(newImage!,1.0)
        let sizeOrigin      = Int64((finallImageData?.count)!)
        let sizeOriginKB    = Int(sizeOrigin / 1024)
        if sizeOriginKB <= maxSize {
            return finallImageData! as NSData
        }
        
        //保存压缩系数
        let compressionQualityArr = NSMutableArray()
        let avg = CGFloat(1.0/250)
        var value = avg
        
//        for var i = 250; i>=1; i-- {
//            value = CGFloat(i)*avg
//            compressionQualityArr.add(value)
//        }
        var i = 250
        repeat {
            i -= 1
            value = CGFloat(i)*avg
            compressionQualityArr.add(value)
        } while i >= 1

        
        //调整大小
        //说明：压缩系数数组compressionQualityArr是从大到小存储。
        //思路：折半计算，如果中间压缩系数仍然降不到目标值maxSize，则从后半部分开始寻找压缩系数；反之从前半部分寻找压缩系数
        finallImageData = UIImageJPEGRepresentation(newImage!, CGFloat(compressionQualityArr[125] as! NSNumber))
        if Int(Int64((UIImageJPEGRepresentation(newImage!, CGFloat(compressionQualityArr[125] as! NSNumber))?.count)!)/1024) > maxSize {
            
            //拿到最初的大小
            finallImageData = UIImageJPEGRepresentation(newImage!, 1.0)
            
            //从后半部分开始
            for idx in 126..<250 {
                let value = compressionQualityArr[idx]
                let sizeOrigin   = Int64((finallImageData?.count)!)
                let sizeOriginKB = Int(sizeOrigin / 1024)
                print("后半部分当前降到的质量：\(sizeOriginKB)")
                if sizeOriginKB > maxSize {
                    print("\(idx)----\(value)")
                    finallImageData = UIImageJPEGRepresentation(newImage!, CGFloat(value as! NSNumber))
                } else {
                    break
                }
            }
        } else {
            //拿到最初的大小
            finallImageData = UIImageJPEGRepresentation(newImage!, 1.0)
            //从前半部分开始
            for idx in 0..<125 {
                let value = compressionQualityArr[idx]
                let sizeOrigin   = Int64((finallImageData?.count)!)
                let sizeOriginKB = Int(sizeOrigin / 1024)
                print("前半部分当前降到的质量：\(sizeOriginKB)")
                if sizeOriginKB > maxSize {
                    print("\(idx)----\(value)")
                    finallImageData = UIImageJPEGRepresentation(newImage!, CGFloat(value as! NSNumber))
                } else {
                    break
                }
            }
        }
        return finallImageData! as NSData
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
