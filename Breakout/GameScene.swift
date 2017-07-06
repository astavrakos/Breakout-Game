//
//  GameScene.swift
//  Breakout
//
//  Created by Alexandra Stavrakos on 7/6/17.
//  Copyright © 2017 Alexandra Stavrakos. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene
{
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView)
    {
        createBackground()
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
        
}
