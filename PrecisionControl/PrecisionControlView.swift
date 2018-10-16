//
//  PrecisionControlView.swift
//  PrecisionControl
//
//  Created by Priyanka Herur on 10/15/18.
//  Copyright © 2018 Priyanka Herur. All rights reserved.
//

import UIKit
fileprivate let TextRulerFont               = UIFont.systemFont(ofSize: 11)
fileprivate let RulerLineColor              = UIColor.gray
fileprivate let RulerGap                    = 6
fileprivate let RulerLong                   = 40
fileprivate let RulerShort                  = 30
fileprivate let IndicatorHeight:CGFloat     = 12.0
fileprivate let CollectionWidth             = 70
fileprivate let TextColorWhiteAlpha:CGFloat = 1.0

class PrecisionControlView: UIView {
    var scrollByHand = true
    var stepNum = 0
    
    private var redLine:UIImageView?
    private var fileRealValue:Float = 0.0
    var minValue:Float = 0.0
    var maxValue:Float = 0.0
    var step:Float = 0.0
    var interpolateNum:Int = 0
    static var IndicatorPosition: Float = 0.0
    var currentVC:UIViewController?
    
    init(frame: CGRect,
         pcMinValue:Float,
         pcMaxValue:Float,
         pcIncrement:Float,
         pcInterpolationNum:Int,
         viewcontroller:UIViewController) {
        super.init(frame: frame)
        minValue = pcMinValue
        maxValue = pcMaxValue
        interpolateNum = pcInterpolationNum
        step = pcIncrement
        stepNum = Int((pcMaxValue - pcMinValue)/step)/interpolateNum
        currentVC = viewcontroller
        PrecisionControlView.IndicatorPosition = Float(frame.height)
        self.backgroundColor = UIColor.white
        
        valueView.frame = CGRect.init(x: self.frame.maxX - 50, y: self.bounds.size.height/2-60, width: 40, height: 80)
        
        indicatorView.frame = CGRect.init(x: self.frame.minX, y: self.frame.midY - (IndicatorHeight/2), width: self.frame.width, height: CGFloat(IndicatorHeight))

        self.addSubview(self.collectionView)
        self.addSubview(self.indicatorView)
        self.addSubview(self.valueView)
        
        self.collectionView.frame = CGRect.init(x: 0, y: 0, width: CGFloat(CollectionWidth) , height: self.bounds.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var valueView: UITextField = {[unowned self] in
        let valueView = UITextField()
        valueView.isUserInteractionEnabled  = true
        return valueView
    }()
    
    lazy var collectionView: UICollectionView = {[unowned self]in
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView:UICollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: CGFloat(CollectionWidth), height:  self.bounds.size.height), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.green
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "headCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "footerCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "midCell")
        
        return collectionView
    }()

    lazy var indicatorView: IndicatorView = {
        let indicatorView = IndicatorView()
        indicatorView.backgroundColor = UIColor.clear
        return indicatorView
    }()
    
    @objc fileprivate func didChangeCollectionValue() {
        let textFieldValue = Float(valueView.text!)
        if (textFieldValue!-minValue)>=0 {
            self.setRealValueAndAnimated(realValue: ((textFieldValue!-minValue)/step), animated: true)
        }
    }
    
    @objc fileprivate func setRealValueAndAnimated(realValue:Float,animated:Bool){
        fileRealValue = realValue
        valueView.text = "\(fileRealValue*step+minValue)"
        collectionView.setContentOffset(CGPoint.init(x: 0, y: Int(realValue)*RulerGap), animated: animated)
    }
    
    func setDefaultValueAndAnimated(defaultValue:Float,animated:Bool){
        fileRealValue = defaultValue
        valueView.text = "\(defaultValue)"
        collectionView.setContentOffset(CGPoint.init(x: 0, y: Int((defaultValue-minValue)/step) * RulerGap), animated: animated)
    }
    
}

