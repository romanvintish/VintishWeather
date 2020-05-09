//
//  PeaksChartView.swift
//  Universum
//
//  Created by Vintish Roman on 2/12/19.
//  Copyright © 2019 JellyWorkz. All rights reserved.
//

import UIKit

struct PeaksChartViewValue {
    let progress:CGFloat
    let tapHandler:(()->Void)
}

class PeaksChartView: UIView {
    
    var chartGradientFirstColor:UIColor = UIColor.cyan
    var chartGradientSecondColor:UIColor = UIColor.blue
    var chartLineWidth:CGFloat = 3.0
    var animationDuration:Double = 0.4
    var chartIndent:CGFloat = 40.0
    
    private var chartLineLayer:CALayer?
    private var chartPointsLayer:CALayer?
    
    var values:[PeaksChartViewValue]? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var points:[CGPoint] = []
    
    var tapRecognizer: UITapGestureRecognizer?
    
    func addGestureRecognizers() {
        if let tapRecognizer = tapRecognizer {
            removeGestureRecognizer(tapRecognizer)
        }
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        tapRecognizer?.numberOfTouchesRequired = 1
        
        addGestureRecognizer(tapRecognizer!)
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        addGestureRecognizers()
        
        guard let values = values, values.count != 0 else {
            layer.sublayers?.removeAll()
            return
        }
        
        var numberValues:[CGFloat] = Array.init()
        
        for value in values {
            numberValues.append(value.progress)
        }
        
        let graphicRect = CGRect.init(x: chartIndent,
                                      y: chartIndent,
                                      width: rect.size.width - (2*chartIndent),
                                      height: rect.size.height - (2*chartIndent))
        
        let chartRect = rect
        
        let linePath = getPeaksPath(graphicRect, numberValues).cgPath
        let pointPath = getPointsPath(graphicRect, numberValues).cgPath

        if chartLineLayer == nil {
            
            let chartPathLayer = CAShapeLayer()
            chartPathLayer.path = linePath
            chartPathLayer.backgroundColor = UIColor.clear.cgColor
            chartPathLayer.lineJoin = .round
            chartPathLayer.lineCap = .round
            chartPathLayer.lineWidth = chartLineWidth
            chartPathLayer.fillColor = UIColor.clear.cgColor
            chartPathLayer.strokeColor = UIColor.black.cgColor
            chartPathLayer.masksToBounds = false
            chartPathLayer.frame = chartRect
            
            let chartLineLayer = CAGradientLayer()
            chartLineLayer.colors = [chartGradientFirstColor.cgColor, chartGradientSecondColor.cgColor]
            chartLineLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
            chartLineLayer.endPoint = CGPoint.init(x: 1.0, y: 0.5)
            chartLineLayer.mask = chartPathLayer
            chartLineLayer.masksToBounds = false
            chartLineLayer.frame = chartRect
            
            self.layer.addSublayer(chartLineLayer)
            
            self.chartLineLayer = chartLineLayer
            
            let pointsPathLayer = CAShapeLayer()
            pointsPathLayer.path = pointPath
            pointsPathLayer.backgroundColor = UIColor.clear.cgColor
            pointsPathLayer.lineJoin = .round
            pointsPathLayer.lineCap = .round
            pointsPathLayer.lineWidth = chartLineWidth
            pointsPathLayer.fillColor = UIColor.clear.cgColor
            pointsPathLayer.strokeColor = UIColor.black.cgColor
            pointsPathLayer.masksToBounds = false
            pointsPathLayer.frame = chartRect
            
            let chartPointsLayer = CAGradientLayer()
            chartPointsLayer.colors = [chartGradientFirstColor.cgColor, chartGradientSecondColor.cgColor]
            chartPointsLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
            chartPointsLayer.endPoint = CGPoint.init(x: 1.0, y: 0.5)
            chartPointsLayer.mask = pointsPathLayer
            chartPointsLayer.masksToBounds = false
            chartPointsLayer.frame = chartRect
            
            self.layer.addSublayer(chartPointsLayer)
            
            self.chartPointsLayer = chartPointsLayer
            
        } else {

            _ = {
                let animatableLayer = self.chartLineLayer?.mask as? CAShapeLayer

                CATransaction.begin()
                
                CATransaction.setCompletionBlock({
                    animatableLayer?.path = linePath
                    animatableLayer?.removeAllAnimations()
                })
                
                let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
                animation.toValue = linePath
                animation.duration = self.animationDuration
                animation.fillMode = CAMediaTimingFillMode.both
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                animation.isRemovedOnCompletion = false
                
                animatableLayer?.add(animation, forKey: nil)
                
                CATransaction.commit()
            }()
   
            _ = {
                let animatableLayer = self.chartPointsLayer?.mask as? CAShapeLayer

                CATransaction.begin()
                
                CATransaction.setCompletionBlock({
                    animatableLayer?.path = pointPath
                    animatableLayer?.removeAllAnimations()
                })
                
                let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
                animation.toValue = pointPath
                animation.duration = self.animationDuration
                animation.fillMode = CAMediaTimingFillMode.both
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                animation.isRemovedOnCompletion = false
                
                animatableLayer?.add(animation, forKey: nil)
                
                CATransaction.commit()
            }()
            
        }
        
    }
    
