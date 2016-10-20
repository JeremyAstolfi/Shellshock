//
//  TutorialScene.swift
//  Shellshock
//
//  Created by igmstudent on 3/14/16.
//  Copyright © 2016 TeamSwifty. All rights reserved.
//

import Foundation
import SpriteKit

class TutorialScene: SKScene {
    
    let endTutLabel = SKLabelNode(fontNamed: "Bubblegum")
    let effectsNode = SKEffectNode()
    
    var tutorial: SKSpriteNode!
    var tutFrames = [SKTexture]()
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.blueColor()
        
        let background = backgroundNode()
        background.setScale(4)
        background.anchorPoint = CGPointZero
        background.position = CGPoint(x: 0, y: 0)
        background.name = "background"
        background.zPosition = -2
        
        // MARK: Blur Effect TANKS FPS DO NOT USE
        /*
        let filter = CIFilter(name: "CIGaussianBlur")
        let blurAmount = 10.0
        
        filter?.setValue(blurAmount, forKey: kCIInputRadiusKey)
        
        effectsNode.filter = filter
        effectsNode.position = CGPointMake(0, 0)
        effectsNode.blendMode = .Alpha
        
        effectsNode.addChild(background)
        addChild(effectsNode)
        */
        
        addChild(background)
        
        endTutLabel.verticalAlignmentMode = .Center
        endTutLabel.horizontalAlignmentMode = .Center
        endTutLabel.text = "Touch anywhere to continue"
        endTutLabel.fontSize = 70
        endTutLabel.fontColor = SKColor.whiteColor()
        endTutLabel.position = CGPoint(x: size.width/2, y: 200)
        endTutLabel.zPosition = 102
        
        addChild(endTutLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        let tutAtlas = SKTextureAtlas(named: "tutorial")
        let numImages = tutAtlas.textureNames.count
        
        for var i = 1; i < numImages; i++ {
            let tutTextureName = "tutorial\(i)"
            tutFrames.append(tutAtlas.textureNamed(tutTextureName))
        }
        
        let firstFrame = tutFrames[0]
        tutorial = SKSpriteNode(texture: firstFrame)
        tutorial.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        tutorial.setScale(1.5)
        addChild(tutorial)
        
        tutorialGif()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        runAction(SKAction.sequence([
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.fadeWithDuration(0.0)
                let scene = GameScene(size: self.size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
    }
    
    func tutorialGif(){
        tutorial.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(
                tutFrames,
                timePerFrame: 1/30,
                resize: false,
                restore:  true
            )),
        withKey:"tutorial")
    }
}