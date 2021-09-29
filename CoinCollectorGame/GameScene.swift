//
//  GameScene.swift
//  CoinCollectorGame
//
//  Created by Anton Veldanov on 9/28/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var coinMan: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        
        createCoin()

    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  
        //apply force to the object
        coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
    }
    
    
    func createCoin(){
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 128, height: 128)
        addChild(coin)
        
        let moveLeft = SKAction.moveBy(x: -300, y: 0, duration: 2)
    }

}
