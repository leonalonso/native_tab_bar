//
//  SwiftNativeTabBarPlugin.swift
//  native_tab_bar_ios
//
//  Created by Grushka, Tom on 9/22/22.
//

import Flutter
import Foundation

public class SwiftNativeTabBarPlugin: NSObject, FlutterPlugin {
    static let viewTypeId = "com.dra11y.flutter.native_tab_bar.ios"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftNativeTabBarPlugin(registrar: registrar)
        registrar.register(instance.factory, withId: viewTypeId)
    }

    let factory: NativeTabBarViewFactory
    let hostApi: NativeTabBarHostApiIOS
    let flutterApi: NativeTabBarFlutterApi

    init(registrar: FlutterPluginRegistrar) {
        hostApi = NativeTabBarHostApiIOS()
        NativeTabBarHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: hostApi)
        flutterApi = NativeTabBarFlutterApi(binaryMessenger: registrar.messenger())
        factory = NativeTabBarViewFactory(hostApi: hostApi, flutterApi: flutterApi, registrar: registrar)

        if #available(iOS 13.0, *) {
            _ = UITabBarButtonSwizzler()
        }
    }
}
