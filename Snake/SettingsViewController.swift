//
//  SettingsViewController.swift
//  Snake
//
//  Created by Michael Snowden on 9/15/14.
//  Copyright (c) 2014 MichaelSnowden. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func settingsViewController(settingsViewController : SettingsViewController, didFinishWithSettings : Settings)
}

class SettingsViewController : UIViewController {
    
    var settings : Settings!

    @IBOutlet weak var difficultySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var soundSwitch: UISwitch!
    
    @IBOutlet weak var borderWidthSlider: UISlider!
    
    @IBOutlet weak var tileInsetSlider: UISlider!
    
    @IBOutlet weak var tileColorButton: UIButton!
    
    @IBOutlet weak var backgroundColorButton: UIButton!
    
    @IBAction func changeTileColor(sender: UIButton) {
        let colorPickerView = NKOColorPickerView(frame: CGRect(origin: CGPointZero, size: CGSize(width: view.frame.size.width, height: view.frame.size.height - 50)), color: settings.tileColor) { (color : UIColor!) -> Void in
            self.settings.tileColor = color
            self.tileColorButton.backgroundColor = color
        }
        addDoneButtonToColorPickerView(colorPickerView)
    }
    
    @IBAction func changeBorderColor(sender: UIButton) {
        let colorPickerView = NKOColorPickerView(frame: CGRect(origin: CGPointZero, size: CGSize(width: view.frame.size.width, height: view.frame.size.height - 50)), color: settings.tileColor) { (color : UIColor!) -> Void in
            self.settings.borderColor = color
            self.backgroundColorButton.backgroundColor = color
        }
        addDoneButtonToColorPickerView(colorPickerView)
    }
    
    func addDoneButtonToColorPickerView(colorPickerView : NKOColorPickerView) {
        let buttonSize = CGSize(width: 100, height: 50)
        let point = CGPoint(x: view.frame.size.width / 2 - buttonSize.width / 2, y: view.frame.size.height - 50)
        let button = UIButton(frame: CGRect(origin: point, size: buttonSize))
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.blackColor()
        button.addTarget(colorPickerView, action: "removeFromSuperview", forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(button, action: "removeFromSuperview", forControlEvents: UIControlEvents.TouchUpInside)
        button.setTitle("Done", forState: UIControlState.Normal)
        
        view.addSubview(colorPickerView)
        view.addSubview(button)
    }
}
