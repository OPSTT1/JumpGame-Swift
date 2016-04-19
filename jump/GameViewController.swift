//
//  GameViewController.swift
//  jump
//
//  Created by papaya on 16/4/15.
//  Copyright (c) 2016年 Li Haomiao. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let skView = self.view as? SKView{
            if skView.scene == nil {
                let lengthAndWidth = skView.bounds.height / skView.bounds.size.width
                let secne = GameScene(size: CGSize(width: 320, height: 320*lengthAndWidth))
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.showsPhysics = true
                skView.ignoresSiblingOrder = true
                
                secne.scaleMode = .AspectFill
                skView.backgroundColor = UIColor.blueColor()
                skView.presentScene(secne)
            }
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
