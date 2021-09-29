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
    var ground: SKSpriteNode?
    var ceil: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    
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
        
        
        ground = childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ground?.physicsBody?.collisionBitMask = coinManCategory
        
        ceil = childNode(withName: "ground") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = coinManCategory

        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.position = CGPoint(x: -size.width/2+80, y: size.height/2 - 80)
        
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.createCoin()
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  
        //apply force to the object
        coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
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
        SKAction.sequence([moveLeft,SKAction.removeFromParent()])
        //apply action
        coin.run(SKAction.sequence([moveLeft,SKAction.removeFromParent()]))
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        score += 1
        scoreLabel?.text = "Score: \(score)"
        
        // Checking for both bodies as we do not know which one is coin
        if contact.bodyA.categoryBitMask == coinCategory{
            contact.bodyA.node?.removeFromParent()
        }
        if contact.bodyB.categoryBitMask == coinCategory{
            contact.bodyB.node?.removeFromParent()
        }
    }

}