//MARK: Drawing the indicator to show the current value
class IndicatorView: UIView {
    override func draw(_ rect: CGRect) {
        UIColor.clear.set()
        UIRectFill(self.bounds)
        let line = UIBezierPath()
        let halfHeight = IndicatorHeight/2
        line.move(to: CGPoint(x: self.bounds.origin.x + halfHeight, y: self.bounds.origin.y + halfHeight))
        line.addLine(to: CGPoint(x: self.bounds.origin.x + self.bounds.width - halfHeight, y: self.bounds.origin.y + halfHeight))
        line.lineWidth = 5
        line.close()
        line.lineJoinStyle = .round
        line.lineCapStyle = .round
        UIColor.black.withAlphaComponent(0.4).setStroke()
        line.stroke()
    }
}

class SubControlsView: UIView {
    var minValue:Float = 0.0
    var maxValue:Float = 0.0
    var unit:String = ""
    var step:Float = 0.0
    var interpolationNum = 0
    override func draw(_ rect: CGRect) {
        let startX:CGFloat  = 0
        let lineCenterX     = CGFloat(RulerGap)
        let shortLineY      = rect.size.width - CGFloat(RulerLong)
        let longLineY       = rect.size.width - CGFloat(RulerShort)
        let topY:CGFloat    = 0
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1)
        context?.setLineCap(CGLineCap.butt)
        context?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        for i in 0...interpolationNum {
            context?.move(to: CGPoint.init(x: topY, y: startX+lineCenterX*CGFloat(i)))
            if i%interpolationNum == 0 {
                let num = Float(i)*step+minValue
                var numStr = "\(num)"
                if num > 1000000 {
                    numStr = "\(num/10000)"
                }
                let attribute:Dictionary = [NSAttributedString.Key.font:TextRulerFont,NSAttributedString.Key.foregroundColor:UIColor.init(white: TextColorWhiteAlpha, alpha: 1.0)]
                
                let height = numStr.boundingRect(
                    with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                    attributes: attribute,context: nil).size.height
                numStr.draw(in: CGRect.init(x: longLineY+10, y: startX+lineCenterX*CGFloat(i)-height/2 , width: 14, height: height), withAttributes: attribute)
                context!.addLine(to: CGPoint.init(x: longLineY, y:  startX+lineCenterX*CGFloat(i)))
            }else{
                context!.addLine(to: CGPoint.init(x: shortLineY , y: startX+lineCenterX*CGFloat(i)))
            }
            context!.strokePath()
            
        }
    }
}

//MARK: SubControls Header View (to push it to the middle)
class SubControlsHeaderView: UIView {
    var headerMinValue = 0
    override func draw(_ rect: CGRect) {
        let longLineX = rect.size.width - CGFloat(RulerShort)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context?.setLineWidth(1.0)
        context?.setLineCap(CGLineCap.butt)
        
        context?.move(to: CGPoint.init(x: 0, y: rect.size.height))
        var numStr:NSString = "\(headerMinValue)" as NSString
        if headerMinValue > 1000000 {
            numStr = "\(headerMinValue/10000)" as NSString
        }
        let attribute:Dictionary = [NSAttributedString.Key.font:TextRulerFont,NSAttributedString.Key.foregroundColor:UIColor.init(white: TextColorWhiteAlpha, alpha: 1.0)]
        let height = numStr.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions(rawValue: 0), attributes: attribute, context: nil).size.height
        numStr.draw(in: CGRect.init(x: longLineX+10, y: rect.size.height-height/2 , width: 14, height: height), withAttributes: attribute)
        context?.addLine(to: CGPoint.init(x: longLineX, y: rect.size.height))
        context?.strokePath()
    }
}

//MARK: SubControls Header View (to make more space at the end)
class SubControlsFooterView: UIView {
    var footerMaxValue = 0
    var footerUnit = ""
    
