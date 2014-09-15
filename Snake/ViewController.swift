//
//  ViewController.swift
//  Snake
//
//  Created by Michael Snowden on 9/15/14.
//  Copyright (c) 2014 MichaelSnowden. All rights reserved.
//

import UIKit
import SpriteKit

enum Direction : Int {
    case Up
    case Left
    case Down
    case Right
}

typealias Index = (i : Int, j : Int)

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

class Scene : SKScene {
    
    var direction : Direction = .Right
    var tiles = Array<Array<SKShapeNode>>()
    var numHorizontalTiles : Int = 20
    var numVerticalTiles   : Int!
    let snake = Snake()
    var coin : (index : Index, node : SKNode)!
    var tileSideLength : CGFloat!
    let timeFrameInterval = NSTimeInterval(0.1)
    var lastUpdate = NSTimeInterval(0)
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        numVerticalTiles = Int(CGFloat(numHorizontalTiles) * view.frame.size.height / view.frame.size.width)
        
        // add the tiles
        tileSideLength = size.width / CGFloat(numHorizontalTiles)
        let tileSize = CGSize(width: tileSideLength, height: tileSideLength)
        
        
        for i in 0..<numVerticalTiles {
            var row = Array<SKShapeNode>()
            for j in 0..<numHorizontalTiles {
                var tile = SKShapeNode(rect: CGRect(origin: CGPoint(x: tileSideLength * CGFloat(j), y: tileSideLength * CGFloat(i)), size: tileSize), cornerRadius: 10)
                tile.fillColor = UIColor.lightGrayColor()
                row.append(tile)
                addChild(tile)
            }
            tiles.append(row)
        }
        
        // add the coin
        coin = (index : (i: 10, j: 10), node : SKShapeNode(rect: CGRect(origin: CGPoint(x: tileSideLength * CGFloat(10), y: tileSideLength * CGFloat(10)), size: tileSize), cornerRadius: 10) )
        (coin.node as SKShapeNode).fillColor = UIColor.redColor()
        addChild(coin.node)
        
        // start the game
        
        let label = SKLabelNode(text: "3")
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
        
        let countdownAction = SKAction.sequence([SKAction.repeatAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({ () -> Void in
            let value = label.text.toInt()!
            label.text = String(value - 1)
        })]), count: 3), SKAction.waitForDuration(1), SKAction.runBlock({ () -> Void in
            label.removeFromParent()
        })])
        
        runAction(SKAction.sequence([countdownAction, SKAction.runBlock({ () -> Void in
            self.paused = false
        })]))
    }
    
    override func update(currentTime: NSTimeInterval) {
        if currentTime - lastUpdate > timeFrameInterval {
            lastUpdate = currentTime
            
            gameUpdate()
        }
    }
    
    func gameUpdate() {
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
        
        if head.i == coin.index.i && head.j == coin.index.j {
            let randI = arc4random_uniform(UInt32(numVerticalTiles))
            let randJ = arc4random_uniform(UInt32(numHorizontalTiles))
            let x = CGFloat(randJ + 1) * tileSideLength
            let y = CGFloat(randI + 1) * tileSideLength
            println("i: \(randI), j: \(randJ)\nx: \(x), y: \(y)")
            
            coin.node.position = CGPoint(
                x: x,
                y: y)
        } else {
            snake.segments.removeAtIndex(0)
        }
        
        snake.segments.append(head)
        for i in 0..<numVerticalTiles {
            for j in 0..<numHorizontalTiles {
                tiles[i][j].fillColor = UIColor.lightGrayColor()
            }
        }
        
        for segment in snake.segments {
            tiles[segment.i][segment.j].fillColor = UIColor.blackColor()
        }
    }
    
    func gameOver() {
        let label = SKLabelNode(text: "Game Over")
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.fontColor = UIColor.blackColor()
        addChild(label)
        self.paused = true
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // Four cases, touches are in upper triangle, left triangle, right triangle, or bottom triangle
        
        let location = touches.anyObject()!.locationInNode(self)
        
        // for now, we'll make it a random direction
        let newDirection = Direction.fromRaw((direction.toRaw() + 1) % 4)!
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let skView = view as SKView
        skView.showsFPS = true
        
        let scene = Scene(size: skView.frame.size)
        
        skView.presentScene(scene)
    }
    
}
