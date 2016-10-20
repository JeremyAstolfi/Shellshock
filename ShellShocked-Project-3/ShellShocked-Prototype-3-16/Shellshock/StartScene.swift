//
//  StartScene.swift
//  Shellshock
//
//  Created by igmstudent on 2/29/16.
//  Copyright © 2016 TeamSwifty. All rights reserved.
//

import Foundation
import SpriteKit

class StartScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.blueColor()
        
        let background = backgroundNode()
        background.setScale(4)
        background.anchorPoint = CGPointZero
        background.position = CGPoint(x: 0, y: 0)
        background.name = "background"
        background.zPosition = -2
        addChild(background)
        
        let title1 = SKLabelNode(fontNamed: "Courier-Bold")
        title1.fontSize = 150
        title1.text = "Shell"
        title1.fontColor = SKColor.blackColor()
        title1.position = CGPoint(x: size.width/2, y: size.height/2 + 160)
        addChild(title1)

        let title2 = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        title2.text = "Shock"
        title2.fontSize = 150
        title2.fontColor = SKColor.blackColor()
        title2.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(title2)
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(2.0),
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.fadeWithDuration(2.0)
                let scene = TutorialScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
        ]))

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}