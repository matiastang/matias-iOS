//
//  CustomActivity.swift
//  iOSShare
//
//  Created by matiastang on 2021/1/11.
//

import UIKit

class CustomActivity: UIActivity {

    // override methods
    @available(iOS 7.0, *)
    open class override var activityCategory: UIActivity.Category { return .share } // default is UIActivityCategoryAction.

    
    open override var activityType: UIActivity.ActivityType? { return .init(CustomActivity.description()) } // default returns nil. subclass may override to return custom activity type that is reported to completion handler
//    标题
    open override var activityTitle: String? { return "自定义分享" } // default returns nil. subclass must override and must return non-nil value
//    logo
    open override var activityImage: UIImage? { return nil } // default returns nil. subclass must override and must return non-nil value

    
    open override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    } // override this to return availability of activity based on items. default returns NO

    open override func prepare(withActivityItems activityItems: [Any]) {
        print(activityItems)
    }// override to extract items and set up your HI. default does nothing

    
    open override var activityViewController: UIViewController? { return nil } // return non-nil to have view controller presented modally. call activityDidFinish at end. default returns nil

    open override func perform() {
        print(#function + String(#line))
    }// if no view controller, this method is called. call activityDidFinish when done. default calls [self activityDidFinish:NO]

    
    // state method
    
    open override func activityDidFinish(_ completed: Bool) {
        print("分享成功\(completed)")
    } // activity must call this when activity is finished

}
