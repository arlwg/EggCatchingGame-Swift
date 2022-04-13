//
//  GameScene.swift
//  Assignment 2 Swifty
//
//  Created by Karl Zingel on 2022-04-12.
//
import CoreMotion
import SpriteKit
import GameplayKit


class Object: SKSpriteNode { }

class Player: SKSpriteNode { }

//Global score variable, used in seperate scene.
var theScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Array of ball asset names, used when initializing our balls.
    var balls = ["ballBlue", "ballGreen", "ballPurple", "ballRed", "ballYellow"]
    //With balls affected by gravity, by tilting the screen on ipad you can make them move.
    var motionManager: CMMotionManager?
    //Score label public declaration
    let scoreLabel = SKLabelNode(fontNamed:"HelveticaNeue-Thin")
    //Lives label public declaration
    let livesLabel = SKLabelNode(fontNamed:"HelveticaNeue-Thin")
    //Player public declaration
    let player = SKSpriteNode(imageNamed: "Basket")
    
    //Physics categories used for collision
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 // 1
        static let Bounds : UInt32 = 0b10 // 2
        static let Ball : UInt32 = 0b100 // 4
    }
    //Game state enum.
    enum gameState {
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState = gameState.inGame
//Score variable - formats and updates score
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "Score \(formattedScore)"
        }
    }
    //Lives variable - formats and updates lives
    var lives = 3 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            
            let formattedLives = formatter.string(from: lives as NSNumber) ?? "3"
            livesLabel.text = "Lives \(formattedLives)"
        }
    }
    
    //Function(s) for returning random number within range.
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    //When we start a new level, we stop all current actions running (if they are currently running) , and then start again when we call it again.
    
    func startNewLevel(){
        if self.action(forKey: "SpawnGravity") != nil {
            self.removeAction(forKey: "SpawnGravity")
        }
        
        if self.action(forKey: "SpawnBall") != nil {
            self.removeAction(forKey: "SpawnBall")
        }
        
        
        let spawn = SKAction.run(spawnObject)
        let spawnGravity = SKAction.run(spawnGravityObject)
        let waitToSpawn = SKAction.wait(forDuration: 1)
        let waitToSpawnGravityActor = SKAction.wait(forDuration: 1.6)
        
        //Spawning non-gravity balls sequence
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        //Spawning gravity balls sequence
        let gravitySpawnSequence = SKAction.sequence([waitToSpawnGravityActor, spawnGravity])
        
        let spawnForever = SKAction.repeatForever(spawnSequence)
        let spawnGravityActorForever = SKAction.repeatForever(gravitySpawnSequence)
        self.run(spawnGravityActorForever, withKey: "SpawnGravity")
        self.run(spawnForever, withKey: "SpawnBall")
    }
    
    //When our game ends, we remove all running actions, set our game state enum, and run our change scene actions.
    func runGameOver()
    {
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Ball")
        {
            ball, stop in
            ball.removeAllActions()
        }
        
        
        currentGameState = gameState.afterGame
        theScore = score
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        
        let changeLevelSequence = SKAction.sequence([changeSceneAction, waitToChangeScene])
        
        self.run(changeLevelSequence)
        
    }
    
    //This changes our scene to the end scene when it is called.
    func changeScene()
    {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        
        self.view!.presentScene(sceneToMoveTo, transition: transition)
        
    }
    
    
    override func didMove(to view: SKView) {

        self.physicsWorld.contactDelegate = self
        
        //Setting global score variable for high score/end screen as well as local used in score label.
        theScore = 0
        score = 0
        
        //Background image
        let background = SKSpriteNode(imageNamed: "backgroundgame")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        // Score Label
        scoreLabel.fontSize = 72
        scoreLabel.position = CGPoint(x: 20, y: 20)
        scoreLabel.text = "Score : 0"
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        //Lives Label
        livesLabel.fontSize = 72
        livesLabel.position = CGPoint(x: 900, y: 20)
        livesLabel.text = "Lives : 3"
        livesLabel.zPosition = 100
        livesLabel.horizontalAlignmentMode = .right
        addChild(livesLabel)
    
        
        // Set up players physics body
        player.physicsBody = SKPhysicsBody(rectangleOf:CGSize(width: player.size.width, height: player.size.height / 2))
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        player.physicsBody?.collisionBitMask = PhysicsCategories.None
        player.physicsBody?.contactTestBitMask = PhysicsCategories.Ball
        player.setScale(3)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.075)
        player.zPosition = 2
        self.addChild(player)
        
        //Motion manager for tilting.
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
        //Begin game
        startNewLevel()
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.size.width, height: 10))
        
        //This is our collider at the bottom of the screen, it collides with the ball.
        physicsBody?.categoryBitMask = PhysicsCategories.Bounds
        physicsBody?.collisionBitMask = PhysicsCategories.None
        physicsBody?.contactTestBitMask = PhysicsCategories.Ball
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        //Ball always body1, Player body2
        if(contact.bodyA.categoryBitMask == PhysicsCategories.Ball)
        {
            body1 = contact.bodyA // Ball
            body2 = contact.bodyB // Player
        }
        else if(contact.bodyB.categoryBitMask == PhysicsCategories.Ball)
        {
            body1 = contact.bodyB // Ball
            body2 = contact.bodyA // Player
        }
        else if(contact.bodyA.categoryBitMask == PhysicsCategories.Bounds)
        {
            body1 = contact.bodyB // Ball
            body2 = contact.bodyA // Bounds
        }
        else if(contact.bodyB.categoryBitMask == PhysicsCategories.Bounds)
        {
            body1 = contact.bodyA // Ball
            body2 = contact.bodyB // Bounds
        }
        
        
        //If there is a collision with the player.
        if(body2.categoryBitMask == PhysicsCategories.Player)
        {
            if(body1.node != nil)
            {
                //increment our score
                score += 1
                //remove ball from scene
                body1.node?.removeFromParent()
                //if score reaches an multiple of 10 then increase lives by 1
                if(score % 10 == 0)
                {
                    lives += 1
                }
            }
            
        }//If there is a collision with the bounds ( bottom of screen )
        else if(body2.categoryBitMask == PhysicsCategories.Bounds)
        {
            if(body1.node != nil)
            {
                //Spawn picture & actions
                spawnOops(spawnPosition: body1.node!.position)
                //remove ball from scene
                body1.node?.removeFromParent()
                
                if(lives > 0)
                {
                    
                    lives -= 1
                }
                else
                {
                    //If we are out of lives, spawn game over sequences/functions.
                    spawnGameOver(spawnPosition: CGPoint(x: self.position.x + self.size.width / 2 , y: self.position.y + self.size.height / 2))
                    runGameOver()
                    
                }
            }
        }
        
       
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Unused currently.
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Get point of touch, and move player along x axis according to the distance dragged on the screen.
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            //Only move player if the gamestate is "inGame"
            if(currentGameState == gameState.inGame)
            {
                player.position.x += amountDragged
            }
            
                
            
        }
    }
    
    //Spawning our non-gravity objects, randomize top and bottom start/end points.
    func spawnObject() {
        let randomXStart = random(min: 0, max: self.size.width)
        let randomXEnd = random(min: 0, max: self.size.width)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        //Get random ball
        let objectType = balls.randomElement()!
        let object = SKSpriteNode(imageNamed: objectType)
        let objectRadius = object.frame.width / 2.0;
        
        //Set position and identifier
        object.position = startPoint
        object.name = "Ball"
        
        self.addChild(object)
        //Set physics properties, although affected by gravity, it is overriden by the move action.
        object.physicsBody = SKPhysicsBody(circleOfRadius: objectRadius)
        object.physicsBody?.allowsRotation = false
        object.physicsBody?.restitution = 0
        object.physicsBody?.friction = 0
        object.physicsBody?.affectedByGravity = true
        object.physicsBody?.categoryBitMask = PhysicsCategories.Ball // This is a ball
        object.physicsBody?.collisionBitMask = PhysicsCategories.None
        object.physicsBody?.contactTestBitMask = PhysicsCategories.Player // Collides with player
        
        object.zPosition = 1
        
        
        //If it doesn't get removed by collision somehow, delete once it has moved to the end point.
        let deleteObject = SKAction.removeFromParent()
        let moveObject = SKAction.move(to: endPoint, duration: 3)
        
        let objectSequence = SKAction.sequence([moveObject, deleteObject])
        
        //Only run if we are in game ( failsafe ).
        if(currentGameState == gameState.inGame)
        {
            object.run(objectSequence)
            
        }
    }
    
    //This is the same as the other object, except it doesn't have a move function and is purely affected by gravity.
    func spawnGravityObject() {
        
        let randomXStart = random(min: 0, max: self.size.width)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        
        
        let objectType = balls.randomElement()!
        let object = SKSpriteNode(imageNamed: objectType)
        let objectRadius = object.frame.width / 2.0;
        
        
        object.position = startPoint
        object.name = objectType
        addChild(object)
        
        object.physicsBody = SKPhysicsBody(circleOfRadius: objectRadius)
        object.physicsBody?.allowsRotation = false
        object.physicsBody?.restitution = 0
        object.physicsBody?.friction = 0
        object.physicsBody?.affectedByGravity = true
        object.physicsBody?.categoryBitMask = PhysicsCategories.Ball
        object.physicsBody?.collisionBitMask = PhysicsCategories.None
        object.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        
        object.zPosition = 1
        
        
        
        let deleteObject = SKAction.removeFromParent()
        let waitToDelete = SKAction.wait(forDuration: 2)
        let objectSequence = SKAction.sequence([waitToDelete, deleteObject])
        
        object.run(objectSequence)
        
    }
    //For spawning our oops sprite.
    func spawnOops(spawnPosition: CGPoint)
    {
        
        if(currentGameState != gameState.afterGame)
        {
            let oops = SKSpriteNode(imageNamed: "omg")
            oops.position = spawnPosition
            oops.setScale(0.0)
            oops.zPosition = 3
            self.addChild(oops)
            
            let scaleIn = SKAction.scale(to: 1, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let delete = SKAction.removeFromParent()
            
            
            let oopsSequence = SKAction.sequence([scaleIn,fadeOut,delete])
            
            oops.run(oopsSequence)
        }
        
    }
    //Spawning our gameover Sprite
    func spawnGameOver(spawnPosition: CGPoint)
    {
        if(currentGameState != gameState.afterGame)
        {
        let gameover = SKSpriteNode(imageNamed: "gameover")
        gameover.position = spawnPosition
        gameover.setScale(0.0)
        gameover.zPosition = 3
        self.addChild(gameover)
        
        let scaleIn = SKAction.scale(to: 4, duration: 2)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let delete = SKAction.removeFromParent()
        
        
        let gameoverSequence = SKAction.sequence([scaleIn,fadeOut,delete])
        
        gameover.run(gameoverSequence)
        }
    }


    override func update(_ currentTime: TimeInterval) {
        
        //Change gravity according to ipad/iphone rotation
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y *  -50, dy: accelerometerData.acceleration.x * 50)
        }
        
        // If our gamestate changes, restart (call startNewLevel) to stop actions.
        if(currentGameState == gameState.afterGame)
        {
           let wait = SKAction.wait(forDuration: 2)
            
            let restart = SKAction.run(startNewLevel)
            let spawnSequence = SKAction.sequence([wait, restart])
            
            self.run(spawnSequence)
        
        }
    }
}
