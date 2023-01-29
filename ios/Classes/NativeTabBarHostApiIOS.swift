//
//  NativeTabBarApiIOS.swift
//  native_tab_bar_ios
//
//  Created by Grushka, Tom on 9/22/22.
//

import Flutter

// NativeTabBarApi Host API implementation class.
// Currently, since Pigeon does not yet support multiple API/channel instances,
// we pass the id in each API call from Flutter, and delegate the method
// to the appropriate registered view instance. We use a dictionary as a
// very simple "instance manager." See also: https://github.com/flutter/plugins/tree/main/packages/webview_flutter
class NativeTabBarHostApiIOS: NSObject, NativeTabBarHostApi, NativeTabBarApiManagement {
    func setTabs(id: String, tabs: [NativeTab], selectedIndex: Int32?) -> Bool {
        controller(with: id)?.setTabs(tabs: tabs, selectedIndex: selectedIndex?.int) ?? false
    }

    func setStyle(id: String, style: NativeTabBarApiStyle) -> Bool {
        controller(with: id)?.setStyle(style: style) ?? false
    }

    func setSelected(id: String, index: Int32?) -> Bool {
        guard let index = index?.int else { return false }
        return controller(with: id)?.setSelected(index) ?? false
    }

    // Stored property required by `NativeTabBarApiManagement`.
    var controllers: [String : Weak<NativeTabBarViewController>] = [:]
}

// Separate internal management functions from the Host API to make API maintenance easier.
protocol NativeTabBarApiManagement: NativeTabBarHostApiIOS {
    // Retain a weak reference to each view for dispatching API events properly,
    // since Pigeon does not yet support multiple API instances/channels.
    // Weak references allow the framework to dispose of views when it wants to.
    var controllers: [String: Weak<NativeTabBarViewController>] { get set }

    func register(controller: NativeTabBarViewController)
    func deregister(controller: NativeTabBarViewController)

    // Convenience method to delegate calls to the registered view by its ID.
    func controller(with id: String) -> NativeTabBarViewController?
}

extension NativeTabBarApiManagement {
    func register(controller: NativeTabBarViewController) {
        controllers[controller.id] = Weak(value: controller)
    }

    func deregister(controller: NativeTabBarViewController) {
        controllers.removeValue(forKey: controller.id)
    }

    func controller(with id: String) -> NativeTabBarViewController? {
        controllers[id]?.value
    }
}
