//
//  ViewController.swift
//  Snake
//
//  Created by Michael Snowden on 9/15/14.
//  Copyright (c) 2014 MichaelSnowden. All rights reserved.
//

import UIKit
import GameKit

enum Direction : Int {
    case Right
    case Up
    case Left
    case Down
}

enum Difficulty {
    case Easy
    case Medium
    case Hard
}

typealias Index = (i : Int, j : Int)
typealias Settings = (difficulty: Difficulty, sound: Bool, borderWidth: CGFloat, tileInset: CGFloat, cornerRadius: CGFloat, tileColor: UIColor, borderColor: UIColor)

var gameCenterFeaturesEnabled  = false

class Snake {
    var head : Index {
        get { return segments.last! }
        set { segments[segments.count - 1] = head }
    }
    var neck : Index {
        get { return segments[segments.count - 2] }
        set { segments[segments.count - 2] = neck }
    }
    var tail : Index {
        get { return segments.first! }
        set { segments[0] = tail }
    }
    var segments : [Index]! = [(0, 0), (0, 1), (0, 2)]
}

@IBDesignable
class SceneView : UIView {
    
    weak var label : UILabel!
    weak var scoreLabel : UILabel!
    @IBInspectable var cornerRadius : CGFloat = CGFloat(5) {
        didSet {
            for row in tiles {
                for tile in row {
                    tile.layer.cornerRadius = cornerRadius
                }
            }
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = CGFloat(5) {
        didSet {
            for row in tiles {
                for tile in row {
                    tile.layer.borderWidth = borderWidth
                }
            }
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.blackColor() {
        didSet {
            for row in tiles {
                for tile in row {
                    tile.layer.borderColor = borderColor.CGColor
                }
            }
        }
    }
    
    @IBInspectable var tileInset : CGFloat = CGFloat(5) {
        didSet {
            createBackground()
        }
    }
    
    @IBInspectable var tileColor : UIColor = UIColor.lightGrayColor() {
        didSet {
            for row in tiles {
                for tile in row {
                    tile.backgroundColor = tileColor
                }
            }
        }
    }
    @IBInspectable var numHorizontalTiles : Int = 20 {
        didSet {
            createBackground()
        }
    }
    
    var settings : Settings = (difficulty: Difficulty.Easy, sound: true, borderWidth: CGFloat(5), tileInset: CGFloat(5), cornerRadius: CGFloat(5), tileColor: UIColor.clearColor(), borderColor: UIColor.blackColor()) {
        didSet {
            self.borderWidth = settings.borderWidth
            self.tileColor = settings.tileColor
            self.borderColor = settings.borderColor
            self.cornerRadius = settings.cornerRadius
            self.tileInset = settings.tileInset
        }
    }
    var numVerticalTiles   : Int!
    
    var direction : Direction = .Right
    var tiles = Array<Array<UIView>>()
    
    var snake = Snake()
    var coin : Index! = (0, 0) {
        didSet {
            tiles[coin.i][coin.j].backgroundColor = UIColor.redColor()
        }
    }
    var tileSideLength : CGFloat!
    var gameUpdateTimer : NSTimer?
    var gameStartCountdownTimer : NSTimer?
    var tapGestureRecognizer : UITapGestureRecognizer?
    
    func repaintCharacters() {
        tiles[coin.i][coin.j].backgroundColor = UIColor.redColor()
        for segment in snake.segments {
            tiles[segment.i][segment.j].backgroundColor = UIColor.blackColor()
        }
    }
    
    func createBackground() {
        println("Creating background")
        func updateSizes() {
            numVerticalTiles = numHorizontalTiles
            tileSideLength = (frame.size.width - tileInset * CGFloat(numHorizontalTiles)) / CGFloat(numHorizontalTiles)
            let tileSize = CGSize(width: tileSideLength, height: tileSideLength)
        }
        updateSizes()
        
        func removeOldTiles() {
            for row in tiles {
                for tile in row {
                    tile.removeFromSuperview()
                }
            }
            tiles.removeAll(keepCapacity: true)
        }
        removeOldTiles()
        
        
        func addTiles() {
            var rect = CGRect(origin: CGPointZero, size: CGSize(width: tileSideLength, height: tileSideLength))
            
            for i in 0..<numVerticalTiles {
                var row = [UIView]()
                rect.origin.y = CGFloat(i) * (tileSideLength + tileInset)
                for j in 0..<numHorizontalTiles {
                    rect.origin.x = CGFloat(j) * (tileSideLength + tileInset)
                    
                    let view = UIView(frame: rect)
                    view.backgroundColor = tileColor
                    view.layer.cornerRadius = cornerRadius
                    view.layer.borderColor = borderColor.CGColor
                    view.layer.borderWidth = borderWidth
                    addSubview(view)
                    
                    row.append(view)
                }
                tiles.append(row)
            }
        }
        addTiles()
        
        if label != nil {
            bringSubviewToFront(label)
        }
    }
    
    func spawnCoin() {
        var validSpots = Array<Index>()
        for i in 0..<numVerticalTiles {
            for j in 0..<numHorizontalTiles {
                var spotIsValid = true
                for segment in snake.segments {
                    if i == segment.i && j == segment.j {
                        spotIsValid = false
                        break
                    }
                }
                if i == coin.i && j == coin.j {
                    spotIsValid = false
                }
                if spotIsValid {
                    validSpots.append((i, j))
                }
            }
        }
        
        let randomIndex = arc4random_uniform(UInt32(validSpots.count))
        let randomValidSpot = validSpots[Int(randomIndex)]
        coin = randomValidSpot
    }

    func update() {
        var head = snake.head
        var neck = snake.neck
        switch direction {
        case .Left :
            --head.j
        case .Right :
            ++head.j
        case .Up :
            --head.i
        case .Down :
            ++head.i
        }
        
        // 1. We hit a wall -> gameOver
        if head.i < 0 || head.i == numVerticalTiles || head.j < 0 || head.j == numHorizontalTiles {
            gameOver()
            return
        }
        
        // 2. We hit ourself -> gameOver
        for segment in snake.segments {
            if segment.i == head.i && segment.j == head.j {
                gameOver()
                return
            }
        }
        
        tiles[head.i][head.j].backgroundColor = UIColor.blackColor()
        
        if head.i == coin.i && head.j == coin.j {
            spawnCoin()
            let score = scoreLabel.text!.toInt()!
            scoreLabel.text = String(score + 1)
        } else {
            let tail = snake.segments[0]
            tiles[tail.i][tail.j].backgroundColor = settings.tileColor
            snake.segments.removeAtIndex(0)
        }
        
        snake.segments.append(head)
    }
    
    func start(recognizer: UITapGestureRecognizer) {
        removeGestureRecognizer(recognizer)
        start()
    }
    func start() {
        createBackground()
        label.hidden = false
        label.text = "2"
        scoreLabel.text = "0"
        snake = Snake()
        for segment in snake.segments {
            tiles[segment.i][segment.j].backgroundColor = UIColor.blackColor()
        }
        direction = .Right
        
        spawnCoin()
        
        gameStartCountdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "decrementTimer", userInfo: nil, repeats: true)
    }
    
    func pause() {
        gameUpdateTimer?.invalidate()
        gameUpdateTimer = nil
    }
    
    func resume() {
        label.hidden = false
        label.text = "2"
        gameStartCountdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "decrementTimer", userInfo: nil, repeats: true)
    }
    
    func decrementTimer() {
        let value = label.text!.toInt()!
        if value > 0 {
            label.text = String(value - 1)
        } else {
            var difficultyValue : CGFloat
            
            switch settings.difficulty {
            case .Easy:
                difficultyValue = 1.0
            case .Medium:
                difficultyValue = 2.0
            case .Hard:
                difficultyValue = 3.0
            }
            
            label.hidden = true
            gameStartCountdownTimer!.invalidate()
            gameStartCountdownTimer = nil
            gameUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2 / difficultyValue), target: self, selector: "update", userInfo: nil, repeats: true)
        }
    }

