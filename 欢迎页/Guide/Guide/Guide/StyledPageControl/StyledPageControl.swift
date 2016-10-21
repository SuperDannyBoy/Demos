//
//  StyledPageControl.swift
//  Guide
//
//  Created by SuperDanny on 16/10/13.
//  Copyright © 2016年 SuperDanny. All rights reserved.
//

import UIKit

enum PageControlStyle : Int {
    case PageControlStyleDefault
    case PageControlStyleStrokedCircle
    case PageControlStylePressed1
    case PageControlStylePressed2
    case PageControlStyleWithPageNumber
    case PageControlStyleThumb
}

class StyledPageControl: UIControl {
    
    let COLOR_GRAYISHBLUE = UIColor(red: 128 / 255.0, green: 130 / 255.0, blue: 133 / 255.0, alpha: 1)
    let COLOR_GRAY = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    
    var coreNormalColor, coreSelectedColor: UIColor?
    var strokeNormalColor, strokeSelectedColor: UIColor?
    var currentPage, numberOfPages: Int?
    var hidesForSinglePage: Bool = true
    var pageControlStyle: PageControlStyle
    var strokeWidth, diameter, gapWidth: Int?
    var thumbImage, selectedThumbImage: UIImage?
    var thumbImageForIndex, selectedThumbImageForIndex: NSMutableDictionary?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(aDecoder)
        
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.clear
        self.strokeWidth = 2
        self.gapWidth = 10
        self.diameter = 12
        self.pageControlStyle = .PageControlStyleDefault
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapped))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func onTapped(_ gesture: UITapGestureRecognizer) {
        var touchPoint = gesture.location(in: gesture.view!)
        if touchPoint.x < self.frame.size.width / 2 {
            // move left
            if self.currentPage! > 0 {
                if touchPoint.x <= 22 {
                    currentPage = 0
                }
                else {
                    currentPage--
                }
            }
        }
        else {
            // move right
            if self.currentPage! < self.numberOfPages! - 1 {
                if touchPoint.x >= (self.bounds.width - 22) {
                    currentPage = numberOfPages! - 1
                }
                else {
                    currentPage++
                }
            }
        }
        self.setNeedsDisplay()
        self.sendActions(forControlEvents: .valueChanged)
    }
    
    override func draw(_ rect: CGRect) {
        var coreNormalColor: UIColor?
        var coreSelectedColor: UIColor?
        var strokeNormalColor: UIColor?
        var strokeSelectedColor: UIColor?
        if self.coreNormalColor {
            coreNormalColor = self.coreNormalColor
        }
        else {
            coreNormalColor = COLOR_GRAYISHBLUE
        }
        if self.coreSelectedColor {
            coreSelectedColor = self.coreSelectedColor
        }
        else {
            if self.pageControlStyle == PageControlStyleStrokedCircle || self.pageControlStyle == PageControlStyleWithPageNumber {
                coreSelectedColor = COLOR_GRAYISHBLUE
            }
            else {
                coreSelectedColor = COLOR_GRAY
            }
        }
        if self.strokeNormalColor {
            strokeNormalColor = self.strokeNormalColor
        }
        else {
            if self.pageControlStyle == PageControlStyleDefault && self.coreNormalColor {
                strokeNormalColor = self.coreNormalColor
            }
            else {
                strokeNormalColor = COLOR_GRAYISHBLUE
            }
        }
        if self.strokeSelectedColor {
            strokeSelectedColor = self.strokeSelectedColor
        }
        else {
            if self.pageControlStyle == PageControlStyleStrokedCircle || self.pageControlStyle == PageControlStyleWithPageNumber {
                strokeSelectedColor = COLOR_GRAYISHBLUE
            }
            else if self.pageControlStyle == PageControlStyleDefault && self.coreSelectedColor {
                strokeSelectedColor = self.coreSelectedColor
            }
            else {
                strokeSelectedColor = COLOR_GRAY
            }
        }
        // Drawing code
        if self.hidesForSinglePage && self.numberOfPages == 1 {
            return
        }
        var myContext = UIGraphicsGetCurrentContext()!
        var gap = self.gapWidth
        var diameter: Float = self.diameter - 2 * self.strokeWidth
        if self.pageControlStyle == PageControlStyleThumb {
            if self.thumbImage && self.selectedThumbImage {
                diameter = self.thumbImage.size.width
            }
        }
        var total_width = self.numberOfPages * diameter + (self.numberOfPages - 1) * gap
        if total_width > self.frame.size.width {
            while total_width > self.frame.size.width {
                diameter -= 2
                gap = diameter + 2
                while total_width > self.frame.size.width {
                    gap -= 1
                    total_width = self.numberOfPages * diameter + (self.numberOfPages - 1) * gap
                    if gap == 2 {
                        total_width = self.numberOfPages * diameter + (self.numberOfPages - 1) * gap
                    }
                }
                if diameter == 2 {
                    total_width = self.numberOfPages * diameter + (self.numberOfPages - 1) * gap
                }
            }
        }
        var i: Int
        for i in 0..<self.numberOfPages {
            var x = (self.frame.size.width - total_width) / 2 + i * (diameter + gap)
            if self.pageControlStyle == PageControlStyleDefault {
                if i == self.currentPage {
                    myContext.setFillColor(coreSelectedColor!.cgColor)
                    myContext.fillEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                    myContext.setStrokeColor(strokeSelectedColor!.cgColor)
                    myContext.strokeEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                }
                else {
                    myContext.setFillColor(coreNormalColor!.cgColor)
                    myContext.fillEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                    myContext.setStrokeColor(strokeNormalColor!.cgColor)
                    myContext.strokeEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                }
            }
            else if self.pageControlStyle == PageControlStyleStrokedCircle {
                myContext.setLineWidth(self.strokeWidth)
                if i == self.currentPage {
                    myContext.setFillColor(coreSelectedColor!.cgColor)
                    myContext.fillEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                    myContext.setStrokeColor(strokeSelectedColor!.cgColor)
                    myContext.strokeEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                }
                else {
                    myContext.setStrokeColor(strokeNormalColor!.cgColor)
                    myContext.strokeEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                }
            }
            else if self.pageControlStyle == PageControlStyleWithPageNumber {
                myContext.setLineWidth(self.strokeWidth)
                if i == self.currentPage {
                    var currentPageDiameter = diameter * 1.6
                    x = (self.frame.size.width - total_width) / 2 + i * (diameter + gap) - (currentPageDiameter - diameter) / 2
                    myContext.setFillColor(coreSelectedColor!.cgColor)
                    myContext.fillEllipse(in: CGRect(x: x, y: (self.frame.size.height - currentPageDiameter) / 2, width: currentPageDiameter, height: currentPageDiameter))
                    myContext.setStrokeColor(strokeSelectedColor!.cgColor)
                    myContext.strokeEllipse(in: CGRect(x: x, y: (self.frame.size.height - currentPageDiameter) / 2, width: currentPageDiameter, height: currentPageDiameter))
                    var pageNumber = "\(i + 1)"
                    myContext.setFillColor(UIColor.white.cgColor)
                    pageNumber.draw(inRect: CGRect(x: x, y: (self.frame.size.height - currentPageDiameter) / 2 - 1, width: currentPageDiameter, height: currentPageDiameter), withFont: UIFont.systemFont(ofSize: currentPageDiameter - 2), lineBreakMode: .characterWrap, alignment: .center)
                }
                else {
                    myContext.setStrokeColor(strokeNormalColor!.cgColor)
                    myContext.strokeEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                }
            }
            else if self.pageControlStyle == PageControlStylePressed1 || self.pageControlStyle == PageControlStylePressed2 {
                if self.pageControlStyle == PageControlStylePressed1 {
                    myContext.setFillColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor)
                    myContext.fillEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2 - 1, width: diameter, height: diameter))
                }
                else if self.pageControlStyle == PageControlStylePressed2 {
                    myContext.setFillColor(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor)
                    myContext.fillEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2 + 1, width: diameter, height: diameter))
                }
                
                if i == self.currentPage {
                    myContext.setFillColor(coreSelectedColor!.cgColor)
                    myContext.fillEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                    myContext.setStrokeColor(strokeSelectedColor!.cgColor)
                    myContext.strokeEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                }
                else {
                    myContext.setFillColor(coreNormalColor!.cgColor)
                    myContext.fillEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                    myContext.setStrokeColor(strokeNormalColor!.cgColor)
                    myContext.strokeEllipse(in: CGRect(x: x, y: (self.frame.size.height - diameter) / 2, width: diameter, height: diameter))
                }
            }
            else if self.pageControlStyle == PageControlStyleThumb {
                var thumbImage = self.thumbImage(for: i)
                var selectedThumbImage = self.selectedThumbImage(for: i)
                if thumbImage && selectedThumbImage {
                    if i == self.currentPage {
                        selectedThumbImage.draw(in: CGRect(x: x, y: (self.frame.size.height - selectedThumbImage.size.height) / 2, width: selectedThumbImage.size.width, height: selectedThumbImage.size.height))
                    }
                    else {
                        thumbImage.draw(in: CGRect(x: x, y: (self.frame.size.height - thumbImage.size.height) / 2, width: thumbImage.size.width, height: thumbImage.size.height))
                    }
                }
            }
        }
    }
    
    func setPageControlStyle(_ style: PageControlStyle) {
        self.pageControlStyle = style
        self.setNeedsDisplay()
    }
    
    override func setCurrentPage(_ page: Int) {
        self.currentPage = page
        self.setNeedsDisplay()
    }
    
    override func setNumberOfPages(_ numOfPages: Int) {
        self.numberOfPages = numOfPages
        self.setNeedsDisplay()
    }
    
    func setThumbImage(_ aThumbImage: UIImage, for index: Int) {
        if self.thumbImageForIndex == nil {
            self.thumbImageForIndex = [AnyHashable: Any]()
        }
        if (aThumbImage != nil) {
            self.thumbImageForIndex[(index)] = aThumbImage
        }
        else {
            self.thumbImageForIndex.removeValueForKey((index))
        }
        self.setNeedsDisplay()
    }
    
    func thumbImage(for index: Int) -> UIImage {
        var aThumbImage = (self.thumbImageForIndex[(index)] as! String)
        if aThumbImage == nil {
            aThumbImage = self.thumbImage
        }
        return aThumbImage
    }
    
    func setSelectedThumbImage(_ aSelectedThumbImage: UIImage, for index: Int) {
        if self.selectedThumbImageForIndex == nil {
            self.selectedThumbImageForIndex = [AnyHashable: Any]()
        }
        if (aSelectedThumbImage != nil) {
            self.selectedThumbImageForIndex[(index)] = aSelectedThumbImage
        }
        else {
            self.selectedThumbImageForIndex.removeValueForKey((index))
        }
        self.setNeedsDisplay()
    }
    
    func selectedThumbImage(for index: Int) -> UIImage {
        var aSelectedThumbImage = (self.selectedThumbImageForIndex[(index)] as! String)
        if aSelectedThumbImage == nil {
            aSelectedThumbImage = self.selectedThumbImage
        }
        return aSelectedThumbImage
    }
}
