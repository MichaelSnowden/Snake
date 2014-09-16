//
//  ViewController.swift
//  Snake
//
//  Created by Michael Snowden on 9/15/14.
//  Copyright (c) 2014 MichaelSnowden. All rights reserved.
//

import UIKit

enum Direction : Int {
    case Right
    case Up
    case Left
    case Down
}

typealias Index = (i : Int, j : Int)

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
    var segments : [Index]! = [(i: 3, j: 3), (i: 3, j: 4), (i: 3, j: 5)]
}

@IBDesignable
class SceneView : UIView {
    
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
    
    let snake = Snake()
    var coin : Index! {
        didSet {
            tiles[coin.i][coin.j].backgroundColor = UIColor.redColor()
        }
    }
    var tileSideLength : CGFloat!
    let timeFrameInterval = NSTimeInterval(0.1)
    var gameUpdateTimer : NSTimer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coin = (3, 3)
        gameUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(timeFrameInterval, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
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
                for j in 0..<numHorizontalTiles {
                    
                    let view = UIView(frame: rect)
                    view.backgroundColor = UIColor.redColor()
                    view.layer.cornerRadius = cornerRadius
                    view.layer.borderColor = borderColor.CGColor
                    view.layer.borderWidth = borderWidth
                    addSubview(view)
                    
                    rect.origin.x = CGFloat(j) * (tileSideLength + tileInset)
                    row.append(view)
                }
                rect.origin.y = CGFloat(i) * (tileSideLength + tileInset)
                tiles.append(row)
            }
        }
        addTiles()
    }


    func update() {
        // Four distinct cases, in order of priority
        // 1. We hit a wall
        // 2. We hit ourself
        // 3. We hit a coin
        // 4. We didn't hit anything
        
        // Move the head forward one
        var head = snake.head
        var neck = snake.neck
        switch direction {
        case .Left :
            --head.j
        case .Right :
            ++head.j
        case .Up :
            ++head.i
        case .Down :
            --head.i
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
            let randI = Int(arc4random_uniform(UInt32(numVerticalTiles)))
            let randJ = Int(arc4random_uniform(UInt32(numHorizontalTiles)))
            coin.i = randI
            coin.j = randJ
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

    func gameOver() {
    }
    
    func tryToGoInDirection(newDirection : Direction) {
        
        var head = snake.head
        var neck = snake.neck
        switch newDirection {
        case .Left :
            if !(neck.i == head.i && neck.j == head.j + 1) {
                direction = newDirection
            }
        case .Right :
            if !(neck.i == head.i && neck.j == head.j - 1) {
                direction = newDirection
            }
        case .Up :
            if !(neck.i == head.i + 1 && neck.j == head.j) {
                direction = newDirection
            }
        case .Down :
            if !(neck.i == head.i - 1 && neck.j == head.j) {
                direction = newDirection
            }
        }
    }
}

class ViewController : UIViewController {
    
    @IBOutlet weak var sceneView: SceneView!
    
    @IBOutlet weak var rightArrow: ArrowView!
    @IBOutlet weak var upArrow: ArrowView!
    @IBOutlet weak var leftArrow: ArrowView!
    @IBOutlet weak var downArrow: ArrowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "goRight"))
        upArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "goUp"))
        leftArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "goLeft"))
        downArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "goDown"))
        
        rightArrow.updateArrow()
        upArrow.updateArrow()
        leftArrow.updateArrow()
        downArrow.updateArrow()
    }
    
    func goRight() {
        sceneView.tryToGoInDirection(.Right)
    }
    func goUp() {
        sceneView.tryToGoInDirection(.Up)
    }
    func goLeft() {
        sceneView.tryToGoInDirection(.Left)
    }
    func goDown() {
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