    override func draw(_ rect: CGRect) {
        let longLineX = Int(rect.size.width) - RulerShort
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context?.setLineWidth(1.0)
        context?.setLineCap(CGLineCap.butt)
        context?.move(to: CGPoint.init(x: 0, y: 0))
        var numStr:NSString = "\(footerMaxValue)" as NSString
        if footerMaxValue > 1000000 {
            numStr = "\(footerMaxValue/10000)" as NSString
        }
        let attribute:Dictionary = [NSAttributedString.Key.font:TextRulerFont,NSAttributedString.Key.foregroundColor:UIColor.init(white: TextColorWhiteAlpha, alpha: 1.0)]
        let height = numStr.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions(rawValue: 0), attributes: attribute, context: nil).size.height
        numStr.draw(in: CGRect.init(x: CGFloat(longLineX+10), y: 0-height/2 , width: CGFloat(14), height: height), withAttributes: attribute)
        context?.addLine(to: CGPoint.init(x: longLineX, y: 0))
        context?.strokePath()
    }
}


extension PrecisionControlView:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2+stepNum
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell:UICollectionViewCell       = collectionView.dequeueReusableCell(withReuseIdentifier: "headCell", for: indexPath)
            var headerView:SubControlsHeaderView?   = cell.contentView.viewWithTag(1000) as? SubControlsHeaderView
            
            if headerView == nil {
                headerView = SubControlsHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: CollectionWidth, height:  Int(self.bounds.height / 2)))
                headerView!.backgroundColor  = UIColor.blue
                headerView!.headerMinValue   = Int(minValue)
                headerView!.tag              = 1000
                cell.contentView.addSubview(headerView!)
            }
            return cell
        } else
            if indexPath.item == (stepNum + 1) {
                let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "footerCell", for: indexPath)
                var footerView:SubControlsFooterView? = cell.contentView.viewWithTag(1001) as? SubControlsFooterView
                if footerView == nil {
                    footerView = SubControlsFooterView.init(frame: CGRect.init(x: 0, y: 0, width: CollectionWidth , height: Int(self.bounds.height / 2)))
                    footerView!.backgroundColor  = UIColor.green
                    footerView!.footerMaxValue   = Int(maxValue)
                    footerView!.tag              = 1001
                    cell.contentView.addSubview(footerView!)
                }
                return cell
            }else
            {
                let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "midCell", for: indexPath)
                var rulerView:SubControlsView? = cell.contentView.viewWithTag(1002) as? SubControlsView
                if rulerView == nil {
                    rulerView = SubControlsView.init(frame: CGRect.init(x: 0, y: 0, width: CollectionWidth, height:  RulerGap*interpolateNum))
                    rulerView!.backgroundColor   = UIColor.clear
                    rulerView!.step              = step
                    rulerView!.tag               = 1002
                    rulerView!.interpolationNum     = interpolateNum
                    cell.contentView.addSubview(rulerView!)
                }
                
                rulerView?.backgroundColor = UIColor.gray
                rulerView!.minValue = step*Float((indexPath.item-1))*Float(interpolateNum)+minValue
                rulerView!.maxValue = step*Float(indexPath.item)*Float(interpolateNum)
                rulerView!.setNeedsDisplay()
                
                return cell
        }
    }
}

extension PrecisionControlView:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = Int(scrollView.contentOffset.y)/RulerGap
        let totalValue = Float(value)*step+minValue
        if scrollByHand {
            if totalValue>=maxValue {
                valueView.text = "\(maxValue)"
            }else if totalValue <= minValue {
                valueView.text = "\(minValue)"
            }else{
                valueView.text = "\(Float(value)*step+minValue)"
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.setRealValueAndAnimated(realValue: Float(scrollView.contentOffset.y)/Float(RulerGap), animated: true)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.setRealValueAndAnimated(realValue: Float(scrollView.contentOffset.y)/Float(RulerGap), animated: true)
    }
}

extension PrecisionControlView:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == stepNum + 1 {
            return CGSize(width: CollectionWidth, height: Int(self.frame.size.height/2))
        }
        return CGSize(width: CollectionWidth, height: RulerGap*interpolateNum)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
