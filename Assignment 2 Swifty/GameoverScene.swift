//
//  GameoverScene.swift
//  Assignment 2 Swifty
//
//  Created by Karl Zingel on 2022-04-13.
//

import Foundation
import SpriteKit


class GameOverScene: SKScene{
    
    let restartLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "game over")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(background)
        
        
        let gameOverLabel = SKLabelNode(fontNamed:"Baskerville Bold")
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 190
        gameOverLabel.fontColor = SKColor.magenta
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.8)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        
        let scoreLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        scoreLabel.text = "Final Score \(theScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.red
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.6)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
        let defaults = UserDefaults()
        
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        
        if(theScore > highScoreNumber)
        {
            highScoreNumber = theScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        highScoreLabel.text = "High Score \(highScoreNumber)"
        highScoreLabel.fontSize = 80
        highScoreLabel.fontColor = SKColor.purple
        highScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.1)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        
       
        restartLabel.text = "Restart Game"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.25)
        restartLabel.zPosition = 1
        addChild(restartLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            
            if(restartLabel.contains(pointOfTouch))
            {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transition)
            }
            
            
            
        }
    }
}
