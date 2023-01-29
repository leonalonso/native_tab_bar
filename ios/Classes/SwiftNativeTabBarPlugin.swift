//
//  SwiftNativeTabBarPlugin.swift
//  native_tab_bar_ios
//
//  Created by Grushka, Tom on 9/22/22.
//

import Flutter
import Foundation

struct FontManifestEntry: Decodable {
    let family: String
    let fonts: [Asset]

    struct Asset: Decodable {
        let asset: String
    }
}

public class FontRegistry {
    static let defaultFontFamily = "MaterialIcons"
    static let defaultFontSize: CGFloat = 24

    public static func resolve(family: String?, size: CGFloat?) -> UIFont? {
        guard let fontFamily = registeredFonts[family ?? Self.defaultFontFamily] else { return nil }
        return UIFont(name: fontFamily, size: size ?? Self.defaultFontSize)
    }

    fileprivate static func register(family: String, fontName: String) {
        registeredFonts[family] = fontName
    }

    private static var registeredFonts = [String : String]()

    fileprivate static func registerFonts(registrar: FlutterPluginRegistrar) {
        guard
            let manifestUrl = Bundle.main.url(forResource: registrar.lookupKey(forAsset: "FontManifest"), withExtension: "json"),
            let manifestData = try? Data(contentsOf: manifestUrl, options: .mappedIfSafe),
            let manifest = try? JSONDecoder().decode([FontManifestEntry].self, from: manifestData)
        else {
            fatalError("Could not read FontManifest.json!")
        }

        manifest.forEach { manifestEntry in
            let family = NSString(string: manifestEntry.family).lastPathComponent
            manifestEntry.fonts.forEach { fontAsset in
                let assetKey = registrar.lookupKey(forAsset: fontAsset.asset)
                let fontName = NSString(string: NSString(string: fontAsset.asset).lastPathComponent).deletingPathExtension

                var error: Unmanaged<CFError>? = nil

                guard
                    let fontUrl = Bundle.main.url(forResource: assetKey, withExtension: nil),
                    let data = try? Data(contentsOf: fontUrl),
                    let provider = CGDataProvider(data: data as CFData),
                    let cgFont = CGFont(provider),
                    CTFontManagerRegisterGraphicsFont(cgFont, &error),
                    UIFont(name: fontName, size: 24) != nil
                else {
//                    assertionFailure("Could not register font family: \(family) with asset path: \(fontAsset.asset). ERROR: \(String(describing: error))\nFONT MANIFEST: \(manifest)")
                    return
                }

                FontRegistry.register(family: family, fontName: fontName)
            }

        }

    }
}

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

        FontRegistry.registerFonts(registrar: registrar)

        if #available(iOS 13.0, *) {
            _ = UITabBarButtonSwizzler()
        }
    }
}
