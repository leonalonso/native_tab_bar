# native_tab_bar

## Accessible tab navigation bar for Flutter

This plugin provides an __accessible, styleable, native__ platform bottom tabs navigation component on both Android and iOS for Flutter. It can be used (almost!) as a drop-in replacement for the `BottomNavigationBar` Flutter widget. It renders a `UITabBar` on iOS, and a `BottomNavigationView` (compatible with Material 3) on Android. It behaves similarly to `BottomNavigationBarType.fixed` in that it does not provide the typical Flutter animations, but rather respects the native platform behaviors and animations that iOS and Android users are used to.

## Accessibility problems solved

The Flutter `BottomNavigationBar` widget has a couple of accessibility problems.

1. The Flutter widget does not support the __Large Content Viewer__ on iOS. Since font sizes should not be scaled in tabs due to space limitations, this presents a barrier to low vision users.

2. The tabs in the Flutter widget do not have proper "Tab" __roles__ or __indexes__ on iOS or Android. Instead, these are included in the accessibility labels, which creates a bad accessibility experience:

    - The Flutter widget tabs have accessibility labels like this: "Home Tab 1 of 3", "Downloads Tab 2 of 3", "Settings Tab 3 of 3"
        - They should be labeled like this: "Home", "Downloads", "Settings"

    - __Voice Control__ on iOS does not work with the Flutter widget. For example, if a user says, "Tap Home," Voice Control does not recognize the label, because it thinks the label is, "Home Tab 1 of 3." Even if the user says, "Tap Home Tab one of three," Voice Control does not recognize it.

    - __Braille display users__ will be confused and inconvenienced by the longer labels, because Braille displays have a shorthand for indicating tabs and tab indexes, which the labels spell out. Most Braille users have displays that show 40 characters or less, because 80-column displays are very expensive.

This plugin addresses all of these issues by providing native iOS and Android behavior in the respective platform native components for accessibility users.

## Installation

`flutter pub add native_tab_bar`

### Dependencies

- cupertino_icons
- plugin_platform_interface
- uuid
- visibility_detector

- Dev dependencies (only needed when working on this plugin):
    - pigeon (for API generation)

## Usage Example

See `example/lib/main.dart` for a full usage example.

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NativeTabBar Example')),
      bottomNavigationBar: NativeTabBar(
        onTap: (index) {
          print("Selected tab index: $index");
          setState(() {
            currentTabIndex = index;
          });
        },
        tabs: <NativeTab>[
          NativeTab(
            title: 'Home',
            nativeTabIcon: NativeTabIcon.adaptive(
              material: Icons.home,
              materialSelected: Icons.home_filled,
              cupertino: CupertinoIcons.house,
              cupertinoSelected: CupertinoIcons.house_fill,
            ),
          ),
          NativeTab(
            title: 'Downloads',
            nativeTabIcon: NativeTabIcon.adaptive(
              material: Icons.download_outlined,
              materialSelected: Icons.download,
              cupertino: CupertinoIcons.cloud_download,
              cupertinoSelected: CupertinoIcons.cloud_download_fill,
            ),
          ),
          NativeTab(
            title: 'Settings',
            nativeTabIcon: NativeTabIcon.adaptive(
              material: Icons.settings_outlined,
              materialSelected: Icons.settings,
              cupertino: CupertinoIcons.gear_alt,
              cupertinoSelected: CupertinoIcons.gear_alt_fill,
            ),
          ),
        ],
        style: NativeTabBarStyle(
          selectedItemColor: Colors.lightBlue,
          materialIndicatorBackgroundColor: Colors.lightBlue,
          materialIndicatorForegroundColor: Colors.white,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Home page content goes here."),
          ),
        ],
      ),
    );
  }
}
```

## License

This plugin has a liberal MIT license to encourage accessibility in all app development. Please learn from it and use as you see fit in your own apps!

## Contributing

I would really appreciate learning who is using this plugin, and your feedback, and bugfix and feature requests. Please feel free to open an issue or pull request.

## Contributors

- Tom Grushka, principal developer
- Adam Campfield
