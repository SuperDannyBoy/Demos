//
//  GuideCollectionViewCell.swift
//  LoadingADView
//
//  Created by SuperDanny on 16/3/7.
//  Copyright © 2016年 SuperDanny ( http://SuperDanny.link/ ) ( http://SuperDanny.link/ ). All rights reserved.
//

import UIKit

@objc(GuideCollectionViewCell)

public class GuideCollectionViewCell: UICollectionViewCell {
    var imageView = UIImageView(frame: ScreenBounds)
    var nextBtn = UIButton(frame: CGRect(x: (ScreenWidth-(UIImage(named: "btn_experience")?.size.width)!)/2, y: ScreenHeight-110, width: (UIImage(named: "btn_experience")?.size.width)!, height: (UIImage(named: "btn_experience")?.size.height)!))
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        
        nextBtn.setImage(UIImage(named: "btn_experience"), for: UIControlState.normal)
        nextBtn.isHidden = true
        nextBtn.addTarget(self, action: #selector(GuideCollectionViewCell.nextButtonClick), for: UIControlEvents.touchUpInside)
        contentView.addSubview(nextBtn)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHiddenNextButton(isHidden: Bool) {
        nextBtn.isHidden = isHidden
    }
    
    func nextButtonClick() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GuideViewControllerDidFinish"), object: nil)
    }
}
