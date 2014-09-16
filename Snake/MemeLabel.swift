//
//  MemeLabel.swift
//  PopOut
//
//  Created by Michael Snowden on 9/12/14.
//  Copyright (c) 2014 MichaelSnowden. All rights reserved.
//

import UIKit

class MemeLabel : UILabel {
    
    override func drawTextInRect(rect: CGRect) {
        let shadowOffset = self.shadowOffset
        
        let c = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(c, 10)
        CGContextSetLineJoin(c, kCGLineJoinRound)
        
        CGContextSetTextDrawingMode(c, kCGTextStroke)
        self.textColor = UIColor.blackColor()
        super.drawTextInRect(rect)
        
        CGContextSetTextDrawingMode(c, kCGTextFill)
        
        self.textColor = UIColor.whiteColor()
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawTextInRect(rect)
        
        self.shadowOffset = shadowOffset
    }
}
