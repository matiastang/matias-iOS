//
//  ViewController.swift
//  iOSShare
//
//  Created by matiastang on 2021/1/6.
//

import UIKit
import WebKit
import JavaScriptCore
import Photos

class ViewController: UIViewController {

    /*
     (1)loadRequest()  加载请求
     (2)goBack()  网页后退
     (3)goForward()  网页前进
     (4)reload()  网页重新加载
     (5)stopLoading()  网页停止加载
     (6)title  网页标题
     (7)canGoBack  网页是否能够后退
     (8)canGoForward  网页是否能够前进
     (9)estimatedProgress  网页加载中当前的进度
     */
//    @IBOutlet weak var webViewNib: WKWebView!
    private var webView: WKWebView!
    
    private lazy var progressBar:UIProgressView = {
        let progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        progressBar.progress = 0.0
        progressBar.tintColor = UIColor.red
        return progressBar
    }()
    
    private var loadWebView: WKNavigation? {
        didSet {
            addObserver()
        }
    }
    
    private var margin: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         1.WebViewJavaScriptBridge缺点就是要固定的加入相关代码，JS端代码要在固定的函数内添加，使用拦截协议URL的方式传递参数需要把参数拼接在后面，遇到要传递的参数有特殊字符，例如& 、= 、？等解析容易出问题;
         bridge.callHandler('callme', {'blogURL': 'https://github.com/maying1992&content=每天都是好心情&img=图片'}, function(response) {
                  log('JS端 得到 response', response)
         2.WKWebview-MessageHandler在JS中写起来更简单一点，JS传递参数更方便，减少参数中特殊字符引起的错误,WKWebView在性能、稳定性方面更加强大；
         3.JavaScriptCore使用起来比较简单，方便web端和移动端的统一。
         */
        /*
         iOS与JS交互之UIWebView-协议拦截
         iOS与JS交互之UIWebView-JavaScriptCore框架
         iOS与JS交互之UIWebView-JSExport协议
         iOS与JS交互之WKWebView-协议拦截
         iOS与JS交互之WKWebView-WKScriptMessageHandler协议
         iOS与JS交互之WKWebView-WKUIDelegate协议
         
         三方库WebViewJavascriptBridge对UIWebView与WKWebView做了同意处理。
         
         WKScriptMessageHandler协议 专门用来处理监听JavaScript方法从而调用原生OC方法
         WKNavigationDelegate 主要处理一些跳转、加载处理操作
         WKUIDelegate 回拦截alert、confirm、prompt三种js弹框
         */
        setUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
    }

    open override func viewDidAppear(_ animated: Bool) {
        
    }

    open override func viewWillDisappear(_ animated: Bool) {
        
    }

    open override func viewDidDisappear(_ animated: Bool) {
        
    }

    @available(iOS 5.0, *)
    open override func viewWillLayoutSubviews() {
        
    }

    @available(iOS 5.0, *)
    open override func viewDidLayoutSubviews() {
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      if keyPath == "estimatedProgress" {
        print(webView.estimatedProgress)
        progressBar.alpha = 1.0
        progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
         if(webView.estimatedProgress >= 1.0) {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                self.progressBar.alpha = 0.0
            }, completion: { (finished:Bool) -> Void in
                self.progressBar.progress = 0
            })
          }
        }
    }

    deinit {
        print(#function)
        removeObserver()
        
        // 移除注入js的方法
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "jsConsole")
    }
}

extension ViewController {
    
    private func setUI() {
        setWebView()
        setNavigation()
        setProgressView()
//        loadHTMLString(webView)
        load(webView)
//        loadFileURL(webView)
    }
    
    private func setWebView() {
        /*
         @available(iOS, introduced: 2.0, deprecated: 13.0, message: "Use the statusBarManager property of the window scene instead.")
         open var statusBarFrame: CGRect { get } // returns CGRectZero if the status bar is hidden
         */
        let windows = UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene}).compactMap({ $0 }).first?.windows
        var statusH:CGFloat = 0
//        if let keyWindow = windows?.first {
//            statusH = keyWindow.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//        }
//        UIScreen.main.applicationFrame.width
//        UIScreen.main.bounds.width
        let config = webViewConfig()
        webView = WKWebView.init(frame: CGRect.init(x: 0, y: statusH, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - statusH), configuration: config)
        // UI代理
        webView.uiDelegate = self
        // 导航代理
        webView.navigationDelegate = self
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        webView.allowsBackForwardNavigationGestures = true
        webView.mediaType = "no-header-and-footer-device"// 配合@media no-header-and-footer-device使用
        // 可返回的页面列表, 存储已打开过的网页
