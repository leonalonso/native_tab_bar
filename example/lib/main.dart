import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:native_tab_bar/native_tab_bar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NativeTabBar Test',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  bool isNative = true;
  bool isMaterial3 = true;

  @override
  Widget build(BuildContext context) {
    print('flutter isMaterial3 = $isMaterial3');
    final flutterBottomNavigationBar = BottomNavigationBar(
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          label: 'Home',
          icon: Icon(CupertinoIcons.house),
        ),
        BottomNavigationBarItem(
          label: 'Downloads',
          icon: Icon(CupertinoIcons.cloud_download),
        ),
        BottomNavigationBarItem(
          label: 'Settings',
          icon: Icon(CupertinoIcons.settings),
        ),
      ],
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
    );

    final nativeTabBar = NativeTabBar(
      currentIndex: currentIndex,
      onTap: (index) {
        print("Selected tab index: $index");
        setState(() {
          currentIndex = index;
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
        isMaterial3: isMaterial3,
        selectedItemColor: Colors.lightBlue,
        materialIndicatorBackgroundColor: Colors.lightBlue,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('NativeTabBar Example')),
      bottomNavigationBar: isNative ? nativeTabBar : flutterBottomNavigationBar,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Home page content goes here."),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  isNative = !isNative;
                });
              },
              child: Text(
                'Switch to ${isNative ? 'Flutter' : 'Native'} tab bar',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  isMaterial3 = !isMaterial3;
                });
              },
              child: Text(
                'Switch to Material ${isMaterial3 ? 2 : 3} theme',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
