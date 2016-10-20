//
//  Shark.swift
//  sharkTest
//
//  Created by igmstudent on 2/28/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import Foundation
import SpriteKit

class Shark:SKSpriteNode{
    
    var imageName: String
    var scoreMod: Int
    var centerSpawn: CGPoint
    var targetFromSpawn: Int
    var sharkSpeed: CGFloat = 960.0
    var sharkVelocity: CGPoint = CGPoint.zero
    var sharkFriction: CGFloat = 10.0
    var sharkDirection = CGPoint.zero
    var attackRange: CGFloat = 0
    var damageToTime: CGFloat = 1
    
    init(imageName: String, scoreModifier: Int){
        self.imageName = imageName
        self.scoreMod = scoreModifier
        let texture = SKTexture(imageNamed: self.imageName)
        centerSpawn = CGPoint.zero
        targetFromSpawn = -1 + Int(arc4random_uniform(UInt32(1 - -1 + 1)))
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.setScale(0.3)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Updates the Shark by moving and potentially flipping it
    func update(x:CGFloat, y:CGFloat, player: SKSpriteNode, dt: NSTimeInterval){
        moveShark(x, y: y)
        moveSprite(dt)
        //rotateSprite()
        if(self.position.x <= player.position.x && self.xScale > 0){
            flipShark(1.0)
        }
        else if(self.position.x > player.position.x && self.xScale < 0){
            flipShark(1.0)
        }
    }
    
    // MARK: Movement/Rotation
    // Moves the Shark towards a location
    func moveShark(x:CGFloat, y:CGFloat){
        // Determine speed of the Shark
        //let constraintOrient = SKConstraint.orientToPoint(CGPointMake(x, y), offset: SKRange(constantValue: 0))
        
        let deltaX = x - self.position.x
        let deltaY = y - self.position.y
        let angleToRotateTo = atan(deltaY / deltaX)
        
        let distance = sqrt((pow(deltaX, 2) + pow(deltaY, 2)))
        if(distance < attackRange)
        {
            let sharkOffset = CGPoint(x: x, y: y) - position
            let sharkDirection = sharkOffset.normalized()
            
            sharkVelocity = sharkDirection * sharkSpeed
            
            let actionRotate = SKAction.rotateToAngle(angleToRotateTo, duration: 0.25)
            self.runAction(actionRotate)
        }
    }
    
    // Helper function to set random spawn of Shark
    func setSpawnPos(x: CGFloat, y: CGFloat)
    {
        // Position the Shark slightly off-screen along the edge,
        // and along a random position along the X or Y axis as calculated above
        centerSpawn = CGPoint(x: x, y: y)
        position = CGPoint(x: x, y: y)
    }
    
    func moveSprite(dt: NSTimeInterval)
    {
        let sharkMove = sharkVelocity * CGFloat(dt)
        position += sharkMove
    }
    
    func rotateSprite()
    {
        let deltaX = sharkVelocity.x
        let deltaY = sharkVelocity.y
        let angleToRotateTo = atan2(deltaY, deltaX)
        
        let actionRotate = SKAction.rotateToAngle(angleToRotateTo - π/2, duration: 0.000001)
        runAction(actionRotate)
        
    }
    
    // Flips the Shark in the opposite direction
    func flipShark(flipAmount: CGFloat){
        self.xScale *= -flipAmount
    }
}