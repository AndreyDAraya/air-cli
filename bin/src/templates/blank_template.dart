import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';

/// Blank template - minimal Air structure
class BlankTemplate {
  Future<void> apply(String projectName, String org) async {
    final libPath = path.join(projectName, 'lib');

    // Create main.dart
    await FileUtils.createFile(
      path.join(libPath, 'main.dart'),
      _mainDart(projectName),
    );

    // Create app.dart
    await FileUtils.createFile(
      path.join(libPath, 'app.dart'),
      _appDart(projectName),
    );

    // Create core files

    // Create empty home module
    await FileUtils.createFile(
      path.join(libPath, 'modules', 'home', 'home_module.dart'),
      _homeModuleDart(),
    );

    await FileUtils.createFile(
      path.join(libPath, 'modules', 'home', 'ui', 'views', 'home_page.dart'),
      _homeScreenDart(),
    );

    Console.success('Blank template applied');
  }

  String _mainDart(String projectName) => '''
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:air_framework/air_framework.dart';
import 'modules/home/home_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register modules
  final manager = ModuleManager();
  
  // Registration is async and calls module.onBind(AirDI) and module.onInit(AirDI)
  await manager.register(HomeModule());
  
  runApp(const App());
}
''';

  String _appDart(String projectName) =>
      '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ModuleManager(),
      builder: (context, _) {
        final airRouter = AirRouter();
        airRouter.initialLocation = '/';

        final router = airRouter.router;

        return MaterialApp.router(
          title: '$projectName',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: router,
        );
      },
    );
  }
}
''';

  String _homeModuleDart() => '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import 'ui/views/home_page.dart';

class HomeModule extends AppModule {
  @override
  String get id => 'home';

  @override
  String get name => 'Home';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.home;

  @override
  Color get color => Colors.blue;

  @override
  String get initialRoute => '/';

  @override
  void onBind(AirDI di) {}

  @override
  Future<void> onInit(AirDI di) async {}

  @override
  List<AirRoute> get routes => [
    AirRoute(path: '/', builder: (context, state) => const HomeScreen()),
  ];
}
''';

  String _homeScreenDart() => '''
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Air Project Ready!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Start building your modular app'),
          ],
        ),
      ),
    );
  }
}
''';
}
