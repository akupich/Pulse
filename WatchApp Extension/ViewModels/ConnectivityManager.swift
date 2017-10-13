//
//  ConnectivityManager.swift
//  WatchApp Extension
//
//  Created by Andriy Kupich on 10/10/17.
//  Copyright © 2017 Remit. All rights reserved.
//

import WatchConnectivity

class ConnectivityManager: NSObject, WCSessionDelegate {
    var session : WCSession?
    
    override init() {
        super.init()
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
    
    func sendInfo(_ data:Any, for key: String) {
        session?.transferUserInfo([key:data])
    }
}
