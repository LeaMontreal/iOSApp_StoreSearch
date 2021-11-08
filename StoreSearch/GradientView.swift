//
//  GradientView.swift
//  StoreSearch
//
//  Created by user206341 on 11/8/21.
//

import Foundation
import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDocoder: NSCoder) {
        super.init(coder: aDocoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        
        let trait = UITraitCollection.current
        let color: CGFloat = trait.userInterfaceStyle == .light ? 0.314 : 1
        
        let colorComponents: [CGFloat] = [color, color, color, 0.2,
                                          color, color, color, 0.4,
                                          color, color, color, 0.6,
                                          color, color, color, 1]
        let locations: [CGFloat] = [0, 0.5, 0.75, 1]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // prepare CGGradient object
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComponents, locations: locations, count: 4)
        
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        let radius = max(x, y)
        
        // draw radial gradient
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
}
