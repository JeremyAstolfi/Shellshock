import Foundation
import SpriteKit

class Player:SKSpriteNode{
    
    var imageName:String
    var playableArea: CGRect = CGRect.zero
    var playerSpeed: CGFloat = 960.0
    var playerVelocity = CGPoint.zero
    var playerFriction: CGFloat = 10.0
    var playerDirection = CGPoint.zero
    
    let playerRotationRate = 10.0 * π
    var actionRotate: SKAction!
    
    init(imageName: String){
        self.imageName = imageName
        let texture = SKTexture(imageNamed: self.imageName)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.setScale(0.3)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Updates the Shark by moving and potentially flipping it
    func update(dt: NSTimeInterval)
    {
        
        if playerVelocity.length() > 0.1
        {
            playerVelocity = playerVelocity.normalized() * (playerVelocity.length() - playerFriction)
            playerDirection = playerVelocity
        }
        else
        {
            playerVelocity = CGPoint.zero
        }
        
        keepPlayerInBounds()
        moveSprite(dt)
        rotateSprite()
    }
    
    
    func moveSprite(dt: NSTimeInterval)
    {
        
        let playerMove = playerVelocity * CGFloat(dt)
        position += playerMove
    }
    
    func keepPlayerInBounds()
    {
        let bottomLeft = CGPoint(x: CGRectGetMinX(playableArea),
            y: CGRectGetMinY(playableArea))
        let topRight = CGPoint(x: CGRectGetMaxX(playableArea),
            y: CGRectGetMaxY(playableArea))
        
        if position.x <= bottomLeft.x{
            position.x = bottomLeft.x
            playerVelocity.x = -playerVelocity.x
        }
        if position.x >= topRight.x{
            position.x = topRight.x
            playerVelocity.x = -playerVelocity.x
        }
        if position.y <= bottomLeft.y{
            position.y = bottomLeft.y
            playerVelocity.y = -playerVelocity.y
        }
        if position.y >= topRight.y{
            position.y = topRight.y
            playerVelocity.y = -playerVelocity.y
        }
    }
    func rotateSprite()
    {
        let deltaX = playerVelocity.x
        let deltaY = playerVelocity.y
        let angleToRotateTo = atan2(deltaY, deltaX)
        
        actionRotate = SKAction.rotateToAngle(angleToRotateTo - π/2, duration: 0.000001)
        runAction(actionRotate)
        
    }
    
    func playerDidCollideWithShark(shark:Shark, scene: GameScene) {
        scene.timer -= shark.damageToTime
        scene.tempTime = scene.timer
        scene.uiSetUp.updateTimerUI(scene)
        shark.removeFromParent()
    }
    
    func playerDidCollideWithBoss(megalodon: Megalodon, scene: GameScene)
    {
        scene.timer -= megalodon.damageToTime
        scene.tempTime = scene.timer
        scene.uiSetUp.updateTimerUI(scene)
        playerVelocity *= -1
    }
}

