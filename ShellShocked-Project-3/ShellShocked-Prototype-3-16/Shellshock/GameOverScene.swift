//
//  GameOverScene.swift
//  Shellshock
//
//  Created by igmstudent on 3/7/16.
//  Copyright © 2016 TeamSwifty. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    var score:Int
    
    init(size: CGSize, score: Int) {
        self.score = score
        super.init(size: size)
        backgroundColor = SKColor.blueColor()
        
        let background = backgroundNode()
        background.setScale(4)
        background.anchorPoint = CGPointZero
        background.position = CGPoint(x: 0, y: 0)
        background.name = "background"
        background.zPosition = -2
        addChild(background)
        
        let mainlabel = SKLabelNode(fontNamed: "GillSans-Bold")
        mainlabel.text = "Game Over"
        mainlabel.fontSize = 300
        mainlabel.fontColor = SKColor.blackColor()
        mainlabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(mainlabel)
        
        let label = SKLabelNode(fontNamed: "GillSans-Bold")
        label.text = "Score: \(score)"
        label.fontSize = 150
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2 + 300)
        addChild(label)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        
        animating = false
        // More here...
        let wait = SKAction.waitForDuration(3.0)
        let block = SKAction.runBlock {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.fadeWithDuration(0.0)
            self.view?.presentScene(myScene, transition: reveal)
        }
        self.runAction(SKAction.sequence([wait, block]))
    }
}
