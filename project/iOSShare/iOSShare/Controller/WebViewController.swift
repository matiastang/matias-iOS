//
//  WebViewController.swift
//  iOSShare
//
//  Created by matiastang on 2021/1/8.
//

import UIKit
import WebKit
import JavaScriptCore

class WebViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    deinit {
        print("销毁")
    }
}

// MARK: - JavaScriptCore相关
extension WebViewController {
    
    /*
     JSContext：JSContext是JS的执行环境，通过evaluateScript()方法可以执行JS代码
     JSValue：  JSValue封装了JS与ObjC中的对应的类型，以及调用JS的API等
     JSExport： JSExport是一个协议，遵守此协议，就可以定义我们自己的协议，
                在协议中声明的API都会在JS中暴露出来，这样JS才能调用原生的API
         OC Swift type        |    JavaScript type
    ---------------------------------------------------
             nil              |      undefined
            NSNull            |        null
        NSString String       |       string
           NSNumber           |    number, boolean
     NSDictionary Dictionary  |     Object object
         NSArray Array        |      Array object
            NSDate            |       Date object
          NSBlock (1)         |   Function object (1)
            id (2)            |    Wrapper object (2)
           Class (3)          | Constructor object (3)
     */
    private func javaScriptRun(_ webView: WKWebView) {
//        //        获取JS代码的执行环境/上下文/作用域
//                let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext")
//        //        监听JS代码里面的jsToOc方法（执行效果上可以理解成重写了JS的jsToOc方法）
//                context["divReload"] = (action: String, params: String) {
//                    print(<#T##items: Any...##Any#>)
//                }
        javaScriptCoreTest()
        setContext(webView)
    }
    
    private func javaScriptCoreTest() {
        let context: JSContext = JSContext()
        let result1: JSValue = context.evaluateScript("1 + 3")
        print(result1)  // 输出4
            
        // 定义js变量和函数
        context.evaluateScript("var num1 = 10; var num2 = 20;")
        context.evaluateScript("function multiply(param1, param2) { return param1 * param2; }")
            
        // 通过js方法名调用方法
        let result2 = context.evaluateScript("multiply(num1, num2)")
        print(result2 ?? "result2 = nil")  // 输出200
            
        // 通过下标来获取js方法并调用方法
        let squareFunc = context.objectForKeyedSubscript("multiply")
        let result3 = squareFunc?.call(withArguments: [10, 20]).toString()
        print(result3 ?? "result3 = nil")  // 输出200
    }
    
    func setContext(_ webView: WKWebView){
        guard let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext else {
            return
        }
            
        let model = SwiftJavaScriptModel()
        model.controller = self
        model.jsContext = context
        
        // 这一步是将SwiftJavaScriptModel模型注入到JS中，在JS就可以通过WebViewJavascriptBridge调用我们暴露的方法了。
        context.setObject(model, forKeyedSubscript: "WebViewJavascriptBridge" as NSCopying & NSObjectProtocol)
        
        // 注册到网络Html页面 请设置允许Http请求
        let curUrl = webView.url?.absoluteString  // WebView当前访问页面的链接 可动态注册
        context.evaluateScript(curUrl)
        // 异常回调
        context.exceptionHandler = { (context, exception) in
            guard let excep = exception else {
                return
            }
            print(excep)
            /*
                此处打印js异常错误，JSContext不会主动抛出js异常。
                比如：
                1、ReferenceError: Can't find variable:
                2、TypeError: undefined is not an object
                ...
            */
            context?.exception = excep
        }
    }
}

// 定义协议SwiftJavaScriptDelegate 该协议必须遵守JSExport协议
//@objc protocol SwiftJavaScriptDelegate: JSExport {
//
//    // js调用App的返回方法
//    func popVC()
//
//    // js调用App的showDic。传递Dict 参数
//    func showDic(_ dict: [String: AnyObject])
//
//    // js调用App方法时传递多个参数 并弹出对话框 注意js调用时的函数名
//    func showDialog(_ title: String, message: String)
//
//    // js调用App的功能后 App再调用js函数执行回调
//    func callHandler(_ handleFuncName: String)
//
//}

// 定义一个模型 该模型实现SwiftJavaScriptDelegate协议
//@objc class SwiftJavaScriptModel: NSObject {
//
//    weak var controller: UIViewController?
//    weak var jsContext: JSContext?
//}

//extension SwiftJavaScriptModel: SwiftJavaScriptDelegate {
//
//    func popVC() {
//        if let vc = controller {
//            DispatchQueue.main.async {
//                vc.navigationController?.popViewController(animated: true)
//            }
//
//        }
//    }
//
//    func showDic(_ dict: [String: AnyObject]) {
//
//        print("展示信息：", dict,"= = ")
//
//        // 调起微信分享逻辑
//        callHandler("webViewJavascriptBridgeBack")
//    }
//
//    func showDialog(_ title: String, message: String) {
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
//        self.controller?.present(alert, animated: true, completion: nil)
//    }
//
//    func callHandler(_ handleFuncName: String) {
//
//        let jsHandlerFunc = self.jsContext?.objectForKeyedSubscript("\(handleFuncName)")
//        let dict = ["name": "tdy", "age": 18] as [String : Any]
//        let _ = jsHandlerFunc?.call(withArguments: [dict])
//    }
//}
