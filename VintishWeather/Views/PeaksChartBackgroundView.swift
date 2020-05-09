//
//  PeaksChartBackgroundView.swift
//  Universum
//
//  Created by Vintish Roman on 2/12/19.
//  Copyright © 2019 JellyWorkz. All rights reserved.
//

import UIKit

struct PeaksChartBackgroundViewValue {
    let isVertical:Bool
    let progress:CGFloat
}

class PeaksChartBackgroundView: UIView {

    var chartLinesColor:UIColor = UIColor.gray.withAlphaComponent(0.25)
    var chartLineWidth:CGFloat = 2.0
    var animationDuration:Double = 0.4

    private var verticalLinesLayers:[CAShapeLayer]?
    private var horizontalLinesLayers:[CAShapeLayer]?
    private var verticalFirstExtraLinesLayers:[CAShapeLayer]?
    private var verticalSecondExtraLinesLayers:[CAShapeLayer]?
    private var horizontalFirstExtraLinesLayers:[CAShapeLayer]?
    private var horizontalSecondExtraLinesLayers:[CAShapeLayer]?

    var values:[PeaksChartBackgroundViewValue]? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
                
        super.draw(rect)
        
        guard let values = values, values.count != 0 else {
            layer.sublayers?.removeAll()
            return
        }
        
