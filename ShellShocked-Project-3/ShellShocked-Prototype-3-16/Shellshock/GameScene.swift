import SpriteKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Player: UInt32 = 0b1      // 1
    static let Torpedo: UInt32 = 0b10    // 2
    static let Enemies: UInt32 = 0b11    // 3
    static let Treasure: UInt32 = 0b100  // 4
    static let Megalodon: UInt32 = 0b101 // 5
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let player:Player = Player(imageName: "submarine")
    let megalodon: Megalodon = Megalodon(imageName: "Megalodon", scoreModifier: 2500)
    let uiSetUp = UISetUp()
    let hud = SKSpriteNode(imageNamed: "Temp_HUD")
    let pauseButton = SKSpriteNode(imageNamed: "Pause_Button")
    
    var torpedoSpeed: CGFloat = 1280.0
    var torpedoVelocity = CGPoint.zero

    var lastTouchPosition: CGPoint?
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var timer: CGFloat = 60
    var gameOver = false
    var invincible = false
    //let torpedoLaunchSound: SKAction = SKAction.playSoundFileNamed("torpedoLaunch.wav", waitForCompletion: false)
    var treasureSpawner: [SKSpriteNode] = []
    var SharkList: [Shark] = []
    var SwiftSharkList: [Shark] = []
    var score = 0
    let scoreLabel = SKLabelNode(fontNamed: "Bubblegum")
    let timeLabel = SKLabelNode(fontNamed: "Bubblegum")
    let cameraNode = SKCameraNode();
    
    var timeTouched: CGFloat = 0
    var timeBetweenTouches: CGFloat = 0.75
    var interactable = true
    var tempTime: CGFloat = 0
    let background = backgroundNode()
    let bubbleEmitter = SKEmitterNode(fileNamed: "BubbleEmitter")!
    
    let backgroundMusic = SKAudioNode(fileNamed: "sweetclouds.wav")
    
    override init(size: CGSize)
    {
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: Make a game over scene
    override func didMoveToView(view: SKView)
    {
        backgroundColor = SKColor.blackColor()
        
        background.setScale(20)
        background.anchorPoint = CGPointZero
        background.position = CGPoint(x: 0, y: 0)
        background.name = "background"
        background.zPosition = -2
        addChild(background)
        
        let playableHeight = background.size.height
        let playableMargin = background.size.width
        player.playableArea = CGRect(
            x: 0, y: 0, width: playableMargin, height: playableHeight)
        
        player.setScale(0.35)
        player.position = CGPoint(x: background.size.width/2, y: background.size.height - (2 * player.size.height))
        player.zPosition = 100
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Enemies
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(player)
        addChild(cameraNode)
        camera = cameraNode
        
        let filter = CIFilter(name: "CIGaussianBlur")
        let blurAmount = 10.0
        filter!.setValue(blurAmount, forKey: kCIInputRadiusKey)
        
        uiSetUp.setupHUD(self)
        
        setCameraPosition(CGPoint(x:size.width/2,y:size.height/2))
        
        bubbleEmitter.position = CGPointMake(background.size.width/2, 0)
        bubbleEmitter.zPosition = 5
        addChild(bubbleEmitter)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        addMegalodon("Megalodon")
        
        for _ in 1...30
        {
            addShark("Shark")
        }
        
        for _ in 1...15
        {
            addSwiftShark("SwiftShark")
        }
        
        spawnTreasure()
        
        backgroundMusic.autoplayLooped = true;
        //addChild(backgroundMusic);
        
        runAction(SKAction.playSoundFileNamed("sweetclouds", waitForCompletion: false))
        
    }
   
    override func update(currentTime: NSTimeInterval)
    {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if timeTouched < timeBetweenTouches
        {
            timeTouched += CGFloat(dt)
        }
        else
        {
            interactable = true
        }
        
        timer -= CGFloat(dt)
        uiSetUp.updateTimerUI(self)
        
        player.update(dt)
        
        setCameraPosition(player.position)
        
        megalodon.update(player.position.x, y: player.position.y, player: player, dt: dt)
     
        for shark in SharkList {
            shark.update(player.position.x, y: player.position.y, player: player, dt: dt)
        }
        
        for shark in SwiftSharkList {
            shark.update(player.position.x, y: player.position.y, player: player, dt: dt)
        }
        
        if(timer <= 0.0 && !gameOver)
        {
            timeLabel.text = "0:00"
            gameOver = true
            let gameOverScene = GameOverScene(size: size, score: score)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.fadeWithDuration(2.0)
            view?.presentScene(gameOverScene, transition:reveal)
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch = touches.first else { return }
        let touchPosition = touch.locationInNode(self)
        
        if(interactable)
        {
            runAction(SKAction.playSoundFileNamed("torpedo.wav", waitForCompletion: true))
            launchTorpedo(touchPosition)
            sceneTouched(touchPosition)
            interactable = false
            timeTouched = 0
        }
    }
    
    func sceneTouched(touchPosition:CGPoint)
    {
        lastTouchPosition = touchPosition
        
        let playerOffset = player.position - touchPosition
        let playerDirection = playerOffset.normalized()
        
        let torpedoOffset = touchPosition - player.position
        let torpedoDirection = torpedoOffset.normalized()
        
        player.playerVelocity = playerDirection * player.playerSpeed
        torpedoVelocity = torpedoDirection * torpedoSpeed
    }
    
    func launchTorpedo(touchPosition: CGPoint)
    {
        //will change to torpedo later
        let torpedo = SKSpriteNode(imageNamed: "torpedo")
        torpedo.setScale(0.25)
        torpedo.position = player.position
        
        torpedo.physicsBody = SKPhysicsBody(rectangleOfSize: torpedo.size)
        torpedo.physicsBody?.dynamic = true
        torpedo.physicsBody?.categoryBitMask = PhysicsCategory.Torpedo
        torpedo.physicsBody?.contactTestBitMask = PhysicsCategory.Enemies
        torpedo.physicsBody?.collisionBitMask = PhysicsCategory.None
        torpedo.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(torpedo)
        
        let travelDistance = touchPosition - torpedo.position
        
        let direction = travelDistance.normalized()
        
        let torpedoTrueSpeed = direction * torpedoSpeed
        let targetPosition = torpedoTrueSpeed + torpedo.position
        
        
        let delta = player.playerDirection * -1
        let angleToRotateTo = atan2(delta.y, delta.x)
        
        let actionRotate = SKAction.rotateToAngle(angleToRotateTo, duration: 0.000001)
        torpedo.runAction(actionRotate)
        
        let torpedoLaunch = SKAction.moveTo((targetPosition), duration: 2.0)
        let torpedoFinish = SKAction.removeFromParent()
        torpedo.runAction(SKAction.sequence([torpedoLaunch,torpedoFinish]))
    }
    
    
    // MARK: Collisions
    func torpedoDidCollideWithShark(torpedo:SKSpriteNode, shark:Shark) {
        torpedo.removeAllChildren()
        torpedo.removeFromParent()
        shark.removeFromParent()
        score += shark.scoreMod
        scoreLabel.text = "Score: \(score)"
    }
    
    func torpedoDidCollideWithBoss(torpedo: SKSpriteNode, boss: Megalodon)
    {
        torpedo.removeAllChildren()
        torpedo.removeFromParent()
        boss.health -= 1
        if(boss.health <= 0)
        {
            score += boss.scoreMod
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // Check for collision with two sharks one bullet
        guard contact.bodyA.node != nil && contact.bodyB.node != nil else{
            return
        }
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //if ((firstBody.categoryBitMask & PhysicsCategory.Enemies != 0) &&
            //(secondBody.categoryBitMask & PhysicsCategory.Torpedo != 0)) {
        if(firstBody.categoryBitMask == PhysicsCategory.Torpedo && secondBody.categoryBitMask == PhysicsCategory.Enemies) {
            torpedoDidCollideWithShark(firstBody.node as! SKSpriteNode, shark: secondBody.node as! Shark)
        }
            
        else if (firstBody.categoryBitMask == PhysicsCategory.Torpedo && secondBody.categoryBitMask == PhysicsCategory.Megalodon){
            torpedoDidCollideWithBoss(firstBody.node as! SKSpriteNode, boss: secondBody.node as! Megalodon)
        }
        
        else if (firstBody.categoryBitMask == PhysicsCategory.Player && secondBody.categoryBitMask == PhysicsCategory.Enemies){
            runAction(SKAction.playSoundFileNamed("crashShort.wav", waitForCompletion: true))
            player.playerDidCollideWithShark(secondBody.node as! Shark, scene: self)
        }
            
        else if (firstBody.categoryBitMask == PhysicsCategory.Player && secondBody.categoryBitMask == PhysicsCategory.Megalodon){
            runAction(SKAction.playSoundFileNamed("crashShort.wav", waitForCompletion: true))
            player.playerDidCollideWithBoss(secondBody.node as! Megalodon, scene: self)
        }
        else if (firstBody.categoryBitMask == PhysicsCategory.Player && secondBody.categoryBitMask == PhysicsCategory.Treasure)
        {
            
            runAction(SKAction.playSoundFileNamed("coins.wav", waitForCompletion: true))
            score += 500
            scoreLabel.text = "Score: \(score)"
            secondBody.node!.removeFromParent()
        }
        
    }
    
    // MARK: Camera setup/movement
    func getCameraPosition()->CGPoint
    {
        return CGPoint(x:cameraNode.position.x, y:cameraNode.position.y)
    }
    
    func setCameraPosition(position: CGPoint)
    {
        let minX = size.width/2
        let minY = size.height/2
        let maxX = background.size.width - size.width/2
        let maxY = background.size.height - size.height/2
        var tempFinalX: CGFloat = 0.0
        var tempFinalY:CGFloat  = 0.0
        
        tempFinalX = position.x
        tempFinalY = position.y
        
        if(position.x <= minX){
            tempFinalX = minX
        }
        else if(position.x >= maxX){
            tempFinalX = maxX
        }
        
        if(position.y <= minY){
            tempFinalY = minY
        }
        else if(position.y >= maxY){
            tempFinalY = maxY
        }
        
        cameraNode.position = CGPoint(x:tempFinalX, y:tempFinalY)
    }
    
    func moveCamera()
    {
        let distance: CGFloat = hypot(player.position.x - cameraNode.position.x,
            player.position.y - cameraNode.position.y)
        if(distance > CGFloat(400)) //temp values
        {
            //let backgroundVelocity = CGPoint(x:distance, y:distance)
        }
    }
    
    // MARK: Shark setup
    func addShark(name: String)
    {
        // Create a Shark using the passed in image name
        let shark = Shark(imageName: name, scoreModifier: 100)
        shark.attackRange = 900
        shark.sharkSpeed = 360
        shark.setScale(0.50)
        
        let actualX = random(min: shark.size.width/2, max: background.size.width - shark.size.width/2)
        let actualY = random(min: shark.size.height/2, max: background.size.height - shark.size.height/2)
        
        shark.setSpawnPos(actualX, y:actualY)
        
        addChild(shark)
        
        shark.physicsBody = SKPhysicsBody(rectangleOfSize: shark.size)
        shark.physicsBody?.dynamic = true
        shark.physicsBody?.categoryBitMask = PhysicsCategory.Enemies
        shark.physicsBody?.contactTestBitMask = PhysicsCategory.Torpedo
        shark.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        shark.update(player.position.x, y: player.position.y, player: player, dt: dt)
        
        SharkList.append(shark)
    }
    
    func addSwiftShark(name: String)
    {
        
        // Create a Shark using the passed in image name
        let shark = Shark(imageName: name, scoreModifier: 250)
        shark.sharkSpeed = 720
        shark.attackRange = 650
        shark.damageToTime = 3
        shark.setScale(0.30)
        
        let actualX = random(min: shark.size.width/2, max: (background.size.width - shark.size.width/2))
        let actualY = random(min: 50 + shark.size.height/2, max: 200 + (2 * shark.size.height))
        
        shark.setSpawnPos(actualX, y: actualY)
        
        addChild(shark)
        
        shark.physicsBody = SKPhysicsBody(rectangleOfSize: shark.size)
        shark.physicsBody?.dynamic = true
        shark.physicsBody?.categoryBitMask = PhysicsCategory.Enemies
        shark.physicsBody?.contactTestBitMask = PhysicsCategory.Torpedo
        shark.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        shark.update(player.position.x, y: player.position.y, player: player, dt: dt)
        
        SwiftSharkList.append(shark)
    }
    
    func addMegalodon(name: String)
    {
        // Create a Shark using the passed in image name
        megalodon.sharkSpeed = 200
        megalodon.attackRange = 500
        megalodon.damageToTime = 5
        megalodon.setScale(2.5)
        
        let actualX = random(min: megalodon.size.width/2, max: (background.size.width - megalodon.size.width/2))
        let actualY = random(min: 50 + megalodon.size.height/2, max: background.size.height - megalodon.size.height)
        
        megalodon.setSpawnPos(actualX, y: actualY)
        
        addChild(megalodon)
        
        megalodon.physicsBody = SKPhysicsBody(rectangleOfSize: megalodon.size)
        megalodon.physicsBody?.dynamic = true
        megalodon.physicsBody?.categoryBitMask = PhysicsCategory.Megalodon
        megalodon.physicsBody?.contactTestBitMask = PhysicsCategory.Torpedo
        megalodon.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        megalodon.update(player.position.x, y: player.position.y, player: player, dt: dt)
    }
    
    func spawnTreasure()
    {
        for _ in 1...15
        {
            let treasure = SKSpriteNode(imageNamed: "Treasure")
            treasure.setScale(0.15)
            treasure.position.x = random(min: treasure.size.width, max: background.size.width - treasure.size.width)
            treasure.position.y = treasure.size.height
            addChild(treasure)
            
            treasure.physicsBody = SKPhysicsBody(rectangleOfSize: treasure.size)
            treasure.physicsBody?.dynamic = true
            treasure.physicsBody?.categoryBitMask = PhysicsCategory.Treasure
            treasure.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            treasure.physicsBody?.collisionBitMask = PhysicsCategory.None
            treasureSpawner.append(treasure)
        }
    }
}
