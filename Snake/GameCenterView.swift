//
//  GameCenterView.swift
//  Snake
//
//  Created by Michael Snowden on 9/15/14.
//  Copyright (c) 2014 MichaelSnowden. All rights reserved.
//

import Foundation
import GameKit

@IBDesignable
class GameCenterView : UIView, GKGameCenterControllerDelegate {
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        let rootViewController = UIApplication.sharedApplication().keyWindow.rootViewController!
        rootViewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    // MARK: GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
