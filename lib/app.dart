import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

    return Scaffold(
      key: _key,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: ElevatedButton(
          onPressed: () {
            _key.currentState!.openDrawer();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black45,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
          ),
          child: const Icon(Icons.menu),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.amber,
              ),
              child: Text('Waktu Solat Zones visualization tool'),
            ),
            ListTile(
              title: const Text('GitHub'),
              onTap: () {
                launchUrl(
                    Uri.parse(
                        'https://github.com/mptwaktusolat/jakim_zones_map'),
                    mode: LaunchMode.externalApplication);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: const MapView(),
    );
  }
}
