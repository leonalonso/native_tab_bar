//
//  NativeTabBarViewFactory.swift
//  native_tab_bar_ios
//
//  Created by Grushka, Tom on 9/22/22.
//

import Flutter
import Foundation

class NativeTabBarViewFactory: NSObject, FlutterPlatformViewFactory {
    let hostApi: NativeTabBarHostApiIOS
    let flutterApi: NativeTabBarFlutterApi
    let registrar: FlutterPluginRegistrar

    init(hostApi: NativeTabBarHostApiIOS, flutterApi: NativeTabBarFlutterApi, registrar: FlutterPluginRegistrar) {
        self.hostApi = hostApi
        self.flutterApi = flutterApi
        self.registrar = registrar
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterJSONMessageCodec()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        guard
            let args = args as? [String : Any?],
            let id = args["id"] as? String
        else {
            preconditionFailure("Instance ID must be passed from Flutter via JSONMessageCodec as { 'id': String }")
        }
        return NativeTabBarViewController(frame: frame, id: id, viewId: viewId, hostApi: hostApi, flutterApi: flutterApi, registrar: registrar)
    }
}
