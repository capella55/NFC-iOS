//
//  ViewController.swift
//  Posithive
//
//  Created by Admin on 8/26/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import WebKit
import CoreNFC

class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    var session: NFCNDEFReaderSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let link = URL(string: "http://dev.posithive.co.uk:8283") {
            let request = URLRequest(url: link)
            webView.load(request)
        }
    }
    
    @IBAction func onLoginWithNFCTag(_ sender: UIButton) {
        if NFCNDEFReaderSession.readingAvailable {
            session?.invalidate()
            session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue(label: "nfcQueue", attributes: .concurrent), invalidateAfterFirstRead: false)
            session?.alertMessage = "Hold your iPhone near the item to learn more about it."
            session?.begin()
        }
        else {
            let alert = UIAlertController.init(title: "Posithive", message: "Your device does not support NFC reader.", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "OK", style: .destructive, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        if let message = messages.first {
            if let record = message.records.first {
                if let payload = String(data: record.payload, encoding: .utf8) {
                    loginWithPayload(payload)
                }
            }
        }
    }
    
    func loginWithPayload(_ payload: String) {
        session?.invalidate()
        DispatchQueue.main.async {
            let javascript = "loginFromPhone('\(payload)')"
            print(javascript)
            self.webView.evaluateJavaScript(javascript, completionHandler: nil)
        }
    }
}