//        let backForwardList = webView.backForwardList
        self.view.addSubview(webView)
    }
    
    private func setNavigation() {
        self.navigationItem.title = "加载中..."
        var btnBack = UIBarButtonItem()
        var btnForward = UIBarButtonItem()
        btnBack = UIBarButtonItem(title: "后退", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toBack(_:)))
        btnForward = UIBarButtonItem(title: "前进", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toForward(_:)))
        self.navigationItem.leftBarButtonItem = btnBack
        self.navigationItem.rightBarButtonItem = btnForward
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setProgressView() {
//        let progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
//        progressBar.progress = 0.0
//        progressBar.tintColor = UIColor.red
        webView.addSubview(progressBar)
    }
}

// MARK: - 响应
extension ViewController {
    
    @objc func toBack(_ action: UIButton) {
        print(action)
        iOSJS()
//        let loadURL = URL.init(string: "http://www.baidu.com/")
//        guard let url = loadURL else {
//            return
//        }
//        let urlRequest = URLRequest.init(url: url)
//        loadWebView = webView.load(urlRequest)
    }
    
    @objc func toForward(_ action: UIButton) {
        print(action)
        if webView.canGoForward {
            webView.goForward()
        }
    }
}

extension ViewController {
    
    private func addObserver() {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    private func removeObserver() {
        webView.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
    }
}

extension ViewController {
    
    private func load(_ webView: WKWebView) {
//        let loadURL = URL.init(string: "http://localhost:3000")
        let loadURL = URL.init(string: "http://localhost:3000/#/home")
//        let loadURL = URL.init(string: "http://192.168.105.49:3000/#/test")
//        let loadURL = URL.init(string: "http://www.baidu.com/")
        guard let url = loadURL else {
            return
        }
        let urlRequest = URLRequest.init(url: url)
        loadWebView = webView.load(urlRequest)
    }
    
