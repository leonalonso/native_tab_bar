//
//  SwizzleUITabBarButton.swift
//  native_tab_bar_ios
//
//  Created by Grushka, Tom on 10/10/22.
//

import ObjectiveC
import UIKit

private class SwizzledUITabBarButton : UIView {
    @objc dynamic var swizzled_showsLargeContentViewer: Bool {
        true
    }

    @objc dynamic var swizzled_scalesLargeContentImage: Bool {
        true
    }

    @objc dynamic var swizzled_largeContentTitle: String? {
        let badge: String?
        if
            let badgeView = value(forKey: "badge") as? UIView,
            let badgeLabel = badgeView.value(forKey: "label") as? UILabel,
            let badgeText = badgeLabel.text
        {
            badge = "(\(badgeText))"
        }
        else {
            badge = nil
        }
        let label = (value(forKey: "label") as? UILabel)?.text
        return [label, badge].compactMap { $0 }.joined(separator: " ")
    }

    @objc dynamic var swizzled_largeContentImage: UIImage? {
        let imageView = value(forKey: "imageView") as? UIImageView
        return imageView?.image
    }
}

@available(iOS 13.0, *)
class UITabBarButtonSwizzler {
    private static var isSwizzled = false // Make idempotent

    private let klassName = "UITabBarButton"
    private let swizzledClass = SwizzledUITabBarButton.self

    init() {
        if Self.isSwizzled { return }
        Self.isSwizzled = true

        guard
            let klass = NSClassFromString(klassName)
        else {
            assertionFailure("Could not get \(klassName) class!")
            return
        }

        swizzle(
            klass: klass,
            originalSelector: #selector(getter: UIView.showsLargeContentViewer),
            swizzledSelector: #selector(getter: SwizzledUITabBarButton.swizzled_showsLargeContentViewer)
        )

        swizzle(
            klass: klass,
            originalSelector: #selector(getter: UIView.largeContentTitle),
            swizzledSelector: #selector(getter: SwizzledUITabBarButton.swizzled_largeContentTitle)
        )

        swizzle(
            klass: klass,
            originalSelector: #selector(getter: UIView.largeContentImage),
            swizzledSelector: #selector(getter: SwizzledUITabBarButton.swizzled_largeContentImage)
        )

        swizzle(
            klass: klass,
            originalSelector: #selector(getter: UIView.scalesLargeContentImage),
            swizzledSelector: #selector(getter: SwizzledUITabBarButton.swizzled_scalesLargeContentImage)
        )

    }

    private func swizzle(klass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(klass, originalSelector)
        else {
            assertionFailure("Could not get original method!")
            return
        }

        guard
            let swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector)
        else {
            assertionFailure("Could not get swizzled method!")
            return
        }

        let didAdd = class_addMethod(klass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))

        if didAdd {
            class_replaceMethod(klass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
