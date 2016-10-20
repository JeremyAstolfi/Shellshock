//
//  UISetUp.swift
//  Shellshock
//
//  Created by igmstudent on 5/16/16.
//  Copyright © 2016 TeamSwifty. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: HUD
class UISetUp
{
func setupHUD(scene: GameScene){
    scene.hud.anchorPoint = CGPointMake(0.5, 1.0)
    scene.hud.position = CGPoint(x: 0, y: scene.size.height/2)
    scene.hud.zPosition = 101
    
    scene.pauseButton.anchorPoint = CGPointMake(1.0, 1.0)
    scene.pauseButton.position = CGPoint(x: scene.size.width/2 - 72, y: scene.size.height/2)
    scene.pauseButton.zPosition = 102
    
    scene.timeLabel.verticalAlignmentMode = .Top
    scene.timeLabel.horizontalAlignmentMode = .Center
    scene.timeLabel.text = "\(Int(floor(scene.timer))):\(Int(round(100 * (scene.timer % floor(scene.timer)))))"
    scene.timeLabel.fontSize = 80
    scene.timeLabel.fontColor = SKColor.blackColor()
    scene.timeLabel.position = CGPoint(x: 0, y: scene.size.height/2 - 5)
    scene.timeLabel.zPosition = 102
    
    scene.scoreLabel.verticalAlignmentMode = .Top
    scene.scoreLabel.horizontalAlignmentMode = .Left
    scene.scoreLabel.text = "Score: \(scene.score)"
    scene.scoreLabel.fontSize = 40
    scene.scoreLabel.fontColor = SKColor.blackColor()
    scene.scoreLabel.position = CGPoint(x: -scene.size.width/2 + 80, y: scene.size.height/2 - 5)
    scene.scoreLabel.zPosition = 102
    
    scene.cameraNode.addChild(scene.hud)
    scene.cameraNode.addChild(scene.pauseButton)
    scene.cameraNode.addChild(scene.scoreLabel)
    scene.cameraNode.addChild(scene.timeLabel)
}

func updateTimerUI(scene: GameScene)
{
    if round(100 * (scene.timer % floor(scene.timer))) > 0 {
        if Int(round(100 * (scene.timer % floor(scene.timer)))) < 10 {
            scene.timeLabel.text = "\(Int(floor(scene.timer))):0\(Int(round(100 * (scene.timer % floor(scene.timer)))))"
        }
        else if Int(round(100 * (scene.timer % floor(scene.timer)))) == 0 || Int(round(100 * (scene.timer % floor(scene.timer)))) == 100 {
            scene.timeLabel.text = "\(Int(floor(scene.timer))):99"
        }
        else {
            scene.timeLabel.text = "\(Int(floor(scene.timer))):\(Int(round(100 * (scene.timer % floor(scene.timer)))))"
        }
        if(scene.timer <= 10 && !animating){
            scene.timeLabel.runAction(actionScaleUpDown)
            scene.timeLabel.fontColor = SKColor.redColor()
            animating = false
        }
        else if((scene.tempTime - scene.timer <= 1 && scene.tempTime - scene.timer > 0) && !animating){
            scene.timeLabel.runAction(actionScaleUpDown)
            scene.timeLabel.fontColor = SKColor.redColor()
            animating = false
        }
        if(scene.timer - scene.tempTime < -1 && scene.timer > 10){
            scene.timeLabel.fontColor = SKColor.blackColor()
        }
    }
    else {
        scene.timeLabel.text = "0:\(Int(round(100 * (scene.timer % 1))))"
    }
}
}