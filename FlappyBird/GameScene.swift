//
//  GameScene.swift
//  FlappyBird
//
//  Created by tetsuro miyagawa on 2018/08/27.
//  Copyright © 2018年 tetsuro miyagawa. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
    var scrollNode: SKNode!
    var wallNode: SKNode!
    var birdNode: SKSpriteNode!
    var itemNode: SKSpriteNode!
    
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4
    //32ビットで<<は桁をずらす
    
    var score = 0//スコア
    var itemScore = 0
    let userDefaults: UserDefaults = UserDefaults.standard//userDefaults
    var scoreLabelNode: SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!
    var itemScoreLabelNode: SKLabelNode!
    var goLabelNode: SKLabelNode!//ラベルノード
    
    var audioPlayer: AVAudioPlayer!
    var bgmAudioPlayer: AVAudioPlayer!
    
    
    //didMove はviewが読み込まれた時
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)//背景
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        //SpriteKitにあるphysicsWorldで重力
        physicsWorld.contactDelegate = self
        //当たり判定デリゲートをselfで委託
        
        scrollNode = SKNode()
        addChild(scrollNode) //どこにaddChildしたのか
        //動きを止めるための表示しないスプライト
        
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        itemNode = SKSpriteNode()
        scrollNode.addChild(itemNode)
        
        let bgmAudioPath = Bundle.main.path(forResource: "bgm1", ofType:"mp3")!
        let bgmAudioUrl = URL(fileURLWithPath: bgmAudioPath)
        bgmAudioPlayer = try! AVAudioPlayer(contentsOf: bgmAudioUrl)
        bgmAudioPlayer.play()
        
        
        SetUpGround()
        SetUpCloud()
        SetUpWall()
        SetUpBird()
        SetUpScoreLabel()
        SetUpItem()
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
        // 鳥の速度をゼロにする
        birdNode.physicsBody?.velocity = CGVector.zero
        // 鳥に縦方向の力を与える
        birdNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }else if birdNode.speed == 0 {
            restart()
        }
        
    }

    
    func SetUpGround(){
        
        let groundTexture = SKTexture(imageNamed: "ground")
        //SKTextureで画像読み込み
        groundTexture.filteringMode = .nearest
        //画質優先（.liner）か速度優先(.nearest)か
        
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        //何個必要か
        
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5.0)
        //うごかす
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
        //もどす
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        //連続させる
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            //スプライト化
            sprite.position = CGPoint(x: groundTexture.size().width * (0.5 + CGFloat(i)), y: groundTexture.size().height * 0.5)//位置をずらして配置
            
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            //()内で大きさを指定して物理演算を設定
            sprite.physicsBody?.categoryBitMask = self.groundCategory
            sprite.physicsBody?.isDynamic = false
            
            sprite.run(repeatScrollGround)
            //動かすrun
            scrollNode.addChild(sprite)
            //scrollNodeに追加
        }
    }
    
    func SetUpCloud(){
        
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        let needNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20.0)
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        for i in 0..<needNumber{
        let sprite = SKSpriteNode(texture: cloudTexture)
        sprite.zPosition = -100
            
        sprite.position = CGPoint(x: cloudTexture.size().width * (0.5 + CGFloat(i)) , y: self.frame.size.height - cloudTexture.size().height * 0.5)
            
        sprite.run(repeatScrollCloud)
        scrollNode.addChild(sprite)
            
        }
        
    }
    
    func SetUpWall(){
        
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        let moveingDistance = Int(self.frame.size.width + wallTexture.size().width)
        let moveWall = SKAction.moveBy(x: -(CGFloat(moveingDistance)), y: 0, duration: 4.0)
        let removeWall = SKAction.removeFromParent()
        let repeatScrollWall = SKAction.repeatForever(SKAction.sequence([moveWall, removeWall]))

        let createWallAnimation = SKAction.run({
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width, y: 0)
            wall.zPosition = -50.0
            
            let center_y = self.frame.size.height / 2
            let random_y_range = self.frame.size.height / 4
            let under_wall_lowest_y = UInt32(center_y - wallTexture.size().height / 2 - random_y_range / 2)
            let random_y = arc4random_uniform(UInt32(random_y_range))
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            let slit_length = self.frame.size.height / 6
            
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            //under
            
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + slit_length + wallTexture.size().height)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            //upper
            
            //scorenode//
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.birdNode.size.width / 2, y: self.frame.height / 2.0 )
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            //scorenode//
            
            wall.run(repeatScrollWall)
            self.wallNode.addChild(wall)
            
        })
        
        
        let waitAnimaton = SKAction.wait(forDuration: 2)
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimaton]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func SetUpBird(){
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        //textureにする
        
        let textureAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(textureAnimation)
        //動きをつくる
        
        birdNode = SKSpriteNode(texture: birdTextureA)
        birdNode.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        //textureをスプライト（画像）ノードにして動くようにする
        
        birdNode.physicsBody = SKPhysicsBody(circleOfRadius: birdNode.size.height / 2)
        birdNode.physicsBody?.allowsRotation = false
        
        birdNode.physicsBody?.categoryBitMask = birdCategory //自分のカテゴリは？
        birdNode.physicsBody?.contactTestBitMask = groundCategory | wallCategory//ぶつかる相手
        birdNode.physicsBody?.collisionBitMask = groundCategory | wallCategory //当たった時に跳ね返る
        
        birdNode.run(flap)
        //ノードに動きを加える
        
        addChild(birdNode)
        //できたものをノードとして登録
        
    }
    
    func SetUpItem(){
        
        let itemTexture = SKTexture(imageNamed: "item")
        itemTexture.filteringMode = .nearest
        
        let a = SKAction.moveBy(x: -(self.frame.size.width + itemTexture.size().width), y: 0.0, duration: 4.0)
        let b = SKAction.removeFromParent()
        let itemMove = SKAction.repeatForever(SKAction.sequence([a, b]))
        
        let createItemAnimation = SKAction.run({
            
            let item = SKNode()
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width, y: 0)
            item.zPosition = -70
            
            let center_y = self.frame.size.height / 2
            let random_y_range = self.frame.size.height / 4
            let under_item_lowest_y = UInt32(center_y - itemTexture.size().height / 2 - random_y_range / 2)
            let random_y = arc4random_uniform(UInt32(random_y_range))
            let under_item_y = CGFloat(under_item_lowest_y + random_y)
            
            let orange = SKSpriteNode(texture: itemTexture)
            orange.position = CGPoint(x: 0.0, y: under_item_y)
            
            orange.physicsBody = SKPhysicsBody(circleOfRadius: itemTexture.size().height / 2)
            orange.physicsBody?.categoryBitMask = self.itemCategory
            orange.physicsBody?.isDynamic = false
            orange.physicsBody?.contactTestBitMask = self.birdCategory
            
            item.addChild(orange)
            
            item.run(itemMove)
            self.itemNode.addChild(item)
        })
        
        let waitAnimaton = SKAction.wait(forDuration: 5.0)
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimaton]))
        
        itemNode.run(repeatForeverAnimation)
        
    }
    
    func SetUpScoreLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.zPosition = 100
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "SCORE: \(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "BestSCORE: \(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item: \(itemScore)"
        self.addChild(itemScoreLabelNode)
        
    }
    
    func SetUpgoLabel(){
        goLabelNode = SKLabelNode()
        goLabelNode.fontColor = UIColor.red
        goLabelNode.zPosition = 100
        goLabelNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        goLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        goLabelNode.text = "GAME OVER"
        self.addChild(goLabelNode)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if scrollNode.speed <= 0.0 {
            return
        }
        
        if(contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            print("ScoreUP")
            score += 1
            scoreLabelNode.text = "SCORE: \(score)"
            
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "BestSCORE: \(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }//integerで取得、setで保存、シンクロで同期（しないとすぐ保存されない）
            
        }else if(contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
            print("ItemGet")
            itemScore += 1
            
            /*audio------------*/
            let audioPath = Bundle.main.path(forResource: "cursor7", ofType:"mp3")!
            let audioUrl = URL(fileURLWithPath: audioPath)
            audioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer.play()
            /*audio------------*/
            
            itemScoreLabelNode.text = "Item: \(itemScore)"
            itemNode.removeAllChildren() //?
            
            
        }else{
            
            SetUpgoLabel()
            scrollNode.speed = 0
            
            bgmAudioPlayer.stop()//bgm
            
            birdNode.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(birdNode.position.y) * 0.01, duration:1)
            birdNode.run(roll, completion:{
                self.birdNode.speed = 0
            })
        }
        
    }
    
    func restart(){
        score = 0
        itemScore = 0
        scoreLabelNode.text = "SCORE: \(score)"
        itemScoreLabelNode.text = "Item: \(itemScore)"
        goLabelNode.text = ""
        birdNode.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        birdNode.physicsBody?.velocity = CGVector.zero
        birdNode.physicsBody?.collisionBitMask = groundCategory | wallCategory
        birdNode.zRotation = 0.0
        
        bgmAudioPlayer.play()//bgm
        
        wallNode.removeAllChildren()
        
        birdNode.speed = 1
        scrollNode.speed = 1
    }
    
    

    
}
