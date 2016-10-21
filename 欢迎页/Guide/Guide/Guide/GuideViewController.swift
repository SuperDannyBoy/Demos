//
//  GuideViewController.swift
//  LoadingADView
//
//  Created by SuperDanny on 16/3/7.
//  Copyright © 2016年 SuperDanny ( http://SuperDanny.link/ ). All rights reserved.
//

import UIKit

//import StyledPageControl

enum ScrollDirection : Int {
    ///水平
    case ScrollHorizontal
    ///垂直
    case ScrollVertical
}

private let iPhone35 = "iphone35"
private let iPhone40 = "iphone40"
private let iPhone47 = "iphone47"
private let iPhone55 = "iphone55"

public let ScreenWidth: CGFloat  = UIScreen.main.bounds.size.width
public let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
public let ScreenBounds: CGRect  = UIScreen.main.bounds

@objc(GuideViewController)

public class GuideViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var scrollType: ScrollDirection = .ScrollHorizontal
    var collectionV: UICollectionView?
    var pageController = StyledPageControl(frame: CGRect(x: 0, y: ScreenHeight-30, width: ScreenWidth, height: 20))
    var guideImagesDic: [String: [String]] =
        [iPhone35 : ["guide_35_1", "guide_35_2", "guide_35_3"],
         iPhone40 : ["guide_40_1", "guide_40_2", "guide_40_3"],
         iPhone47 : ["guide_40_1", "guide_40_2", "guide_40_3"],
         iPhone55 : ["guide_40_1", "guide_40_2", "guide_40_3"]]
    let cellIdentity = "Cell"
    
    init(scrollDirection: ScrollDirection) {
        super.init(nibName: nil, bundle: nil)
        scrollType = scrollDirection
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarHidden(false, with: .none)
        buildCollectionView()
        buildPageController()
    }
    
    // MARK: - 显隐pageController
    func setHiddenPageController(isHidden: Bool) {
        pageController.isHidden = isHidden
    }
    
    // MARK: - Build UI
    func buildCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing      = 0
        layout.itemSize                = ScreenBounds.size
        if scrollType == .ScrollHorizontal {
            layout.scrollDirection = .horizontal
        } else {
            layout.scrollDirection = .vertical
        }
        
        collectionV = UICollectionView(frame: ScreenBounds, collectionViewLayout: layout)
        collectionV!.delegate      = self
        collectionV!.dataSource    = self
        collectionV!.isPagingEnabled = true
        collectionV!.bounces       = false
        collectionV!.showsHorizontalScrollIndicator = false
        collectionV!.showsVerticalScrollIndicator   = false
        collectionV?.register(GuideCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentity)
        self.view.addSubview(collectionV!)
    }
    
    func buildPageController() {
        let arr = guideImagesDic[iPhone35]!;
        pageController.numberOfPages = Int32(arr.count)
        pageController.currentPage = 0
        pageController.coreNormalColor = UIColor(red: 212/255.0, green: 211/255.0, blue: 206/255.0, alpha: 1)
        pageController.coreSelectedColor = UIColor(red: 27/255.0, green: 166/255.0, blue: 231/255.0, alpha: 1)
        pageController.addTarget(self, action: #selector(pageValueChange), for: .valueChanged)
//        pageController.thumbImage = UIImage(named: "point_gray")
//        pageController.selectedThumbImage = UIImage(named: "point_blue")
        view.addSubview(pageController)
    }
    
    func pageValueChange(page: StyledPageControl) {
        var scrollPosition: UICollectionViewScrollPosition = .centeredHorizontally
        if scrollType == .ScrollVertical {
            scrollPosition = .centeredVertically
        }
        collectionV?.scrollToItem(at: IndexPath.init(row: Int(pageController.currentPage), section: 0), at: scrollPosition, animated: true)
    }
    
    //MARK: UICollectionViewDataSource
    @nonobjc public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guideImagesDic[iPhone35]!.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentity, for: indexPath) as! GuideCollectionViewCell
        var keyString: String?
        switch UIDevice.currentDeviceScreenMeasurement() {
        case 3.5:
            keyString = iPhone35
        case 4.0:
            keyString = iPhone40
        case 4.7:
            keyString = iPhone47
        case 5.5:
            keyString = iPhone55
        default:
            keyString = iPhone40
        }
        let dataArr = guideImagesDic[keyString!]!
        cell.image = UIImage(named: dataArr[indexPath.row])
        if indexPath.row == dataArr.count - 1 {
            cell.setHiddenNextButton(isHidden: false)
//            setHiddenPageController(true)
        } else {
            cell.setHiddenNextButton(isHidden: true)
//            setHiddenPageController(false)
        }
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollType == .ScrollHorizontal {
            pageController.currentPage = Int32(scrollView.contentOffset.x / ScreenWidth + 0.5)
        } else {
            pageController.currentPage = Int32(scrollView.contentOffset.y / ScreenHeight + 0.5)
        }
        let arr = guideImagesDic[iPhone35]!;
        if pageController.currentPage == Int32(arr.count - 1) {
            setHiddenPageController(isHidden: true)
        } else {
            setHiddenPageController(isHidden: false)
        }
    }
    
    // MARK: -
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