    private func loadFileURL(_ webView: WKWebView) {
        guard let pathStr = Bundle.main.path(forResource: "index", ofType: "html") else {
            return
        }
        let url = URL.init(fileURLWithPath: pathStr)
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    private func loadHTMLString(_ webView: WKWebView) {
        let htmlString = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>WKWebView load html string</title>
        </head>
        <body>
            <div id="app" style="width: 100%;height:400px;background-color: red;"></div>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

extension ViewController {
    
    private func callJSFunction() {
//        let message = "success"
//        let js = "shareSuccess('\(message)')"
//        let js = "document.getElementById('app').style.background = 'blue';"
        let js = "iOSCallFunction('test')"
        webView.evaluateJavaScript(js) { (result, error) in
            print(result ?? "result")
            print(error ?? "error")
        }
    }
    
    private func findHTML() {
        /*
         @available(iOS 14.0, *)
         open class WKFindResult : NSObject, NSCopying {

             
             /* @abstract Whether or not a match was found during the find operation */
             open var matchFound: Bool { get }
         }
         */
        webView.find("iOS") { (result) in
            print(result)
            if result.matchFound {
                print("查找成功")
            } else {
                print("查找失败")
            }
        }
    }
    
    private func pdfFromHTML() {
        /*
         采用UIActivityViewController分享PDF文件到微信，总结出以下情况：

         1. 仅仅将PDF文件的本地文件系统URL传递给UIActivityViewController 时，分享选项会包含微信、QQ、拷贝到微信、拷贝到QQ；
         2. 仅仅将PDF二进制数据传递给UIActivityViewController 时，不会看到微信、QQ相关的分享途径选项；
         3. 将本地文件系统URL和二进制数据都传递给*UIActivityViewController *时，分享选项会包含 拷贝到微信、拷贝到QQ ，不包含 微信、QQ ；
         */
        webView.createPDF { (result) in
            print(result)
            do {
                let data = try result.get()
                print(data)
                let activityVC = UIActivityViewController.init(activityItems: [data], applicationActivities: [CustomActivity()])
//                activityVC.completionHandler = {(type: UIActivity.ActivityType?, succes: Bool) -> Void in
//                }
                // 分享结束后的回调
                activityVC.completionWithItemsHandler = {(type:UIActivity.ActivityType?, success: Bool, items: [Any]?, error: Error?) -> Void in
                    print(type as Any)
                    print(success)
                    print(items ?? "")
                    print(error ?? "")
                }
                activityVC.excludedActivityTypes = [.postToWeibo,.postToTwitter]
                // 弹出系统分享
                self.present(activityVC, animated: true) {
                    
                }
            } catch {
                print("获取PDF数据失败")
            }
        }
    }
    
    private func callAsyncJavaScript() {
        defer {
            if margin <= 0 {
                margin = 10
            } else {
                margin = 0
            }
        }
        let styleString = """
            var element = document.getElementById(elementIDToStylize);
            var str = ''
            if (!element) {
                return str;
            }
            for (const theStyle in stylesToApply) {
                str += theStyle + stylesToApply[theStyle];
                element.style[theStyle] = stylesToApply[theStyle];
        //                element.style.theStyle = stylesToApply[theStyle] + 'px';
        //                element.style = Object.assign(element.style, { theStyle: stylesToApply[theStyle] })
            }
            return str;
        """
        
        webView.callAsyncJavaScript(styleString, arguments: ["elementIDToStylize": "IOSJS","stylesToApply": ["margin": margin]], in: nil, in: .defaultClient) { (result) in
            /*
             @frozen public enum Result<Success, Failure> where Failure : Error
             */
            print(result)
            do {
                let value = try result.get()
                print("The value is \(value).")
            } catch let error {
                print("Error retrieving the value: \(error)")
            }
        }
    }
    
    private func toBackPreviousPage() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    private func iOSJS() {
        /*
         @available(iOS 14.0, macOS 11.0, *)
         extension WKWebView {

             public func callAsyncJavaScript(_ functionBody: String, arguments: [String : Any] = [:], in frame: WKFrameInfo? = nil, in contentWorld: WKContentWorld, completionHandler: ((Result<Any, Error>) -> Void)? = nil)

             使用上图的 createPDF api, 可以截图整个 WebView 的全部内容, 包括屏幕外的, 并作为 pdf 输出
             public func createPDF(configuration: WKPDFConfiguration = .init(), completionHandler: @escaping (Result<Data, Error>) -> Void)

             为当前页面的所有数据创建一个 snapshot, 包括整个页面的 html, js, css 以便重新运行这个 ArchiveData 时, 可以重现当时 Web 页面的所有内容, 因此也非常适用于 Debug
             public func createWebArchiveData(completionHandler: @escaping (Result<Data, Error>) -> Void)

             public func evaluateJavaScript(_ javaScript: String, in frame: WKFrameInfo? = nil, in contentWorld: WKContentWorld, completionHandler: ((Result<Any, Error>) -> Void)? = nil)

             public func find(_ string: String, configuration: WKFindConfiguration = .init(), completionHandler: @escaping (WKFindResult) -> Void)
         }
         */
        let alert = UIAlertController.init(title: "提示", message: "选择执行内容", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "返回上一级", style: .default, handler: { [weak self] (_) -> Void in
            self?.toBackPreviousPage()
        }))
        alert.addAction(UIAlertAction(title: "调用JS已有方法iOSCallFunction", style: .default, handler: { [weak self] (_) -> Void in
            self?.callJSFunction()
        }))
        alert.addAction(UIAlertAction(title: "HTML中查找'iOS'", style: .default, handler: { [weak self] (_) -> Void in
            self?.findHTML()
        }))
        alert.addAction(UIAlertAction(title: "HTML生成PDF", style: .default, handler: { [weak self] (_) -> Void in
            self?.pdfFromHTML()
        }))
        alert.addAction(UIAlertAction(title: "执行iOS中的JS方法", style: .default, handler: { [weak self] (_) -> Void in
            self?.callAsyncJavaScript()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("取消")
        }))
        self.present(alert, animated: true, completion: nil)
        return
//        webView.createWebArchiveData { (result) in
//            do {
//                let data = try result.get()
////                try data.write(to: <#T##URL#>)
//            } catch {
//                print(#function)
//                print(error)
//            }
//        }
    }
    
    private func webViewConfig() ->WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        // 创建设置对象
        let preference = WKPreferences()
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 0
        //设置是否支持javaScript 默认是支持的
        /*
         ios14.0已废弃
         @available(iOS, introduced: 8.0, deprecated: 14.0, message: "Use WKWebPagePreferences.allowsContentJavaScript to disable content JavaScript on a per-navigation basis")
         */
//        preference.javaScriptEnabled = true
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preference
        
//        config.limitsNavigationsToAppBoundDomains = true

        // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = true
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
        config.requiresUserActionForMediaPlayback = true
        //设置是否允许画中画技术 在特定设备上有效
        config.allowsPictureInPictureMediaPlayback = true
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        config.applicationNameForUserAgent = "ChinaDailyForiPad"
         //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
//        let weakScriptMessageDelegate = WeakWebViewScriptMessageDelegate(self)
        //这个类主要用来做native与JavaScript的交互管理
        let wkUController = WKUserContentController()
        //注册一个js方法(注册之后可以在js调用window.webkit.messageHandlers.注册的方法名.postMessage(parameters);)
        wkUController.add(self, name: "jsFunc")// 使用WKScriptMessageHandler
        let contentWorld = WKContentWorld.page
        /*
         WKContentWorld.defaultClient客户的默认世界。
         WKContentWorld.page当前网页内容的内容世界。
         */
        wkUController.addScriptMessageHandler(self, contentWorld: contentWorld, name: "jsConsole")// 使用WKScriptMessageHandlerWithReply
//        wkUController.addScriptMessageHandler(weakScriptMessageDelegate, contentWorld: contentWorld, name: "reload")
        wkUController.addScriptMessageHandler(self, contentWorld: contentWorld, name: "reload")
       config.userContentController = wkUController
        
//        WKUserScript：用于进行JavaScript注入
        //以下代码适配文本大小，由UIWebView换为WKWebView后，会发现字体小了很多，这应该是WKWebView与html的兼容问题，解决办法是修改原网页，要么我们手动注入JS
//        let jSString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
//        let jSString = "document.body.style.background = rgb(211, 211, 211);"
        let jSString = """
                document.body.style.background = "blue";
        """
        //用于进行JavaScript注入
        let wkUScript = WKUserScript.init(source: jSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true, in: contentWorld)
        config.userContentController.addUserScript(wkUScript)
        return config
    }
}

extension ViewController: WKScriptMessageHandler {
    
