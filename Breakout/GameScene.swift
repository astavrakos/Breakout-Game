//
//  GameScene.swift
//  Breakout
//
//  Created by Alexandra Stavrakos on 7/6/17.
//  Copyright © 2017 Alexandra Stavrakos. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var loseZone = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var playing = true
    let gameOver = SKLabelNode(fontNamed: "arcadepix")
    let livesLabel = SKLabelNode(fontNamed: "arcadepix")
    let quit = SKLabelNode(fontNamed: "arcadepix")
    let tryAgain = SKLabelNode(fontNamed: "arcadepix")
    let youWin = SKLabelNode(fontNamed: "arcadepix")
    var lives = 3
    var numBricks = 0
    var bricksHit = 0
    
    
    override func didMove(to view: SKView)
    {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createBackground()
        makeBall()
        makePaddle()
        layBricks()
        makeLoseZone()
        makeLivesCounter()
        moveBall()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !playing
        {
            let touch = touches.first
            let touchLocation = touch?.location(in: self)
            if tryAgain.frame.contains(touchLocation!)
            {
                gameOver.removeFromParent()
                tryAgain.removeFromParent()
                quit.removeFromParent()
                playing = true
                lives = 3
                reset()
                moveBall()
            }
            if quit.frame.contains(touchLocation!)
            {
                exit(0)
            }
        }
        for touch in touches
        {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
    }
    
    func brickHit(brick: SKSpriteNode)
    {
        if(brick.color == UIColor.red)
        {
            brick.removeFromParent()
            bricksHit += 1
        }
        else if brick.color == UIColor.orange
        {
            brick.color = UIColor.red
        }
        else
        {
            brick.color = UIColor.orange
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if contact.bodyA.node?.name?.range(of:"brick") != nil || contact.bodyB.node?.name?.range(of:"brick") != nil
        {
            if(ball == contact.bodyA)
            {
                brickHit(brick: contact.bodyB.node! as! SKSpriteNode)
                checkWin()
            }
            else
            {
                brickHit(brick: contact.bodyA.node! as! SKSpriteNode)
                checkWin()
            }
        }
        
        if contact.bodyA.node?.name == "loseZone" || contact.bodyB.node?.name == "loseZone"
        {
            if lives > 1
            {
                ball.removeFromParent()
                lives -= 1
                livesLabel.text = "Lives: \(lives)"
                makeBall()
                moveBall()
            }
            else
            {
                livesLabel.text = "Lives: 0"
                makeGameOverMessage()
                ball.removeFromParent()
                makeQuitMessage()
                playing = false
                makeTryAgainMessage()
                paddle.removeFromParent()
            }
            
        }
    }
    
    func createBackground()
    {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1
        {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func reset()
    {
        playing = false
        numBricks = 0
        lives = 3
        ball.removeFromParent()
        paddle.removeFromParent()
        loseZone.removeFromParent()
        livesLabel.text = "Lives: 3"
        bricks = [SKSpriteNode]()
        layBricks()
        makeBall()
        makePaddle()
        makeLoseZone()
        numBricks = 0
        bricksHit = 0
    }
    
    func makeBall()
    {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.strokeColor = UIColor.black
        ball.fillColor = UIColor.yellow
        ball.name = "ball"
        
        //physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        //ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        //use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        //no loss of energy from friction
        ball.physicsBody?.friction = 0
        //gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        //bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        //does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball) //add ball object to the view
    }
    
    func makePaddle()
    {
        paddle = SKSpriteNode(color: UIColor.white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBrick(x: CGFloat, y: CGFloat, color: UIColor, w: CGFloat, h: CGFloat)
    {
        var brick = SKSpriteNode()
        bricks.append(brick)
        brick = SKSpriteNode(color: color, size: CGSize(width: w, height: h))
        brick.position = CGPoint(x: x, y: y)
        brick.name = "brick+\(numBricks)"
        numBricks += 1
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
    }
    
    func layBricks()
    {
        let numWide = CGFloat(6)
        let brickWidth = frame.width/numWide - 5/numWide - 5
        let brickHeight = CGFloat(20)
        for row in 1...3
        {
            var color = UIColor()
            switch row
            {
            case 1:
                color = UIColor.yellow
            case 2:
                color = UIColor.orange
            default:
                color = UIColor.red
            }
            for col in 1...Int(numWide)
            {
                makeBrick(x: frame.minX+(brickWidth+CGFloat(5))*CGFloat(col)-brickWidth/2, y: frame.maxY-(brickHeight+CGFloat(5))*CGFloat(row)-brickHeight/2, color: color, w: brickWidth, h: brickHeight)
            }
        }
    }
    
    func makeLoseZone()
    {
        loseZone = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    func makeGameOverMessage()
    {
        gameOver.text = "Game Over"
        gameOver.position = CGPoint(x: 0, y: 0)
        gameOver.fontSize = 40
        gameOver.color = UIColor.white
        addChild(gameOver)
    }
    
    func makeYouWin()
    {
        youWin.text = "You Win"
        youWin.position = CGPoint(x: 0, y: 0)
        youWin.fontSize = 40
        youWin.color = UIColor.white
        addChild(youWin)
    }
    
    func makeTryAgainMessage()
    {
        tryAgain.text = "Try Again"
        tryAgain.position = CGPoint(x: 0, y: -40)
        tryAgain.fontSize = 20
        tryAgain.color = UIColor.white
        addChild(tryAgain)
    }
    
    func makeQuitMessage()
    {
        quit.text = "Quit"
        quit.position = CGPoint(x: 0, y: -80)
        quit.fontSize = 20
        quit.color = UIColor.white
        addChild(quit)
    }
    
    func makeLivesCounter()
    {
        livesLabel.text = "Lives: 3"
        livesLabel.position = CGPoint(x: frame.minX + 60, y: frame.minY + 20)
        livesLabel.fontSize = 20
        addChild(livesLabel)
    }
    
    func moveBall()
    {
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 3.5, dy: 5))
    }
    
    func checkWin()
    {
        if numBricks == bricksHit
        {
            playing = false
            makeYouWin()
            ball.removeFromParent()
            paddle.removeFromParent()
        }
    }
}
