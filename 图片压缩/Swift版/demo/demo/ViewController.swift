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
        
        let scrol = UIScrollView.init(frame: view.bounds)
        view.addSubview(scrol)
        
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
        
        scrol.addSubview(lowImg)
        
        let labLow = UILabel.init(frame: CGRect(x: 0, y: lowImg.frame.maxY+10, width: lowImg.frame.width, height: 20))
        labLow.text = "压缩之后大小：\(formatter.string(fromByteCount: Int64(da.length)))"
        scrol.addSubview(labLow)
        
        //原图片
        let imgSource = UIImageView(image: UIImage(named: "世界地图.jpg"))
        imgSource.frame = CGRect(x: 0, y: labLow.frame.maxY+20, width: 240, height: 320)
        
        scrol.addSubview(imgSource)
        
        let labSource = UILabel.init(frame: CGRect(x: 0, y: imgSource.frame.maxY+10, width: imgSource.frame.width, height: 20))
        labSource.text = "原图大小：\(formatter.string(fromByteCount: Int64((UIImagePNGRepresentation(UIImage(named: "世界地图.jpg")!)?.count)!)))"
        scrol.addSubview(labSource)
        
        //图片增加保存本地功能
        let btn = UIButton(frame: CGRect(x: lowImg.frame.maxX+10, y: 100, width: 120, height: 40))
        btn.addTarget(self, action: #selector(save), for: .touchUpInside)
        btn.setTitle("保存压缩图片", for: .normal)
        btn.backgroundColor = UIColor.orange
        scrol.addSubview(btn)
        
        scrol.contentSize = CGSize(width: btn.frame.maxX+10, height: labSource.frame.maxY+10)
    }
    
    // MARK: - 保存图片后到相册后，调用的相关方法，查看是否保存成功
    @objc private func imageWasSavedSuccessfully(paramImage: UIImage, didFinishSavingWithError paramError: NSError?, contextInfo paramContextInfo: UnsafeMutableRawPointer) {
        if paramError == nil {
            let alert = UIAlertView.init(title: "提示", message: "保存成功", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
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
    func resetSizeOfImageData(source_image: UIImage!, maxSize: Int) -> NSData {
        
        //先判断当前质量是否满足要求，不满足再进行压缩
        var finallImageData = UIImageJPEGRepresentation(source_image,1.0)
        let sizeOrigin      = finallImageData?.count
        let sizeOriginKB    = sizeOrigin! / 1024
        if sizeOriginKB <= maxSize {
            return finallImageData! as NSData
        }
        
        //先调整分辨率
        var defaultSize = CGSize(width: 1024, height: 1024)
        let newImage = self.newSizeImage(size: defaultSize, source_image: source_image)
        
        finallImageData = UIImageJPEGRepresentation(newImage,1.0);
        
        //保存压缩系数
        let compressionQualityArr = NSMutableArray()
        let avg = CGFloat(1.0/250)
        var value = avg
        
        var i = 250
        repeat {
            i -= 1
            value = CGFloat(i)*avg
            compressionQualityArr.add(value)
        } while i >= 1

        
        /*
         调整大小
         说明：压缩系数数组compressionQualityArr是从大到小存储。
         */
        //思路：使用二分法搜索
        finallImageData = self.halfFuntion(arr: compressionQualityArr.copy() as! [CGFloat], image: newImage, sourceData: finallImageData!, maxSize: maxSize)
        //如果还是未能压缩到指定大小，则进行降分辨率
        while finallImageData?.count == 0 {
            //每次降100分辨率
            if defaultSize.width-100 <= 0 || defaultSize.height-100 <= 0 {
                break
            }
            defaultSize = CGSize(width: defaultSize.width-100, height: defaultSize.height-100)
            let image = self.newSizeImage(size: defaultSize, source_image: UIImage.init(data: UIImageJPEGRepresentation(newImage, compressionQualityArr.lastObject as! CGFloat)!)!)
            finallImageData = self.halfFuntion(arr: compressionQualityArr.copy() as! [CGFloat], image: image, sourceData: UIImageJPEGRepresentation(image,1.0)!, maxSize: maxSize)
        }
        
        return finallImageData! as NSData
    }
    
    // MARK: - 调整图片分辨率/尺寸（等比例缩放）
    func newSizeImage(size: CGSize, source_image: UIImage) -> UIImage {
        var newSize = CGSize(width: source_image.size.width, height: source_image.size.height)
        let tempHeight = newSize.height / size.height
        let tempWidth = newSize.width / size.width
        
        if tempWidth > 1.0 && tempWidth > tempHeight {
            newSize = CGSize(width: source_image.size.width / tempWidth, height: source_image.size.height / tempWidth)
        } else if tempHeight > 1.0 && tempWidth < tempHeight {
            newSize = CGSize(width: source_image.size.width / tempHeight, height: source_image.size.height / tempHeight)
        }
        
        UIGraphicsBeginImageContext(newSize)
        source_image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // MARK: - 二分法
    func halfFuntion(arr: [CGFloat], image: UIImage, sourceData finallImageData: Data, maxSize: Int) -> Data? {
        var tempFinallImageData = finallImageData
        
        var tempData = Data.init()
        var start = 0
        var end = arr.count - 1
        var index = 0
        
        var difference = Int.max
        while start <= end {
            index = start + (end - start)/2
            
            tempFinallImageData = UIImageJPEGRepresentation(image, arr[index])!
            
            let sizeOrigin = tempFinallImageData.count
            let sizeOriginKB = sizeOrigin / 1024
            
            print("当前降到的质量：\(sizeOriginKB)\n\(index)----\(arr[index])")
            
            if sizeOriginKB > maxSize {
                start = index + 1
            } else if sizeOriginKB < maxSize {
                if maxSize-sizeOriginKB < difference {
                    difference = maxSize-sizeOriginKB
                    tempData = tempFinallImageData
                }
                end = index - 1
            } else {
                break
            }
        }
        return tempData
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
