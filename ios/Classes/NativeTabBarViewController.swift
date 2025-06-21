//
//  NativeTabBarView.swift
//  native_tab_bar_ios
//
//  Created by Grushka, Tom on 9/22/22.
//

import Flutter
import Foundation

// Provides a public interface for the methods our view controller provides.
protocol NativeTabBarViewControllerApi {
    var id: String { get }
    func setTabs(tabs: [NativeTab], selectedIndex: Int?) -> Bool
    func setStyle(style: NativeTabBarApiStyle) -> Bool
    func setSelected(_ index: Int) -> Bool
}

// Implements `FlutterPlatformView` and really acts more like a view controller than a view.
class NativeTabBarViewController: NSObject, FlutterPlatformView, NativeTabBarViewControllerApi, UITabBarDelegate {
    public let viewId: Int64
    public let id: String
    public let registrar: FlutterPluginRegistrar

    init(frame: CGRect, id: String, viewId: Int64, hostApi: NativeTabBarHostApiIOS, flutterApi: NativeTabBarFlutterApi, registrar: FlutterPluginRegistrar) {
        self.id = id
        self.viewId = viewId
        self.hostApi = hostApi
        self.flutterApi = flutterApi
        self.registrar = registrar
        uiView = MyNativeTabBar(frame: frame, registrar: registrar)

        super.init()

        uiView.delegate = self
        uiView.heightChanged = { height in
            // Callback to Flutter framework with the control's desired height so
            // it can update its `SizedBox` for dynamic type.
            flutterApi.wantsHeight(id: id, height: height) {}
        }

        hostApi.register(controller: self)
    }

    deinit {
        hostApi.deregister(controller: self)
    }

    func view() -> UIView {
        uiView
    }

    public private(set) var selectedIndex = -1

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard
            let index = tabBar.items?.firstIndex(of: item),
            index != selectedIndex
        else { return }
        selectedIndex = index
        flutterApi.valueChanged(id: id, selectedIndex: index.int64) { }
    }

    private let hostApi: NativeTabBarHostApiIOS
    private let flutterApi: NativeTabBarFlutterApi
    private let uiView: MyNativeTabBar

    func setTabs(tabs: [NativeTab], selectedIndex: Int?) -> Bool {
        uiView.setTabs(tabs: tabs, selectedIndex: selectedIndex)
    }

    func setStyle(style: NativeTabBarApiStyle) -> Bool {
        uiView.setStyle(style: style)
        return true
    }

    func setSelected(_ index: Int) -> Bool {
        uiView.setSelected(index)
    }
}