    func gameOver() {
        let score = scoreLabel.text!.toInt()!
        if (gameCenterFeaturesEnabled) {
            
            let player = GKLocalPlayer.localPlayer()
            let gkScore = GKScore(leaderboardIdentifier: "com.MichaelSnowden.JustSnake.HighScores", player: player)
            gkScore.value = Int64(score)
            
            GKScore.reportScores([gkScore], withCompletionHandler: { (error : NSError!) -> Void in
                if (error == nil) {
                    println("Success submitting score :D")
                } else {
                    println("Failure submitting score D: \(error)")
                }
            })
            
        } else {
            let highScore = NSUserDefaults.standardUserDefaults().integerForKey("com.MichaelSnowden.JustSnake.highScore")
            if score > highScore {
                NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "com.MichaelSnowden.JustSnake.highScore")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            
        }
        
        label.hidden = false
        label.text = "Game Over!\nTap to restart"
        gameUpdateTimer?.invalidate()
        gameUpdateTimer = nil
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "start:")
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func tryToGoInDirection(newDirection : Direction) {
        
        var head = snake.head
        var neck = snake.neck
        switch newDirection {
        case .Left :
            if !(neck.i == head.i && neck.j == head.j - 1) {
                direction = newDirection
            } else {
                return
            }
        case .Right :
            if !(neck.i == head.i && neck.j == head.j + 1) {
                direction = newDirection
            } else {
                return
            }
        case .Up :
            if !(neck.i == head.i - 1 && neck.j == head.j) {
                direction = newDirection
            } else {
                return
            }
        case .Down :
            if !(neck.i == head.i + 1 && neck.j == head.j) {
                direction = newDirection
            } else {
                return
            }
        }
    }
}