        if verticalLinesLayers == nil && horizontalLinesLayers == nil {
            
            verticalLinesLayers = Array.init()
            horizontalLinesLayers = Array.init()
            verticalFirstExtraLinesLayers = Array.init()
            verticalSecondExtraLinesLayers = Array.init()
            horizontalFirstExtraLinesLayers = Array.init()
            horizontalSecondExtraLinesLayers = Array.init()
            
            for value in values {
       
                let shapeLayer = getLineShape(rect, value.progress, value.isVertical)
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.strokeColor = chartLinesColor.cgColor
                
                let firstExtraLayer = getLineShape(rect, -value.progress, value.isVertical)
                firstExtraLayer.fillColor = UIColor.clear.cgColor
                firstExtraLayer.strokeColor = chartLinesColor.cgColor

                let secondExtraLayer = getLineShape(rect, 1.0 + value.progress, value.isVertical)
                secondExtraLayer.fillColor = UIColor.clear.cgColor
                secondExtraLayer.strokeColor = chartLinesColor.cgColor
                
                if value.isVertical {
                    verticalLinesLayers?.append(shapeLayer)
                    verticalFirstExtraLinesLayers?.append(firstExtraLayer)
                    verticalSecondExtraLinesLayers?.append(secondExtraLayer)
                } else {
                    horizontalLinesLayers?.append(shapeLayer)
                    horizontalFirstExtraLinesLayers?.append(firstExtraLayer)
                    horizontalSecondExtraLinesLayers?.append(secondExtraLayer)
                }
                
                insetWithAnimation(shapeLayer)
                insetWithAnimation(firstExtraLayer)
                insetWithAnimation(secondExtraLayer)

            }
            
        } else {
            
            guard var verticalLinesLayers = verticalLinesLayers,
                var horizontalLinesLayers = horizontalLinesLayers,
                var verticalFirstExtraLinesLayers = verticalFirstExtraLinesLayers,
                var verticalSecondExtraLinesLayers = verticalSecondExtraLinesLayers,
                var horizontalFirstExtraLinesLayers = horizontalFirstExtraLinesLayers,
                var horizontalSecondExtraLinesLayers = horizontalSecondExtraLinesLayers else {
                    return
            }
            
            //=====================================================================================================
            
            var newVerticalLinesValues:[PeaksChartBackgroundViewValue] = Array.init()
            var newHorizontalLinesValues:[PeaksChartBackgroundViewValue] = Array.init()

            for value in values {
                if value.isVertical {
                    newVerticalLinesValues.append(value)
                } else {
                    newHorizontalLinesValues.append(value)
                }
            }
            
            //=====================================================================================================

            if newVerticalLinesValues.count < verticalLinesLayers.count {
                let difference = verticalLinesLayers.count - newVerticalLinesValues.count
                for _ in 0..<difference {
                    let last1 = verticalLinesLayers.removeLast()
                    removeWithAnimation(last1)
                    let last2 = verticalFirstExtraLinesLayers.removeLast()
                    removeWithAnimation(last2)
                    let last3 = verticalSecondExtraLinesLayers.removeLast()
                    removeWithAnimation(last3)
                }
            }
            
            //=====================================================================================================

            if newHorizontalLinesValues.count < horizontalLinesLayers.count {
                let difference = horizontalLinesLayers.count - newHorizontalLinesValues.count
                for _ in 0..<difference {
                    let last1 = horizontalLinesLayers.removeLast()
                    removeWithAnimation(last1)
                    let last2 = horizontalFirstExtraLinesLayers.removeLast()
                    removeWithAnimation(last2)
                    let last3 = horizontalSecondExtraLinesLayers.removeLast()
                    removeWithAnimation(last3)
                }
            }

            //=====================================================================================================

            for (index, value) in newVerticalLinesValues.enumerated() {
                if index < verticalLinesLayers.count {
                    let shapePath1 = getLinePath(rect, value.progress, value.isVertical)
                    changeWithAnimation(verticalLinesLayers[index], shapePath1)
                    //===
                    let shapePath2 = getLinePath(rect, -value.progress, value.isVertical)
                    changeWithAnimation(verticalFirstExtraLinesLayers[index], shapePath2)
                    //===
                    let shapePath3 = getLinePath(rect, 1.0 + value.progress, value.isVertical)
                    changeWithAnimation(verticalSecondExtraLinesLayers[index], shapePath3)
                } else {
                    let shapeLayer1 = getLineShape(rect, value.progress, value.isVertical)
                    shapeLayer1.fillColor = UIColor.clear.cgColor
                    shapeLayer1.strokeColor = chartLinesColor.cgColor
                    verticalLinesLayers.append(shapeLayer1)
                    insetWithAnimation(shapeLayer1)
                    //===
                    let shapeLayer2 = getLineShape(rect, -value.progress, value.isVertical)
                    shapeLayer2.fillColor = UIColor.clear.cgColor
                    shapeLayer2.strokeColor = chartLinesColor.cgColor
                    verticalFirstExtraLinesLayers.append(shapeLayer2)
                    insetWithAnimation(shapeLayer2)
                    //===
                    let shapeLayer3 = getLineShape(rect, 1.0 + value.progress, value.isVertical)
                    shapeLayer3.fillColor = UIColor.clear.cgColor
                    shapeLayer3.strokeColor = chartLinesColor.cgColor
                    verticalSecondExtraLinesLayers.append(shapeLayer3)
                    insetWithAnimation(shapeLayer3)
                }
            }
            
            //=====================================================================================================

            for (index, value) in newHorizontalLinesValues.enumerated() {
                if index < horizontalLinesLayers.count {
                    let shapePath1 = getLinePath(rect, value.progress, value.isVertical)
                    changeWithAnimation(horizontalLinesLayers[index], shapePath1)
                    //===
                    let shapePath2 = getLinePath(rect, -value.progress, value.isVertical)
                    changeWithAnimation(horizontalFirstExtraLinesLayers[index], shapePath2)
                    //===
                    let shapePath3 = getLinePath(rect, 1.0 + value.progress, value.isVertical)
                    changeWithAnimation(horizontalSecondExtraLinesLayers[index], shapePath3)
                } else {
                    let shapeLayer1 = getLineShape(rect, value.progress, value.isVertical)
                    shapeLayer1.fillColor = UIColor.clear.cgColor
                    shapeLayer1.strokeColor = chartLinesColor.cgColor
                    horizontalLinesLayers.append(shapeLayer1)
                    insetWithAnimation(shapeLayer1)
                    //===
                    let shapeLayer2 = getLineShape(rect, -value.progress, value.isVertical)
                    shapeLayer2.fillColor = UIColor.clear.cgColor
                    shapeLayer2.strokeColor = chartLinesColor.cgColor
                    horizontalFirstExtraLinesLayers.append(shapeLayer2)
                    insetWithAnimation(shapeLayer2)
                    //===
                    let shapeLayer3 = getLineShape(rect, 1.0 + value.progress, value.isVertical)
                    shapeLayer3.fillColor = UIColor.clear.cgColor
                    shapeLayer3.strokeColor = chartLinesColor.cgColor
                    horizontalSecondExtraLinesLayers.append(shapeLayer3)
                    insetWithAnimation(shapeLayer3)
                }
            }
            
            //=====================================================================================================

            self.verticalLinesLayers = verticalLinesLayers
            self.horizontalLinesLayers = horizontalLinesLayers
            self.verticalFirstExtraLinesLayers = verticalFirstExtraLinesLayers
            self.verticalSecondExtraLinesLayers = verticalSecondExtraLinesLayers
            self.horizontalFirstExtraLinesLayers = horizontalFirstExtraLinesLayers
            self.horizontalSecondExtraLinesLayers = horizontalSecondExtraLinesLayers
 
            //=====================================================================================================

        }
        
    }
    
    func changeWithAnimation(_ layer:CAShapeLayer?, _ path:UIBezierPath) {
        
        guard let layer = layer else {
            return
        }
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
            layer.path = path.cgPath
            layer.removeAllAnimations()
        })
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        animation.fromValue = layer.path
        animation.toValue = path.cgPath
        animation.duration = animationDuration
        animation.fillMode = CAMediaTimingFillMode.both
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: nil)
        
        CATransaction.commit()
        
    }
    
    func insetWithAnimation(_ layer:CALayer?) {
        
        guard let layer = layer else {
            return
        }
        
        layer.opacity = 0.0
        self.layer.addSublayer(layer)
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
            layer.opacity = 1.0
            layer.removeAllAnimations()
        })
        
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = animationDuration
        animation.fillMode = CAMediaTimingFillMode.both
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: nil)
        
        CATransaction.commit()
        
    }
    
    func removeWithAnimation(_ layer:CALayer?) {
        
        guard let layer = layer else {
            return
        }
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        })
        
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = animationDuration
        animation.fillMode = CAMediaTimingFillMode.both
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: nil)
        
        CATransaction.commit()
        
    }
    
    func getLineShape(_ rect:CGRect ,_ progress:CGFloat, _ isVertical:Bool) -> CAShapeLayer {
  
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = getLinePath(rect, progress, isVertical).cgPath
        
        return shapeLayer
        
    }
    
    func getLinePath(_ rect:CGRect ,_ progress:CGFloat, _ isVertical:Bool) -> UIBezierPath {

        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: isVertical ? rect.size.width * progress : -(rect.size.width*2),
                                   y: isVertical ? -(rect.size.width*2) : rect.size.height * progress))
        path.addLine(to: CGPoint.init(x: isVertical ? rect.size.width * progress : (rect.size.width*3),
                                      y: isVertical ? (rect.size.height*3) : rect.size.height * progress))
        path.close()
        
        return path
        
    }
    
}
