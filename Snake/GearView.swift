//
//  GearView.swift
//  Snake
//
//  Created by Michael Snowden on 9/15/14.
//  Copyright (c) 2014 MichaelSnowden. All rights reserved.
//

import UIKit

@IBDesignable
class GearView : UIView {
    
    var gearLayer = CAShapeLayer()
    
    @IBInspectable var numberOfTeeth : UInt = 1 {
        didSet {
            update()
        }
    }
    
    @IBInspectable var borderWidthToWidthRatio : CGFloat = 1 {
        didSet {
            update()
        }
    }
    
    @IBInspectable var innerRadiusToWidthRatio : CGFloat = 1 {
        didSet {
            update()
        }
    }
    
    @IBInspectable var outerRadiusToWidthRatio : CGFloat = 1 {
        didSet {
            update()
        }
    }
    
    @IBInspectable var toothGapInRadians : CGFloat = 1 {
        didSet {
            update()
        }
    }
    
    @IBInspectable var toothWidthToToothGapRatio : CGFloat = 1 {
        didSet {
            update()
        }
    }
    
    @IBInspectable var toothHeightToWidthRatio : CGFloat = 1 {
        didSet {
            update()
        }
    }
    
    func update() {
        let path = UIBezierPath()
        
    }
}
