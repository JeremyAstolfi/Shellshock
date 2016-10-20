import Foundation
import SpriteKit

class Megalodon: Shark
{
    var health: CGFloat = 5
    var wanderAng: CGFloat = 100
    var playableArea: CGRect = CGRect.zero
    
    override func moveShark(x:CGFloat, y:CGFloat){
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
        else
        {
            wander(angleToRotateTo)
        }
        
        if(health <= 0)
        {
            self.removeFromParent()
        }
    }
    
    func wander(angleToRotate: CGFloat)
    {
        var wanderTarg: CGPoint = position + CGPoint(x: position.x + 50, y: position.y) * 10
        let angle: CGPoint = CGPoint(x: cos(wanderAng), y: sin(wanderAng))
        let offset: CGPoint = angle * CGPoint(x: position.x + 50, y: position.y)
        wanderTarg += offset * 8
        
        //Debug.DrawLine(transform.position, wanderTarg, Color.red);
        wanderAng += random(min: -8, max: 8);
        
        let targOffset = wanderTarg - position
        let direction = targOffset.normalized()
        
        sharkVelocity = direction * sharkSpeed
        
        let actionRotate = SKAction.rotateToAngle(angleToRotate, duration: 0.25)
        self.runAction(actionRotate)
    }
    func keepMegalodonInBounds()
    {
        let bottomLeft = CGPoint(x: CGRectGetMinX(playableArea),
            y: CGRectGetMinY(playableArea))
        let topRight = CGPoint(x: CGRectGetMaxX(playableArea),
            y: CGRectGetMaxY(playableArea))
        
        if position.x <= bottomLeft.x{
            position.x = bottomLeft.x
            sharkVelocity.x = -sharkVelocity.x
            wanderAng += 180
        }
        if position.x >= topRight.x{
            position.x = topRight.x
            sharkVelocity.x = -sharkVelocity.x
            wanderAng += 180
        }
        if position.y <= bottomLeft.y{
            position.y = bottomLeft.y
            sharkVelocity.y = -sharkVelocity.y
            wanderAng += 180
        }
        if position.y >= topRight.y{
            position.y = topRight.y
            sharkVelocity.y = -sharkVelocity.y
            wanderAng += 180
        }
    }


}
