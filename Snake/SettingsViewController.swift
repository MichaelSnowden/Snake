//
//  SettingsViewController.swift
//  Snake
//
//  Created by Michael Snowden on 9/15/14.
//  Copyright (c) 2014 MichaelSnowden. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func settingsViewController(settingsViewController : SettingsViewController, didFinishWithSettings settings : Settings, shouldRestartGame : Bool)
}

class SettingsViewController : UIViewController, UIAlertViewDelegate {
    
    var delegate : SettingsViewControllerDelegate!
    var settings : Settings!
    var initialDifficulty : Difficulty!

    @IBOutlet weak var difficultySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var soundSwitch: UISwitch!
    
    @IBOutlet weak var borderWidthSlider: UISlider!
    
    @IBOutlet weak var tileInsetSlider: UISlider!
    
    @IBOutlet weak var cornerRadiusSlider: UISlider!
    
    @IBOutlet weak var tileColorButton: UIButton!
    
    @IBOutlet weak var backgroundColorButton: UIButton!
    
    override func viewDidLoad() {
        initialDifficulty = settings.difficulty
        tileColorButton.backgroundColor = settings.tileColor
        backgroundColorButton.backgroundColor = settings.borderColor
        soundSwitch.setOn(settings.sound, animated: false)
        borderWidthSlider.minimumValue = 0
        borderWidthSlider.maximumValue = 10
        borderWidthSlider.value = Float(settings.borderWidth)
        
        tileInsetSlider.minimumValue = 0
        tileInsetSlider.maximumValue = 15
        tileInsetSlider.value = Float(settings.tileInset)
        
        cornerRadiusSlider.minimumValue = 0
        cornerRadiusSlider.maximumValue = 15
        cornerRadiusSlider.value = Float(settings.cornerRadius)
        
        tileColorButton.layer.cornerRadius = 5
        backgroundColorButton.layer.cornerRadius = 5
    }
    
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
    
    @IBAction func done(sender: UIButton) {
        settings.sound = soundSwitch.on
        
        settings.borderWidth = CGFloat(borderWidthSlider.value)
        
        settings.tileInset = CGFloat(tileInsetSlider.value)
        
        settings.cornerRadius = CGFloat(cornerRadiusSlider.value)
        
        switch difficultySegmentedControl.selectedSegmentIndex {
        case 0:
            settings.difficulty = .Easy
        case 1:
            settings.difficulty = .Medium
        case 2:
            settings.difficulty = .Hard
        default:
            settings.difficulty = .Easy
        }
        
        if initialDifficulty != settings.difficulty {
            let alertView = UIAlertView(title: "Difficulty Changed!", message: "Changing the difficuly will cause the game to restart. Are you sure you wish to do this?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
            alertView.show()
        } else {
            delegate.settingsViewController(self, didFinishWithSettings: settings, shouldRestartGame: false)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        println("He selected yes")
        
        delegate.settingsViewController(self, didFinishWithSettings: settings, shouldRestartGame: true)
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func alertViewCancel(alertView: UIAlertView) {
        println("He selected no")
        
        settings.difficulty = initialDifficulty
        
        delegate.settingsViewController(self, didFinishWithSettings: settings, shouldRestartGame: false)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
