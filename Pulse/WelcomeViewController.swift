//
//  ViewController.swift
//  Pulse
//
//  Created by Andriy Kupich on 10/5/17.
//  Copyright © 2017 Remit. All rights reserved.
//

import UIKit
import WatchConnectivity

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    var session : WCSession? {
        didSet {
            session?.delegate = self
            session?.activate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = WCSession.default
    }
    
    func animateHeart () {
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = NSNumber(value: 0.5)
        pulseAnimation.toValue = NSNumber(value: 1.0)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
        heartImageView.layer.add(pulseAnimation, forKey: "heartAnimation")
    }
}

extension WelcomeViewController : WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        heartImageView.layer.removeAllAnimations()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        heartImageView.layer.removeAllAnimations()
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        if error == nil {
            animateHeart ()
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        guard let heartRateValue = userInfo[Constants.kHeartRateKey] as? Double  else{
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if heartRateValue > Constants.kHeartRateAccessValue {
                self?.performSegue(withIdentifier: "showHome", sender: nil)
                return
            }
            
            self?.hintLabel.text = "Your heart rate is too low. Over \(Constants.kHeartRateAccessValue) BPM is required... try harder."
            self?.heartRateLabel.text = "\(heartRateValue) BPM"
        }
    }
}

