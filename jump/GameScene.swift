//
//  GameScene.swift
//  jump
//
//  Created by papaya on 16/4/15.
//  Copyright (c) 2016年 Li Haomiao. All rights reserved.
//

import SpriteKit
enum layerLeve:CGFloat {
    case ground
    case hinder
    case mainGharacter
}

enum phyLevel{
    static let noting:UInt32 = 0
    static let mainCharacter:UInt32 = 0b1
    static let floor:UInt32 = 0b10
    static let wall:UInt32 = 0b100
}

enum gameStatu {
    case gameing
    case gameover
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let kGravity: CGFloat = -600.0
    let kUpSpeed: CGFloat = 400.0
    let kSceneMoveSpeed:CGFloat = -108.0
    let game = SKNode()
    let mainGharacter = SKSpriteNode(imageNamed:"people")
    let hinder = SKSpriteNode(imageNamed: "backss")
    let kMakeNewHinderTime:NSTimeInterval = 0.5
    let kFirstTimeShowInfiniteHinder:NSTimeInterval = 1.5
    
    var contactLeft:CGFloat = 0.0
    var contactRight:CGFloat = 0.0
    
    var contactHinderX:CGFloat = 0.0
    var preHinder = SKSpriteNode(imageNamed: "backss")
    var preHinderHidden:Bool = true
    var initHeight:CGFloat = 0.0
    var mainCharacterspeed = CGPoint.zero
    var isLand = true
    var dt:NSTimeInterval = 0
    var lastUpdateTime:NSTimeInterval = 0.0
    var hasContact:Bool = false
    var floorX:CGFloat = 0.0
    var gameStatus:gameStatu = .gameing
    var canrestart:Bool = false
    var isAheadHinder:Int = -1
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        self.backgroundColor = UIColor.blueColor()
        addChild(game)
        initHinder()
        creatMainGharacter()
        creatInfiniteHinder()
    }
    
    //MARK:创建
    
    func creatHinder() -> SKSpriteNode {
       let hinder = SKSpriteNode(imageNamed: "backss")
        hinder.zPosition = layerLeve.hinder.rawValue
        hinder.userData = NSMutableDictionary()
        
        let offsetX = hinder.size.width * hinder.anchorPoint.x
        let offsetY = hinder.size.height * hinder.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0 - offsetX, 311 - offsetY)
        CGPathAddLineToPoint(path, nil, 53 - offsetX, 311 - offsetY)
        CGPathAddLineToPoint(path, nil, 53 - offsetX, 1 - offsetY)
        CGPathAddLineToPoint(path, nil, 1 - offsetX, 0 - offsetY)
        
        CGPathCloseSubpath(path)
        hinder.physicsBody = SKPhysicsBody(polygonFromPath: path)
        hinder.physicsBody?.categoryBitMask = phyLevel.wall
        hinder.physicsBody?.collisionBitMask = 0
        hinder.physicsBody?.contactTestBitMask = phyLevel.mainCharacter
        return hinder
    }
    
    //生成障碍物
    func makeHinder() {
        let hinder = creatHinder()
        hinder.name = "hinder"
        let beginX = size.width + hinder.size.width/2
        var randomUP = CGFloat.random(min:-30, max:30)
        //防止障碍物过高或者
        if  preHinder.position.y + randomUP <= hinder.size.height / 2 {
            randomUP = randomUP + 30
        }else if preHinder.position.y + randomUP > size.height * 0.5{
            randomUP = randomUP - 30
        }
        
        isAheadHinder = (isAheadHinder + 1 ) % 3
        switch isAheadHinder {
        case 0:
            preHinderHidden = true
        case 1:
            preHinderHidden = true
            randomUP = 0
        default:
            preHinderHidden = false
        }
        
        let poistionY = preHinder.position.y + randomUP
        hinder.position = CGPointMake(beginX,poistionY)
        let randomVar = Int.random(min:0,max:1)
        let boolvar = (randomVar == 1) ? true : true
        if boolvar == true && preHinderHidden != true{
            preHinderHidden = true
            preHinder = hinder
            print("\(preHinder.position.x) and \(preHinder.position.y)")
        }else{
            preHinderHidden = false
            game.addChild(hinder)
            let xMoveDistance:CGFloat = -(size.width+hinder.size.width)
            let xMoveTime = xMoveDistance / kSceneMoveSpeed
            let xMoveQueue = SKAction.sequence([
                SKAction.moveByX(xMoveDistance, y: 0, duration: NSTimeInterval(xMoveTime)),
                SKAction.removeFromParent()
                ])
            hinder.runAction(xMoveQueue)
            preHinder = hinder
        }
        
    }
    
    //无限生成障碍物
    func  creatInfiniteHinder() {
        let firstShowInfiniteHinder = SKAction.waitForDuration(kFirstTimeShowInfiniteHinder)
        let oneHinder = SKAction.runBlock { () -> Void in
            self.makeHinder()
        }
        let makeOneHinderTime = SKAction.waitForDuration(kMakeNewHinderTime)
        let makeHinderQueue = SKAction.sequence([oneHinder,makeOneHinderTime])
        let infinite = SKAction.repeatActionForever(makeHinderQueue)
        let infinteQueue = SKAction.sequence([firstShowInfiniteHinder,infinite])
        runAction(infinteQueue, withKey: "infinte")
    }
    
    //创建主角
    func creatMainGharacter(){
        mainGharacter.position = CGPointMake(size.width*0.2, initHeight+mainGharacter.size.height/2)
        let offsetX = mainGharacter.size.width * mainGharacter.anchorPoint.x
        let offsetY = mainGharacter.size.height * mainGharacter.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 1 - offsetX, 33 - offsetY)
        CGPathAddLineToPoint(path, nil, 19 - offsetX, 33 - offsetY)
        CGPathAddLineToPoint(path, nil, 19 - offsetX, 0 - offsetY)
        CGPathAddLineToPoint(path, nil, 0 - offsetX, 0 - offsetY)
        
        CGPathCloseSubpath(path)
        
        mainGharacter.physicsBody = SKPhysicsBody(polygonFromPath: path)
        mainGharacter.physicsBody?.categoryBitMask = phyLevel.mainCharacter
        mainGharacter.physicsBody?.collisionBitMask = 0
        mainGharacter.physicsBody?.contactTestBitMask = phyLevel.floor | phyLevel.wall
        game.addChild(mainGharacter)
    }
    
    
    //MARK: init
    
    func initHinder()  {
        let k:Int = (Int)(size.width / hinder.size.width) + (size.width % hinder.size.width != 0 ? 1: 0)
        
        for i in 0...k {
            let hinder = creatHinder()
            hinder.name = "hinder"
            let width = hinder.size.width
            hinder.position = CGPointMake(width * CGFloat(i) + hinder.size.width / 2, (hinder.size.height / 2) * 0.2 )
            initHeight = (hinder.size.height/2)*0.2 + hinder.size.height/2
            floorX = initHeight
            game.addChild(hinder)
            
            let moveLength = -(size.width + hinder.position.x)
            let moveTime = moveLength / kSceneMoveSpeed
            let moveQueue = SKAction.sequence([
                SKAction.moveByX(moveLength, y: 0, duration: NSTimeInterval(moveTime)),
                SKAction.removeFromParent()
                ])
            hinder.runAction(moveQueue)
            
            if ( i == k - 1 ){
                preHinder = hinder
            }
        }
    }
    
    //MARK: action
    //跳一下
    func jump() {
        mainCharacterspeed = CGPoint(x: 0, y: kUpSpeed)
        
    }
    
    //MARK: updata
    //更新主角
    func updateMainCharacter(){
        let addSpeed = CGPoint(x: 0, y: kGravity)
        mainCharacterspeed = mainCharacterspeed + addSpeed * CGFloat(dt)
        mainGharacter.position = mainGharacter.position + mainCharacterspeed * CGFloat(dt)
        floorX = 0.0
        game.enumerateChildNodesWithName("hinder", usingBlock: { match,_ in
            if let hinder = match as? SKSpriteNode{
                let left = hinder.position.x - hinder.size.width/2
                let right = hinder.position.x + hinder.size.width/2
                if  self.mainGharacter.position.x >= left && self.mainGharacter.position.x <= right {
                    self.floorX = hinder.position.y + hinder.size.height/2
                }
            }

        })
        if mainGharacter.position.y <= floorX+mainGharacter.size.height/2{
            isLand = true
            mainGharacter.position = CGPoint(x: size.width*0.2, y: floorX+mainGharacter.size.height/2)
        }
        
    }
    
    func updateFloorX() {
        game .enumerateChildNodesWithName("hinder", usingBlock: {match, _ in
            if let hinder = match as? SKSpriteNode{
                let left = hinder.position.x - hinder.size.width/2
                let right = hinder.position.x + hinder.size.width/2
                let top = hinder.position.y + hinder.size.height/2 + self.mainGharacter.size.height/2 - 3.5
                print("\(hinder.position.x)  or \(self.contactHinderX)")
                print("\(self.mainGharacter.position.y)  and \(top)")
                if self.mainGharacter.position.y < top && (Int)(hinder.position.x) == (Int)(self.contactHinderX){
                    self.gameStatus = .gameover
                }else if  self.mainGharacter.position.x >= left && self.mainGharacter.position.x <= right {
                    self.contactLeft = left
                    self.contactRight = right
                    self.floorX = hinder.position.y + hinder.size.height/2
                    self.hasContact = false
                }
                
            }
        })
    }
    
    func stopGame() {
        removeActionForKey("infinte")
        game.enumerateChildNodesWithName("hinder", usingBlock: {match, _ in
            match.removeAllActions()
        })
        canrestart = true
    }
    //MARK: status
    func isAtLand() -> Bool {
        //print("\( mainGharacter.position.y)   \(initHeight+mainGharacter.size.height/2)")
        if mainGharacter.position.y <= self.floorX+mainGharacter.size.height/2 + 0.5{
            return true
        }
        return false

    }
    
    func restartGame() {
        let gameScene = GameScene.init(size: size)
        let restart = SKTransition.fadeWithColor(SKColor.greenColor(), duration: 0.05)
        view?.presentScene(gameScene  , transition: restart)
        canrestart = false
    }
    
    // MARK:SYSTEM
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if ( isLand ){
            
        }
        if isAtLand(){
            jump()
        }
        if canrestart{
            restartGame()
        }
      
    }
   
    override func update(currentTime: CFTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }else{
            dt = 0
        }
        lastUpdateTime = currentTime
                switch gameStatus {
        case .gameing:
            updateFloorX()
            updateMainCharacter()
            break
        default:
            stopGame()
        }
    }
    
    //MARK:碰撞检测
    func didBeginContact(contact: SKPhysicsContact) {
        let contactA = contact.bodyA.categoryBitMask == phyLevel.mainCharacter ? contact.bodyB : contact.bodyA
        if  contactA.categoryBitMask == phyLevel.wall {
            contactHinderX =  contactA.node!.position.x
            hasContact = true
        }
    }
}
