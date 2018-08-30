//
//  ViewController.swift
//  FlappyBird
//
//  Created by tetsuro miyagawa on 2018/08/27.
//  Copyright © 2018年 tetsuro miyagawa. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let scene = GameScene(size:skView.frame.size)
        
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        get {return true}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

