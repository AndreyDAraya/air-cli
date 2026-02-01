import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/console.dart';
import '../utils/file_utils.dart';
import 'blank_template.dart';

/// Starter template - includes auth and home modules
class StarterTemplate {
  Future<void> apply(String projectName, String org) async {
    // First apply blank template
    await BlankTemplate().apply(projectName, org);

    final libPath = path.join(projectName, 'lib');

    // Override main.dart with auth
    await FileUtils.createFile(
      path.join(libPath, 'main.dart'),
      _mainDart(projectName),
    );

    // Override app.dart with auth flow
    await FileUtils.createFile(
      path.join(libPath, 'app.dart'),
      _appDart(projectName),
    );

    // Create auth module
    await _createAuthModule(libPath, projectName);

    // Update home module
    await _createHomeModule(libPath, projectName);

    Console.success('Starter template applied');
  }

  Future<void> _createAuthModule(String libPath, String projectName) async {
    final authPath = path.join(libPath, 'modules', 'auth');

    // Auth module
    await FileUtils.createFile(
      path.join(authPath, 'auth_module.dart'),
      _authModuleDart(projectName),
    );

    // Models
    await FileUtils.createFile(
      path.join(authPath, 'models', 'user.dart'),
      _userModelDart(),
    );

    // Services
    await FileUtils.createFile(
      path.join(authPath, 'services', 'auth_service.dart'),
      _authServiceDart(projectName),
    );

    // State
    final statePath = path.join(authPath, 'ui', 'state');
    await FileUtils.createFile(
      path.join(statePath, 'auth_state.dart'),
      _authStateDart(projectName),
    );
    await FileUtils.createFile(
      path.join(statePath, 'auth_pulses.dart'),
      _authPulsesDart(),
    );
    await FileUtils.createFile(
      path.join(statePath, 'auth_flows.dart'),
      _authFlowsDart(),
    );

    // Views
    final viewsPath = path.join(authPath, 'ui', 'views');
    await FileUtils.createFile(
      path.join(viewsPath, 'login_view.dart'),
      _loginViewDart(projectName),
    );
    await FileUtils.createFile(
      path.join(viewsPath, 'register_view.dart'),
      _registerViewDart(projectName),
    );
  }

  Future<void> _createHomeModule(String libPath, String projectName) async {
    final homePath = path.join(libPath, 'modules', 'home');

    // Clean up existing home module created by BlankTemplate
    final homeDir = Directory(homePath);
    if (homeDir.existsSync()) {
      homeDir.deleteSync(recursive: true);
    }

    await FileUtils.createFile(
      path.join(homePath, 'home_module.dart'),
      _homeModuleDart(projectName),
    );

    await FileUtils.createFile(
      path.join(homePath, 'ui', 'views', 'home_page.dart'),
      _homePageDart(projectName),
    );
  }

  String _mainDart(String projectName) => '''
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:air_framework/air_framework.dart';
import 'modules/home/home_module.dart';
import 'modules/auth/auth_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register modules
  final manager = ModuleManager();
  
  // Registration is async and calls module.onBind() and module.initialize()
  await manager.register(AuthModule());
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
        airRouter.initialLocation = '/login';

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

  String _authModuleDart(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import 'ui/views/login_view.dart';
import 'ui/views/register_view.dart';
import 'ui/state/auth_state.dart';
import 'services/auth_service.dart';

class AuthModule implements AppModule {
  @override
  String get id => 'auth';

  @override
  String get name => 'Authentication';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.lock;

  @override
  Color get color => Colors.indigo;

  @override
  String get initialRoute => '/login';

  @override
  void onBind() {
    AirDI().register<AuthService>(AuthService());
    AirDI().registerLazySingleton<LoginState>(() => LoginState());
  }

  @override
  Future<void> initialize() async {
    AirDI().get<AuthService>();
    // Initialize the state/controller
    AirDI().get<LoginState>();
  }

  @override
  List<AirRoute> get routes => [
    AirRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    AirRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ];
}
''';

  String _userModelDart() => '''
class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});
}
''';

  String _authServiceDart(String projectName) => '''
import '../models/user.dart';

/// Simple auth service - replace with your actual auth implementation
class AuthService {
  UserModel? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_\${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@').first,
    );
    return _currentUser!;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_\${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
    );
    return _currentUser!;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}
''';

