//
//  FastSlapViewController.swift
//  FastSlap
//
//  Created by Matthew Curtner on 9/28/15.
//  Copyright © 2015 Matthew Curtner. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class FastSlapViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    @IBOutlet weak var playCardField: FSImageView!
    @IBOutlet weak var centerCardsField: FSImageView!
    
    
    var appDelegate: AppDelegate!
    var allCardsArray = [String]()
    var currentPlayer: String!

    var canPlay: Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(advertise: true)
        
        // Listen for state change notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRecievedDataNotification:", name: "MPC_DidRecieveDataNotification", object: nil)
        
        
        setupRecogonizer()
        currentPlayer = "o"

        addCardsToArray(letter1: "H", letter2: "C", letter3: "D", letter4: "S")

    }

    // MARK: - Game Setup Methods
    
    // Add card names to Array
    
    func addCardsToArray(letter1 letter1:String, letter2: String, letter3: String, letter4: String) {
        for index in 2...10 {
            self.allCardsArray.append("\(index)_\(letter1)")
            self.allCardsArray.append("\(index)_\(letter2)")
            self.allCardsArray.append("\(index)_\(letter3)")
            self.allCardsArray.append("\(index)_\(letter4)")
        }
    }
    
    // Remove all non numerical characters from string
    
    func getNumbersFromString(theString theString: String) -> Int {
        
        var strVal = theString
        strVal = strVal.stringByReplacingOccurrencesOfString(
            "\\D", withString: "", options: .RegularExpressionSearch,
            range: strVal.startIndex..<strVal.endIndex)
        
        return Int(strVal)!
    }
    
    
    func fieldTapped(recognizer: UITapGestureRecognizer) {
        let tappedField = recognizer.view as! FSImageView
        tappedField.setPlayer(player: currentPlayer)
        
        let messageDict = ["field": tappedField.tag, "player": currentPlayer]
        
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        try! appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        
        // TODO: Check Results
        
    }
    
    func setupRecogonizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "fieldTapped:")
        gestureRecognizer.numberOfTapsRequired = 1
        
        // Add gestureReconizer to Play Card Button
        playCardField.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    // MARK: - Action Methods
    
    @IBAction func connectWithPlayer(sender: AnyObject) {
        
        // Check if
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    // Player action to deal a single card
    
    @IBAction func dealCard(sender: AnyObject) {
        
        let randomNumber = arc4random_uniform(33) + 1
        let cardString = String(format: "%@", allCardsArray[Int(randomNumber)])
        
        print(cardString)
        
        // Set card image for button
        //centerCards.setBackgroundImage(UIImage(named: cardString), forState: .Normal)
    }
    
    // MARK: - NSNotification Selector Methods
    
    func peerChangedStateWithNotification(notification: NSNotification) {
        // Access userinfo object of the notification
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        // Get the State 
        let state = userInfo.objectForKey("state") as! Int
        
        // Check is successfully paired to devices
        if state != MCSessionState.Connecting.rawValue {
            // Display 'Connected'
            self.navigationItem.title = "Connected"
        } else {
            self.navigationItem.title = "Disconnected"
        }
    }

    
    func handleRecievedDataNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let recivedData: NSData = userInfo["data"] as! NSData
        
        let message = try! NSJSONSerialization.JSONObjectWithData(recivedData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        let senderPeerId: MCPeerID = userInfo["peerID"] as! MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        var player: String? = message.objectForKey("player") as? String
        
        
        if player != nil {
            
            print(player)
            
//            playCardField.player = player
//            playCardField.setPlayer(player: player!)
//            
//            print(player)
            
            // TODO: Check Result
        }
    }
    
    
    // MARK: - MCBrowserViewControllerDelegate Methods
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }

}
