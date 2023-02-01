//
//  MyNativeTabControl.swift
//  native_tab_bar_ios
//
//  Created by Grushka, Tom on 9/26/22.
//

import UIKit
import native_flutter_fonts

class MyNativeTabBar: UITabBar, UILargeContentViewerInteractionDelegate {
    let registrar: FlutterPluginRegistrar?
    var interaction: UIInteraction?

    init(frame: CGRect, registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init(frame: frame)
        if #available(iOS 13.0, *) {
            let interaction = UILargeContentViewerInteraction(delegate: self)
            self.interaction = interaction
            addInteraction(interaction)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //    private static func defaultUnscaledHeight() -> CGFloat {
    //        UIFontMetrics.default.scaledFont(
    //            for: .boldSystemFont(ofSize: UIFont.systemFontSize)).lineHeight
    //    }
    //
    //    private func defaultSelectedColor() -> UIColor {
    //        if #available(iOS 12.0, *) {
    //            return isDark ? .gray : .white
    //        } else {
    //            return UIColor.systemBlue
    //        }
    //    }

    //    private func defaultSelectedTextColor() -> UIColor {
    //        return UIColor.white
    //    }

    //    // Allow consumer override of dark theme, fallback to automatic.
    //    @available(iOS 12.0, *)
    //    private var isDark: Bool {
    //        style.isDarkTheme ?? (traitCollection.userInterfaceStyle == .dark)
    //    }

    //    override var showsLargeContentViewer: Bool {
    //        get { true }
    //        set { }
    //    }

//    var lastSelectedIndex: Int = -1
//
//    override var selectedItem: UITabBarItem? {
//        didSet {
//            if
//                let selectedItem = selectedItem,
//                let items = items,
//                let index = items.firstIndex(of: selectedItem),
//                index != lastSelectedIndex
//            {
//                lastSelectedIndex = index
//                print("didset index = \(index)")
//            }
//        }
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
        heightChanged?(intrinsicContentSize.height.rounded())
    }
    //
    //    private func computeBackgroundColor() -> UIColor {
    //        if style.isDarkTheme == nil {
    //            if #available(iOS 13.0, *) {
    //                return .quaternarySystemFill
    //            }
    //        }
    //        if #available(iOS 12.0, *) {
    //            return isDark ? (
    //                style.backgroundColorDark?.uiColor ??
    //                    style.backgroundColor?.uiColor ??
    //                UIColor(white: 0.2, alpha: 1)) : (
    //                    style.backgroundColor?.uiColor ?? UIColor(white: 0.9, alpha: 1))
    //        }
    //        /// Pre-iOS 12 bottom tab background.
    //        return .white
    //    }

    //    private func defaultUnselectedTextColor() -> UIColor {
    //        if #available(iOS 12.0, *) {
    //            return isDark ? .white : .black
    //        } else {
    //            return UIColor.black
    //        }
    //    }

    //    public private(set) var height: CGFloat = MyNativeTabBar.defaultUnscaledHeight() {
    //        didSet {
    //            guard height != oldValue else { return }
    //            heightChanged?(height)
    //        }
    //    }

    // Force update when light/dark mode is toggled or preferred font size changed.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setStyle(style: style)
    }

    public var heightChanged: ((CGFloat) -> Void)?

    func setStyle(style: NativeTabBarApiStyle) {
        self.style = style
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = style.userInterfaceStyle
        }
        tintColor = style.selectedItemColor?.uiColor
        unselectedItemTintColor = style.itemColor?.uiColor
    }

    private var style = NativeTabBarApiStyle()

    func setSelected(_ index: Int) -> Bool {
        guard let items = items, items.count > index else { return false }

        selectedItem = items[index]
        return true
    }

    func setTabs(tabs: [NativeTab], selectedIndex: Int?) -> Bool {
        let items = tabs.enumerated().map { (index: Int, tab: NativeTab) in

            let normalIcon = FlutterFontRegistry.resolve(
                family: tab.nativeTabIcon?.fontFamily,
                    size: 24)?.renderIcon(
                        codePoint: tab.nativeTabIcon?.codePoint?.int)
            let selectedIcon = FlutterFontRegistry.resolve(
                    family: tab.nativeTabIcon?.selectedFontFamily,
                    size: 24)?.renderIcon(
                        codePoint: tab.nativeTabIcon?.selectedCodePoint?.int)
            let item = UITabBarItem(title: tab.title, image: normalIcon, selectedImage: selectedIcon)

            // item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16)
            return item
        }

        setItems(items, animated: true)
        let selected = items[(selectedIndex ?? 0).clamped(min: 0, max: items.count - 1)]
        selectedItem = selected
        delegate?.tabBar?(self, didSelect: selected)
        return true
    }


}
