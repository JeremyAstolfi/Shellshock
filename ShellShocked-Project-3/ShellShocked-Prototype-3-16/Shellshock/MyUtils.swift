//
//  MyUtils.swift
//  sharkTest
//
//  Created by igmstudent on 2/28/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import Foundation
import SpriteKit

// Overloads for CGPoint operations

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (inout left: CGPoint, right: CGPoint) {
    left = left - right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (inout left: CGPoint, right: CGPoint) {
    left = left * right
}

func *= (inout point: CGPoint, scalar: CGFloat) {
    point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (inout left: CGPoint, right: CGPoint) {
    left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (inout point: CGPoint, scalar: CGFloat) {
    point = point / scalar
}


#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
}

let π = CGFloat(M_PI)

func shortestAngleBetween(angle1: CGFloat,
    angle2: CGFloat) -> CGFloat {
        let twoπ = π * 2.0
        var angle = (angle2 - angle1) % twoπ
        if (angle >= π) {
            angle = angle - twoπ
        }
        if (angle <= -π) {
            angle = angle + twoπ
        }
        return angle
}

extension CGFloat {
    func sign() -> CGFloat {
        return (self >= 0.0) ? 1.0 : -1.0
    }
}

// Functions to create random numbers
func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

// Creates a background sprite node
func backgroundNode() ->SKSpriteNode
{
    
    let backgroundNode = SKSpriteNode()
    backgroundNode.anchorPoint = CGPoint.zero
    backgroundNode.name = "background"
    
    let backgroundChild = SKSpriteNode(imageNamed: "background")
    backgroundChild.anchorPoint = CGPoint.zero
    backgroundChild.position = CGPoint(x: 0, y: 0)
    backgroundNode.addChild(backgroundChild)
    
    backgroundNode.size = CGSize(
        width: backgroundChild.size.width,
        height: backgroundChild.size.height)
    
    return backgroundNode
}

// Scale Action
var animating = false
let changeAnimeState = SKAction.runBlock(){ animating = !animating }
let actionScaleUp = SKAction.scaleTo(1.2, duration: 0.5)
let actionScaleDown = SKAction.scaleTo(1.0, duration: 0.5)
let actionScaleUpDown = SKAction.sequence([changeAnimeState, actionScaleUp, actionScaleDown, changeAnimeState])
