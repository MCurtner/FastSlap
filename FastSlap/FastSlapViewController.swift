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
    
    
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(advertise: true)
        
        // Listen for state change notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRecievedDataNotification:", name: "MPC_DidRecieveDataNotification", object: nil)
    }

    
    @IBAction func connectWithPlayer(sender: AnyObject) {
        
        // Check if
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
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