    func getPeaksPath(_ rect:CGRect, _ progresses:[CGFloat]) -> UIBezierPath {
                
        guard progresses.count != 0 else {
            return UIBezierPath()
        }
        
        let path = UIBezierPath()

        _ = {
            let point = CGPoint.init(x: rect.origin.x,
                                     y: rect.origin.y + (rect.size.height * (1-progresses[0])))
            path.move(to: point)
        }()
        
        for i in 0..<progresses.count {
            
            let verticalProgress = progresses[i]
            let horizontalProgress = CGFloat(i)/CGFloat(progresses.count-1)
            
            let point = CGPoint.init(x: rect.origin.x + rect.size.width * horizontalProgress,
                                     y: rect.origin.y + rect.size.height * (1-verticalProgress))
            
            path.addLine(to: point)
            
        }
        
        _ = {
            let point = CGPoint.init(x: rect.origin.x + rect.size.width,
                                     y: rect.origin.y + (rect.size.height * (1-progresses[progresses.count-1])))
            
            path.addLine(to: point)
            path.move(to: point)
            
            for _ in 0..<30 {
                path.addLine(to: point)
                path.move(to: point)
            }
        }()
        
        path.close()

        return path
        
    }
    
    func getPointsPath(_ rect:CGRect, _ progresses:[CGFloat]) -> UIBezierPath {
        
        guard progresses.count != 0 else {
            return UIBezierPath()
        }
        
        let path = UIBezierPath()
         
        points = []
        
        for i in 0..<progresses.count {
            let verticalProgress = progresses[i]
            let horizontalProgress = CGFloat(i)/CGFloat(progresses.count-1)
            
            let point = CGPoint.init(x: rect.origin.x + rect.size.width * horizontalProgress,
                                     y: rect.origin.y + rect.size.height * (1-verticalProgress))
            
            path.move(to: point)
            
            path.addArc(withCenter: point,
                        radius: chartLineWidth,
                        startAngle: radiansFromDegrees(0),
                        endAngle: radiansFromDegrees(360),
                        clockwise: true)
            
            points.append(point)
        }
        
        path.close()
        
        return path
        
    }
    
    func midPointForPoints(_ point1:CGPoint, _ point2:CGPoint) -> CGPoint {
        
        return CGPoint.init(x: (point1.x + point2.x)/2, y: (point1.y + point2.y)/2)
        
    }
    
    func controlPointForPoints(_ point1:CGPoint, _ point2:CGPoint) -> CGPoint {
        
        var controlPoint = midPointForPoints(point1, point2)
        
        let diffY = abs(point2.y - controlPoint.y)
        
        if point1.y < point2.y {
            controlPoint.y += diffY
        } else if point1.y > point2.y {
            controlPoint.y -= diffY
        }
        
        return controlPoint
        
    }
    
    func radiansFromDegrees(_ degree:CGFloat)->(CGFloat) {
        
        return (degree * .pi) / CGFloat(180)
        
    }

    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let tapPoint: CGPoint = gestureRecognizer.location(in: self)
        
        for (index, point) in points.enumerated() {
            let widthRange = point.x-30...point.x+30
            let heightRange = point.y-30...point.y+30

            if widthRange.contains(tapPoint.x) && heightRange.contains(tapPoint.y) {
                values?[index].tapHandler()
            }
        }
    }
    
}