  String _authStateDart(String projectName) => '''
import 'package:air_framework/air_framework.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

part 'auth_pulses.dart';
part 'auth_flows.dart';

class LoginState extends AirState {
  LoginState() : super(moduleId: 'auth');

  @override
  void onInit() {
    flow<String?>(AuthStateKeys.userName, null);
    flow<String?>(AuthStateKeys.userEmail, null);
    flow<bool>(AuthStateKeys.isLoggedIn, false);
    flow<UserModel?>(AuthStateKeys.userModel, null);
  }

  @override
  void onPulses() {
    on(AuthPulses.login, _handleLogin);
    on(AuthPulses.register, _handleRegister);
    on(AuthPulses.logout, (_, {onSuccess, onError}) => _handleLogout());
  }

  Future<void> _handleLogin(
    ParamsLogin data, {
    void Function()? onSuccess,
    void Function(String)? onError,
  }) async {
    flow(AuthStateKeys.loginLoading, true);

    try {
      final user = await inject<AuthService>().login(
        email: data.email,
        password: data.password,
      );
      _updateUserState(user);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      if (onError != null) onError(e.toString());
    } finally {
      flow(AuthStateKeys.loginLoading, false);
    }
  }

  Future<void> _handleRegister(
    ParamsRegister data, {
    void Function()? onSuccess,
    void Function(String)? onError,
  }) async {
    flow(AuthStateKeys.registerLoading, true);

    try {
      final user = await inject<AuthService>().register(
        name: data.name,
        email: data.email,
        password: data.password,
      );
      _updateUserState(user);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      if (onError != null) onError(e.toString());
    } finally {
      flow(AuthStateKeys.registerLoading, false);
    }
  }

  void _handleLogout() async {
    await inject<AuthService>().logout();
    flow<String?>(AuthStateKeys.userName, null);
    flow<String?>(AuthStateKeys.userEmail, null);
    flow<bool>(AuthStateKeys.isLoggedIn, false);
    flow<UserModel?>(AuthStateKeys.userModel, null);
  }

  void _updateUserState(UserModel user) {
    flow<UserModel?>(AuthStateKeys.userModel, user);
    flow<String?>(AuthStateKeys.userName, user.name);
    flow<String?>(AuthStateKeys.userEmail, user.email);
    flow<bool>(AuthStateKeys.isLoggedIn, true);
  }
}
''';

  String _authPulsesDart() => '''
part of 'auth_state.dart';

class AuthPulses {
  static const login = AirPulse<ParamsLogin>('auth.login.submit');
  static const register = AirPulse<ParamsRegister>('auth.register.submit');
  static const logout = AirPulse<void>('auth.logout');
}

class ParamsLogin {
  final String email;
  final String password;

  ParamsLogin({required this.email, required this.password});
}

class ParamsRegister {
  final String name;
  final String email;
  final String password;

  ParamsRegister({
    required this.name,
    required this.email,
    required this.password,
  });
}
''';

  String _authFlowsDart() => '''
part of 'auth_state.dart';

class AuthStateKeys {
  static const String loginLoading = 'auth.login.loading';
  static const String registerLoading = 'auth.register.loading';
  static const String userName = 'auth.user_name';
  static const String userEmail = 'auth.user_email';
  static const String isLoggedIn = 'auth.is_logged_in';
  static const String userModel = 'auth.user_model';
}
''';

  String _loginViewDart(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import '../state/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    AuthPulses.login.pulse(
      ParamsLogin(
        email: _emailController.text,
        password: _passwordController.text,
      ),
      onSuccess: () {
        if (mounted) context.go('/');
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: \$error')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.indigo),
                const SizedBox(height: 32),
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                AirBuilder<bool>(
                  stateKey: AuthStateKeys.loginLoading,
                  initialValue: false,
                  builder: (context, isLoading) {
                    return FilledButton(
                      onPressed: isLoading ? null : _login,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign In'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
''';

  String _registerViewDart(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import '../state/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    AuthPulses.register.pulse(
      ParamsRegister(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
      onSuccess: () {
        if (mounted) context.go('/');
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: \$error')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_outlined, size: 80, color: Colors.indigo),
                const SizedBox(height: 32),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (v!.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AirBuilder<bool>(
                  stateKey: AuthStateKeys.registerLoading,
                  initialValue: false,
                  builder: (context, isLoading) {
                    return FilledButton(
                      onPressed: isLoading ? null : _register,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign Up'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
''';

  String _homeModuleDart(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';
import 'ui/views/home_page.dart';

class HomeModule implements AppModule {
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
  void onBind() {}

  @override
  Future<void> initialize() async {}

  @override
  List<AirRoute> get routes => [
    AirRoute(path: '/', builder: (context, state) => const HomeScreen()),
  ];
}
''';

  String _homePageDart(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:air_framework/air_framework.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.dashboard_customize,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  Air().pulse(action: 'auth.logout', sourceModuleId: 'home');
                  context.go('/login');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  DataConsumer<String?>(
                    dataKey: 'auth.user_name',
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'User',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.rocket_launch, color: Colors.blue),
                            title: Text('Get Started'),
                            subtitle: Text('Start building your awesome app!'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
''';
}
