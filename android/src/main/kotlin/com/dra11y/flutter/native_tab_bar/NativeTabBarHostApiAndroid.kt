package com.dra11y.flutter.native_tab_bar

import java.lang.ref.WeakReference

interface NativeTabBarApiManagement {
    var controllers: MutableMap<String, WeakReference<NativeTabBarViewController>>
    fun register(controller: NativeTabBarViewController)
    fun deregisterIfNeeded(controller: NativeTabBarViewController)
    fun controller(id: String): NativeTabBarViewController? = controllers[id]?.get()
}

class NativeTabBarHostApiAndroid : NativeTabBarHostApi, NativeTabBarApiManagement {
    override fun setTabs(id: String, tabs: List<NativeTab>, selectedIndex: Long?): Boolean {
        return controller(id)?.setTabs(tabs, selectedIndex = selectedIndex?.toInt()) ?: false
    }

    override fun setStyle(id: String, style: NativeTabBarApiStyle): Boolean {
        return controller(id)?.setStyle(style) ?: false
    }

    override fun setSelected(id: String, index: Long?): Boolean {
        return false
    }

    override var controllers: MutableMap<String, WeakReference<NativeTabBarViewController>> = mutableMapOf()

    override fun register(controller: NativeTabBarViewController) {
        controllers[controller.id] = WeakReference(controller)
    }

    override fun deregisterIfNeeded(controller: NativeTabBarViewController) {
        controllers[controller.id]?.get()?.let { registeredController ->
            if (registeredController.viewId == controller.viewId) {
                controllers.remove(controller.id)
            }
        }
    }
}