    @available(iOS 8.0, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsFunc" {
            print(message.name, message.body)
            return
        }
        print("没有对应的方法")
    }
}

extension ViewController: WKScriptMessageHandlerWithReply {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        if message.name == "jsConsole" {
            print(message.body)
            if let body = message.body as? [String : String], body["status"] == "success" {
                replyHandler(body, nil)
            } else {
                replyHandler(nil, "Unexpected message received")
            }
            return
        }
        if message.name == "reload" {
            print(message.body)
            webView.reload()
            replyHandler("reload success", nil)
            return
        }
        print("没有对应的方法")
    }
}

extension ViewController: WKUIDelegate {
    
//    WKWebView创建初始化加载的一些配置(可以指定配置对象、导航动作对象、window特性)
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        webViewConfig(configuration: configuration)
//        return webView
        //判断下当前请求的targetFrame是不是MainFrame，不是则要在主动加载链接
        if let isMain = navigationAction.targetFrame?.isMainFrame, !isMain {
            webView.load(navigationAction.request)
        }
        return nil
    }

    
//    处理WKWebView关闭的时间
    @available(iOS 9.0, *)
    func webViewDidClose(_ webView: WKWebView) {
        
    }

    
//    处理网页js中的提示框,若不使用该方法,则提示框无效
//    处理js里的alert
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // 使用系统提示
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
//    处理网页js中的确认框,若不使用该方法,则确认框无效
//    处理js里的confirm
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // 使用系统提示
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            completionHandler(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
//    处理网页js中的文本输入
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            print(textField.text ?? "")
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
            if let firstTextField = alert.textFields?.first {
                completionHandler(firstTextField.text)
            } else {
                completionHandler(nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
//    允许你的应用程序决定是否给定的元素应该显示预览
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return true
    }

    
//    允许你的应用程序提供一个自定义的视图控制器来显示当给定的元素被窥视。
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        return nil
    }

    
    /** @abstract Allows your app to pop to the view controller it created.
     @param webView The web view invoking the delegate method.
     @param previewingViewController The view controller that is being popped.
     */
    @available(iOS, introduced: 10.0, deprecated: 13.0)
    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        
    }

    
    // TARGET_OS_IPHONE
    
    
    /**
     * @abstract Called when a context menu interaction begins.
     *
     * @param webView The web view invoking the delegate method.
     * @param elementInfo The elementInfo for the element the user is touching.
     * @param completionHandler A completion handler to call once a it has been decided whether or not to show a context menu.
     * Pass a valid UIContextMenuConfiguration to show a context menu, or pass nil to not show a context menu.
     */
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        
    }

    
    
    /**
     * @abstract Called when the context menu will be presented.
     *
     * @param webView The web view invoking the delegate method.
     * @param elementInfo The elementInfo for the element the user is touching.
     */
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
        
    }

    
    
    /**
     * @abstract Called when the context menu configured by the UIContextMenuConfiguration from
     * webView:contextMenuConfigurationForElement:completionHandler: is committed. That is, when
     * the user has selected the view provided in the UIContextMenuContentPreviewProvider.
     *
     * @param webView The web view invoking the delegate method.
     * @param elementInfo The elementInfo for the element the user is touching.
     * @param animator The animator to use for the commit animation.
     */
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        
    }

    
    
    /**
     * @abstract Called when the context menu ends, either by being dismissed or when a menu action is taken.
     *
     * @param webView The web view invoking the delegate method.
     * @param elementInfo The elementInfo for the element the user is touching.
     */
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
        
    }

}

