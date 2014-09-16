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
    @IBInspectable var cornerRadius : CGFloat = CGFloat(0) {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = CGFloat(0) {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
}
