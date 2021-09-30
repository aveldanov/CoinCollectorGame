//
//  GameScene.swift
//  CoinCollectorGame
//
//  Created by Anton Veldanov on 9/28/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var coinMan: SKSpriteNode?
    var coinTimer: Timer?
    var bombTimer: Timer?
//    var ground: SKSpriteNode?
    var ceil: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    var yourScoreLabel: SKLabelNode?
    var finalScoreLabel: SKLabelNode?
    
    // total can creat 32 categories when use UInt32
    /*
     The category on SpriteKit is just a single 32-bit integer, acting as a bitmask. This is a fancy way of saying each of the 32-bits in the integer represents a single category (and hence you can have 32 categories max)
     */
    let coinManCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let groundAndCeilCategory: UInt32 = 0x1 << 4
    
    var score = 0
    
    override func didMove(to view: SKView) {
        //create physicsWorld
        physicsWorld.contactDelegate = self
        
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        
        //assign category to coinMan
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        //assign coinMan to CONTACT! with
        coinMan?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        // to avoid actual collisions ( move coinMan off the screen)
        coinMan?.physicsBody?.collisionBitMask = groundAndCeilCategory // coinMan to collide with ground and ceiling
        
        // CoinMan Animation
        var coinManRun: [SKTexture] = []
        for num in 0..<43{
            if num >= 0 && num <= 9{
                coinManRun.append(SKTexture(imageNamed: "run_00\(num)"))
            }else{
                coinManRun.append(SKTexture(imageNamed: "run_0\(num)"))
            }
            
        }
        // Animation
        let animation = SKAction.animate(with: coinManRun, timePerFrame: 0.015)
        let animationAction = SKAction.repeatForever(animation)
        coinMan?.run(animationAction)
        
        
//        ground = childNode(withName: "ground") as? SKSpriteNode
//        ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
//        ground?.physicsBody?.collisionBitMask = coinManCategory
        
        ceil = childNode(withName: "ground") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = coinManCategory

        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.position = CGPoint(x: -size.width/2+80, y: size.height/2 - 80)
        

        startTimers()
        createGrass()
    }
    
    
    func createGrass(){
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width/sizingGrass.size.width) + 1
        
        for num in 0...numberOfGrass{
            let grass = SKSpriteNode(imageNamed: "grass")

//            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: grass.size.width, height: grass.size.height-80))
            
            grass.physicsBody?.categoryBitMask = groundAndCeilCategory
            grass.physicsBody?.collisionBitMask = coinManCategory
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.isDynamic = false //so it won't bounce back
            addChild(grass)
            
            let grassX = -size.width/2 + grass.size.width/2 + grass.size.width*CGFloat(num)
            
            grass.position = CGPoint(x: grassX, y: -size.height/2+grass.size.height/2-15)
            
            
            // adding speed for the grass to have the same speed no matter the location on the view...as it goes different time for the entire screen vs from left side to deepleft
            let speed = 100
            let moveLeft = SKAction.moveBy(x: -grass.size.width-grass.size.width*CGFloat(num), y: 0, duration: TimeInterval((grass.size.width+grass.size.width*CGFloat(num))/Double(speed)) )
            
            grass.run(moveLeft)
        }
        
        
    }
    
    func startTimers(){
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.createCoin()
        })
        
        bombTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { timer in
            self.createBomb()
        })
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  
        if scene?.isPaused == false {
            //apply force to the object
            coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
        }
        

        
        
        
        
        // RESTART Button actions
        let touch = touches.first
        // self -> touches inside of the scene
        if let location = touch?.location(in: self){
            let nodesPicked = nodes(at: location)
            
            for node in nodesPicked{
                // touched the game button
                if node.name == "play"{
                    // Restard Game
                    score = 0
                    node.removeFromParent() // removed Play button
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    startTimers()
                }
                
            }
        }
    }

    func createCoin(){
        let coin = SKSpriteNode(imageNamed: "coin")
        // by default coin has no physics body so we have to create it
        
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        addChild(coin)
        
        // height 1334 width 750
        let maxY = size.height/2 - coin.size.height/2
        let minY = -size.height/2 + coin.size.height/2
        
        let range = maxY-minY
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        

        coin.position = CGPoint(x: size.width/2, y: coinY)

        //create aciton
        let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: 4)
        
        // Sequence of actions in array
        SKAction.sequence([moveLeft, SKAction.removeFromParent()])
        //apply action
        coin.run(SKAction.sequence([moveLeft,SKAction.removeFromParent()]))
    }
    
    
    func createBomb(){
        let bomb = SKSpriteNode(imageNamed: "bomb")
        // by default coin has no physics body so we have to create it
        
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        addChild(bomb)
        
        // height 1334 width 750
        let maxY = size.height/2 - bomb.size.height/2
        let minY = -size.height/2 + bomb.size.height/2
        
        let range = maxY-minY
        let bombY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        

        bomb.position = CGPoint(x: size.width/2, y: bombY)

        //create aciton
        let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: 4)
        
        // Sequence of actions in array
        SKAction.sequence([moveLeft,SKAction.removeFromParent()])
        //apply action
        bomb.run(SKAction.sequence ([moveLeft,SKAction.removeFromParent()]))
        
        
    }

    
    
    func didBegin(_ contact: SKPhysicsContact) {
        

        
        // Checking for both bodies as we do not know which one is coin
        if contact.bodyA.categoryBitMask == coinCategory{
            contact.bodyA.node?.removeFromParent()
            scoreUp()
        }
        if contact.bodyB.categoryBitMask == coinCategory{
            contact.bodyB.node?.removeFromParent()
            scoreUp()
        }
        
        if contact.bodyA.categoryBitMask == bombCategory{
            print("Game OverA")
            contact.bodyA.node?.removeFromParent()
            gameOver()
        }
        
        if contact.bodyB.categoryBitMask == bombCategory{
            print("Game OverB")
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
    }
    
    func gameOver(){
        
        scene?.isPaused = true
        yourScoreLabel = SKLabelNode(text: "Your Score:")
        guard let yourScoreLabel = yourScoreLabel else{
            return
        }
        addChild(yourScoreLabel)
        yourScoreLabel.zPosition = 1 // default is 0 (back)
        yourScoreLabel.position = CGPoint(x: 0, y: 200)
        yourScoreLabel.fontSize = 100
        
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        guard let finalScoreLabel = finalScoreLabel else {
            return
        }
        addChild(finalScoreLabel)
        finalScoreLabel.zPosition = 1
        finalScoreLabel.position = CGPoint(x: 0, y: 0)
        finalScoreLabel.fontSize = 200
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
        
        coinTimer?.invalidate()
        bombTimer?.invalidate()
    }
    
    func scoreUp(){
        score += 1
        scoreLabel?.text = "Score: \(score)"
    }

}
