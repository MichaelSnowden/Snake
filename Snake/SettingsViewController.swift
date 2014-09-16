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
        let colorPickerView = NKOColorPickerView(frame: CGRect(origin: CGPointZero, size: view.frame.size), color: settings.tileColor) { (color : UIColor!) -> Void in
            self.settings.tileColor = color
        }
        
        view.addSubview(colorPickerView)
    }
    
    @IBAction func changeBorderColor(sender: UIButton) {
        let colorPickerView = NKOColorPickerView(frame: CGRect(origin: CGPointZero, size: view.frame.size), color: settings.tileColor) { (color : UIColor!) -> Void in
            self.settings.borderColor = color
        }
        view.addSubview(colorPickerView)
    }
}