extension ViewController: WKNavigationDelegate {
    
//    在发送请求之前，决定是否跳转 -> 默认允许
//    @available(iOS 8.0, *)
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//
//    }

//    在发送请求之前，决定是否跳转 -> 默认允许
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        /*
         * 使用 javaScriptEnabled 可以 disable 所有 webview 试图去加载的 js 文件
         * 新属性 allowsContentJavaScript, 使用这个属性可以禁用内联的 JS, url 方式加载的远端 js, 以及本地路径的 js 文件, 但是 native 直接执行的 js 仍然有效 在 decidePolicy 代理方法中使用 WKWebpagePreferences, 更可以对每个 web 页面进行更细致的配置, 来决定当前 web 页面是否加载 js
         */
        if let url = navigationAction.request.url {
            if let seheme = url.scheme, seheme == "jsToIOS".lowercased() {
                decisionHandler(.cancel, preferences)
                return
            }
            if url.absoluteString.hasPrefix("http://") {
//                preferences.allowsContentJavaScript = false
            }
        }
        preferences.preferredContentMode = .mobile
        decisionHandler(.allow, preferences)
    }

    
//    根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
//    在收到响应后，决定是否跳转 -> 默认允许
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        //允许跳转
        decisionHandler(.allow)
        //不允许跳转
//        decisionHandler(.cancel)
    }

    
//    处理网页开始加载
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("网页开始加载\(#function)")
    }

    
    // 接收到服务器跳转请求即服务重定向时之后调用
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {

    }

    
//    处理网页加载失败
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("网页加载失败\(#function)")
    }

    
//    处理网页内容开始返回
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("网页内容开始返回\(#function)")
    }

    
//    处理网页加载完成
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("网页加载完成\(#function)")
        // 加载完成可以获取标题
        self.navigationItem.title = webView.title
        javaScriptRun(webView)
    }

    
//    处理网页返回内容时发生的失败
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("网页返回内容时发生的错误\(#function)")
    }

    
//    身份验证时调用
    @available(iOS 8.0, *)
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//
//    }

    
//    处理网页进程终止
    @available(iOS 9.0, *)
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("网页进程终止\(#function)")
    }

    
    /** @abstract Invoked when the web view is establishing a network connection using a deprecated version of TLS.
     @param webView The web view initiating the connection.
     @param challenge The authentication challenge.
     @param decisionHandler The decision handler you must invoke to respond to indicate whether or not to continue with the connection establishment.
     */
//    @available(iOS 14.0, *)
//    func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
//
//    }
}

// MARK: - JavaScriptCore相关
extension ViewController {
    
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
//        setContext(webView)
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
        /*
         WKWebView实例中无法获取上下文(JSContext)，因为布局和javascript是在另一个进程上处理的。
         所有WKWebView不能使用JavaScriptCore框架与JS交互
         */
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
@objc protocol SwiftJavaScriptDelegate: JSExport {
    
    // js调用App的返回方法
    func popVC()
    
    // js调用App的showDic。传递Dict 参数
    func showDic(_ dict: [String: AnyObject])
    
    // js调用App方法时传递多个参数 并弹出对话框 注意js调用时的函数名
    func showDialog(_ title: String, message: String)
    
    // js调用App的功能后 App再调用js函数执行回调
    func callHandler(_ handleFuncName: String)
    
}

// 定义一个模型 该模型实现SwiftJavaScriptDelegate协议
@objc class SwiftJavaScriptModel: NSObject {
    
    weak var controller: UIViewController?
    weak var jsContext: JSContext?
}

extension SwiftJavaScriptModel: SwiftJavaScriptDelegate {
    
    func popVC() {
        if let vc = controller {
            DispatchQueue.main.async {
                vc.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    func showDic(_ dict: [String: AnyObject]) {
        
        print("展示信息：", dict,"= = ")
        
        // 调起微信分享逻辑
        callHandler("webViewJavascriptBridgeBack")
    }
    
    func showDialog(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.controller?.present(alert, animated: true, completion: nil)
    }
    
    func callHandler(_ handleFuncName: String) {
        
        let jsHandlerFunc = self.jsContext?.objectForKeyedSubscript("\(handleFuncName)")
        let dict = ["name": "tdy", "age": 18] as [String : Any]
        let _ = jsHandlerFunc?.call(withArguments: [dict])
    }
}
