//
//  GameScene.swift
//  Platformer
//
//  Created by Skip Wilson on 7/25/14.
//  Copyright (c) 2014 Skip Wilson. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var currentLevel = 0
    var currentLevelData:NSDictionary
    var levels:Levels
    var bg:SKSpriteNode
    var man:SKSpriteNode
    var levelType:SKSpriteNode
    var manSpeed = 10
    var runningManTextures = [SKTexture]()
    var stageMaxLeft:CGFloat = 0
    var stageMaxRight:CGFloat = 0
    
    var manLeft = false
    var manRight = false
    
    
    override func didMoveToView(view: SKView) {
        stageMaxRight = self.size.width / 2
        stageMaxLeft = -stageMaxRight
        loadLevel()
    }
    
    func loadLevel() {
        currentLevelData = levels.data[currentLevel]
        loadBackground()
        loadLevelType()
        loadMan()
    }
    
    func loadBackground() {
        var bgNum = currentLevelData["bg"]! as String
        bg = SKSpriteNode(imageNamed: "bg_\(bgNum)")
        bg.name = "bg"
        bg.zPosition = 1.0
        scene.addChild(bg)
    }
    
    func loadLevelType() {
        var levelTypeInfo = currentLevelData["type"]! as String
        levelType = SKSpriteNode(imageNamed: levelTypeInfo)
        levelType.name = "level_type"
        levelType.position.y = -140
        levelType.zPosition = 2.0
        scene.addChild(levelType)
    }
    
    func loadMan() {
        loadManTextures()
        man.position.y -= man.size.height/2
        man.position.x = -(scene.size.width/2) + man.size.width * 2
        man.zPosition = 3.0
        addChild(man)
    }
    
    func loadManTextures() {
        var runningAtlas = SKTextureAtlas(named: "run")
        for i in 1...3 {
            var textureName = "run_\(i)"
            var temp = runningAtlas.textureNamed(textureName)
            runningManTextures.append(temp)
        }
    }
    
    func moveMan(direction:String) {
        if direction == "left" {
            manLeft = true
            man.xScale = -1
            manRight = false
            runMan()
        } else {
            manRight = true
            man.xScale = 1
            manLeft = false
            runMan()
        }
        
    }
    
    func runMan() {
        man.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(runningManTextures, timePerFrame: 0.2, resize:false, restore:true)))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if event.allTouches().count == 1 {
            let location = touches.anyObject().locationInNode(self)
            if location.x > 0 {
                moveMan("right")
            } else {
                moveMan("left")
            }
        } else {
            println("jump")
        }
    }
    
    func cancelMoves() {
        manLeft = false
        manRight = false
        man.removeAllActions()
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        cancelMoves()
    }
    
    init(size: CGSize) {
        self.currentLevel = 0
        self.currentLevelData = [:]
        self.levels = Levels()
        self.bg = SKSpriteNode()
        self.man = SKSpriteNode(texture: SKTexture(imageNamed: "run_0"))
        self.man.name = "man"
        self.levelType = SKSpriteNode()
        super.init(size: size)
    }
    
    func cleanScreen() {
        bg.removeFromParent()
        levelType.removeFromParent()
    }
    
    func nextScreen(level:Int) -> Bool {
        if level >= 0 && level < levels.data.count {
            currentLevel = level
            currentLevelData = levels.data[currentLevel]
            cleanScreen()
            loadBackground()
            loadLevelType()
            return true
        }
        return false
    }
    
    func updateManPosition() {
        if man.position.x < stageMaxLeft {
            if nextScreen(currentLevel - 1) {
                man.position.x = stageMaxRight
            }
            if manLeft {
                return
            }
        }
        if man.position.x > stageMaxRight {
            if nextScreen(currentLevel + 1) {
                man.position.x = stageMaxLeft
            }
            if manRight {
                return
            }
        }
        
        if manLeft {
            man.position.x -= manSpeed
        } else if manRight {
            man.position.x += manSpeed
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        updateManPosition()
    }
}