class ViewController : UIViewController, SettingsViewControllerDelegate {
    
    @IBOutlet weak var scoreLabel: MemeLabel!
    @IBOutlet weak var sceneView: SceneView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var gearView: GearView!
    var tapGestureRecognizer : UITapGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.hidden = false
        label.text = "Tap to start!"
        scoreLabel.text = "0"
        
        sceneView.label = label
        sceneView.scoreLabel = scoreLabel
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "start:")
        sceneView.addGestureRecognizer(tapGestureRecognizer!)
        
        weak var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer!.authenticateHandler = { (viewController : UIViewController?, error : NSError?) -> Void in
            
            if localPlayer!.authenticated {
                // enable game center
                gameCenterFeaturesEnabled = true
            } else if let vc = viewController {
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                // disable game center
                gameCenterFeaturesEnabled = false
            }
        }
        
        gearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "goToSettings"))
    }
    
    func goToSettings() {
        // The game is running
        if sceneView.gameUpdateTimer != nil {
            sceneView.pause()
        }
        else if sceneView.gameStartCountdownTimer != nil {  // The game is counting down
            sceneView.gameStartCountdownTimer!.invalidate()
            sceneView.gameStartCountdownTimer = nil
        }
        else {
            if tapGestureRecognizer?.view != nil { // Game hasn't started
                sceneView.removeGestureRecognizer(tapGestureRecognizer!)
            }
            else if sceneView.tapGestureRecognizer?.view != nil {   // We're at game over
                sceneView.label.hidden = true
                sceneView.removeGestureRecognizer(sceneView.tapGestureRecognizer!)
            }
        }
        self.performSegueWithIdentifier("goToSettings", sender: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            var settings = self.sceneView.settings
            settings.borderWidth = self.sceneView.borderWidth
            settings.tileColor = self.sceneView.tileColor
            settings.borderColor = self.sceneView.borderColor
            settings.tileInset = self.sceneView.tileInset
            self.sceneView.settings = settings
        }
    }

    func start(recognizer : UITapGestureRecognizer) {
        sceneView.removeGestureRecognizer(recognizer)
        sceneView.start()
    }
    
    @IBAction func goRight(sender: UISwipeGestureRecognizer) {
        sceneView.tryToGoInDirection(.Right)
    }
    @IBAction func goUp(sender: UISwipeGestureRecognizer) {
        sceneView.tryToGoInDirection(.Up)
    }
    @IBAction func goLeft(sender: UISwipeGestureRecognizer) {
        sceneView.tryToGoInDirection(.Left)
    }
    @IBAction func goDown(sender: UISwipeGestureRecognizer) {
        sceneView.tryToGoInDirection(.Down)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToSettings" {
            let settingsViewController = segue.destinationViewController as SettingsViewController
            settingsViewController.delegate = self
            settingsViewController.settings = sceneView.settings
        }
    }
    
    // MARK: SettingsViewControllerDelegate
    func settingsViewController(settingsViewController: SettingsViewController, didFinishWithSettings settings : Settings, shouldRestartGame : Bool) {
        
        sceneView.settings = settings
        sceneView.createBackground()
        sceneView.repaintCharacters()
        
        if shouldRestartGame == true {
            sceneView.start()
        } else {
            if sceneView.tapGestureRecognizer?.view != nil {    // We're at game over
                sceneView.start()
            } else {
                sceneView.resume()
            }
        }
    }
}
