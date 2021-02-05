//
//  WeakScriptMessageDelegate.swift
//  iOSShare
//
//  Created by matiastang on 2021/1/8.
//

import Foundation
import WebKit

class WeakWebViewScriptMessageDelegate: NSObject {
    
    private weak var webViewDelegate:WKScriptMessageHandlerWithReply?
    
    init(_ delegate: WKScriptMessageHandlerWithReply) {
        webViewDelegate = delegate
    }
}

extension WeakWebViewScriptMessageDelegate: WKScriptMessageHandlerWithReply {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        self.webViewDelegate?.userContentController(userContentController, didReceive: message, replyHandler: replyHandler)
    }
}
