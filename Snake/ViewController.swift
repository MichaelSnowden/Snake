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

typealias Index = (i : Int, j : Int)

var gameCenterFeaturesEnabled  = false

@IBDesignable
class ArrowView : UIView {
    var arrow = CAShapeLayer()
    
    @IBInspectable var direction : Int = Direction.Right.toRaw() {
        didSet {
            updateArrow()
        }
    }
    
    func updateArrow() {
        
        var startingPoint : CGPoint
        var toPoint : CGPoint
        var tailWidth : CGFloat = frame.size.width / 2
        var headWidth : CGFloat = tailWidth * 2
        var headLength : CGFloat = frame.size.width / 3
        switch direction {
        case Direction.Right.toRaw() :
            startingPoint = CGPoint(x: 0, y: frame.size.height / 2)
            toPoint = CGPoint(x: frame.size.width, y: frame.size.height / 2)
        case Direction.Up.toRaw() :
            startingPoint = CGPoint(x: frame.size.width / 2, y: 0)
            toPoint = CGPoint(x: frame.size.width / 2, y: frame.size.height)
        case Direction.Left.toRaw() :
            startingPoint = CGPoint(x: frame.size.width, y: frame.size.height / 2)
            toPoint = CGPoint(x: 0, y: frame.size.width / 2)
        case Direction.Down.toRaw():
            startingPoint = CGPoint(x: frame.size.width / 2, y: frame.size.height)
            toPoint = CGPoint(x: frame.size.width / 2, y: 0)
        default :
            return
        }
        arrow.path = UIBezierPath.dqd_bezierPathWithArrowFromPoint(startingPoint, toPoint: toPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength).CGPath
        arrow.removeFromSuperlayer()
        layer.addSublayer(arrow)
    }
}

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
    
    var color : UIColor = UIColor.whiteColor() {
        didSet {
            self.backgroundColor = color
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
    let timeFrameInterval = NSTimeInterval(0.2)
    var gameUpdateTimer : NSTimer?
    var gameStartCountdownTimer : NSTimer?
    
    func createBackground() {
        
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
            tiles.removeAll(keepCapacity: false)
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
        
        if head.i == coin.i && head.j == coin.j {
            spawnCoin()
            let score = scoreLabel.text!.toInt()!
            scoreLabel.text = String(score + 1)
        } else {
            snake.segments.removeAtIndex(0)
        }
        
        snake.segments.append(head)
        for i in 0..<numVerticalTiles {
            for j in 0..<numHorizontalTiles {
                tiles[i][j].backgroundColor = UIColor.lightGrayColor()
            }
        }
        
        // rendering
        for row in tiles {
            for tile in row {
                tile.backgroundColor = tileColor
            }
        }
        for segment in snake.segments {
            tiles[segment.i][segment.j].backgroundColor = UIColor.blackColor()
        }
        tiles[coin.i][coin.j].backgroundColor = UIColor.redColor()
    }
    
    func start(recognizer: UITapGestureRecognizer) {
        removeGestureRecognizer(recognizer)
        start()
    }
    func start() {
        label.hidden = false
        label.text = "2"
        scoreLabel.text = "0"
        snake = Snake()
        direction = .Right
        
        spawnCoin()
        gameStartCountdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "decrementTimer", userInfo: nil, repeats: true)
    }
    
    func decrementTimer() {
        let value = label.text!.toInt()!
        if value > 0 {
            label.text = String(value - 1)
        } else {
            label.hidden = true
            gameStartCountdownTimer!.invalidate()
            gameStartCountdownTimer = nil
            gameUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(timeFrameInterval, target: self, selector: "update", userInfo: nil, repeats: true)
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
                    let alertView = UIAlertView(title: "Score submitted", message: "Your score of \(score) was submitted to GameCenter!", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                } else {
                    println("Failure submitting score D: \(error)")
                    let alertView = UIAlertView(title: "Your score could not be submitted", message: "Your score of \(score) could not be submitted to GameCenter.", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
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
        gameUpdateTimer!.invalidate()
        gameUpdateTimer = nil
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "start:"))
    }
    
    func tryToGoInDirection(newDirection : Direction) {
        
        var head = snake.head
        var neck = snake.neck
        switch newDirection {
        case .Left :
            if !(neck.i == head.i && neck.j == head.j + 1) {
                direction = newDirection
            } else {
                return
            }
        case .Right :
            if !(neck.i == head.i && neck.j == head.j - 1) {
                direction = newDirection
            } else {
                return
            }
        case .Up :
            if !(neck.i == head.i + 1 && neck.j == head.j) {
                direction = newDirection
            } else {
                return
            }
        case .Down :
            if !(neck.i == head.i - 1 && neck.j == head.j) {
                direction = newDirection
            } else {
                return
            }
        }
    }
}

class ViewController : UIViewController {
    
    @IBOutlet weak var scoreLabel: MemeLabel!
    @IBOutlet weak var sceneView: SceneView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.hidden = false
        label.text = "Tap to start!"
        scoreLabel.text = "0"
        
        sceneView.createBackground()
        sceneView.label = label
        sceneView.scoreLabel = scoreLabel
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "start:"))
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneView.createBackground()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}
