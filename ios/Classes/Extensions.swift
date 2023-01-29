//
//  Extensions.swift
//  native_tab_bar_ios
//
//  Created by Grushka, Tom on 9/22/22.
//

import Foundation
import UIKit

extension NativeTabBarApiStyle {
    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch isDarkTheme {
        case true:
            return .dark
        case false:
            return .light
        default:
            return .unspecified
        }
    }
}

extension Comparable {
    func clamped(min minValue: Self, max maxValue: Self) -> Self {
        return min(max(self, minValue), maxValue)
    }
}

extension UIFont {
    static let defaultCodePoint = 58751 // MaterialIcons: settings

    public func renderIcon(codePoint: Int?, size: CGFloat? = nil) -> UIImage? {
        let codePoint = codePoint ?? Self.defaultCodePoint
        guard let scalar = UnicodeScalar(codePoint) else {
            assertionFailure("Invalid Unicode code point: \(codePoint).")
            return nil
        }

        let iconString = NSString(string: String(scalar))
        let attributes: [NSAttributedString.Key : Any] = [
            .font: withSize(size ?? pointSize),
        ]

        let iconSize = iconString.size(withAttributes: attributes)

        let image = UIGraphicsImageRenderer(size: iconSize).image { context in
            iconString.draw(at: CGPoint.zero, withAttributes: attributes)
        }

        return image
    }
}

extension RGBAColor {
    var uiColor: UIColor {
        UIColor(
            red: red ?? 0,
            green: green ?? 0,
            blue: blue ?? 0,
            alpha: 1.0
        )
    }
}

struct Weak<T: AnyObject> {
    weak var value: T?
}

extension NSNumber {
    var bool: Bool {
        self == 1
    }

    var int: Int {
        Int(truncating: self)
    }

    var int64: Int64 {
        Int64(truncating: self)
    }
}

extension Int32 {
    var int: Int {
        Int(self)
    }

    var int32: Int32 {
        Int32(self)
    }
}

extension Int64 {
    var int: Int {
        Int(self)
    }

    var int32: Int32 {
        Int32(self)
    }
}

extension Int {
    var int32: Int32 {
        Int32(self)
    }
}

#if DEBUG
    extension UIView {
        func printSubviews(level: Int = 0) {
            print(String(repeating: "\t", count: level), self)
            for subview in subviews {
                subview.printSubviews(level: level + 1)
            }
        }
    }
#endif
