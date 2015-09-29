//
//  FSImageView.swift
//  FastSlap
//
//  Created by Matthew Curtner on 9/29/15.
//  Copyright © 2015 Matthew Curtner. All rights reserved.
//

import UIKit

class FSImageView: UIImageView {
    
    var player: String?
    var activated: Bool! = false
    
    func setPlayer(player player: String) {
        self.player = player
                
        if activated == false {
            if player == "o" {
                print("O is player1")
            } else {
                print("X is player2")
            }
            activated = true
        }
    }

}
