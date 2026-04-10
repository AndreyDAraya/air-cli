import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;

/// Utility to resolve asset paths in both development and production (snapshot) modes.
class AssetResolver {
  /// Resolves the path to the internal assets of the given package.
  ///
  /// This works by resolving the 'package:<name>/<name>.dart' URI and
  /// navigating up to the package root.
  static Future<String?> resolve(String packageName, {Uri? scriptUri}) async {
    final root = await resolvePackageRoot(packageName, scriptUri: scriptUri);
    if (root != null) {
      return _checkAssetsAt(root);
    }
    return null;
  }

  /// Resolves the path to the package root.
  static Future<String?> resolvePackageRoot(String packageName, {Uri? scriptUri}) async {
    // 1. Try to resolve via package URI
    try {
      final packageUri = Uri.parse('package:$packageName/$packageName.dart');
      final resolvedUri = await Isolate.resolvePackageUri(packageUri);

      if (resolvedUri != null && resolvedUri.scheme == 'file') {
        final libDir = File.fromUri(resolvedUri).parent;
        return libDir.parent.path;
      }
    } catch (_) {}

    // 2. Walk up from script location
    final actualScriptUri = scriptUri ?? Platform.script;
    if (actualScriptUri.scheme == 'file') {
      Directory? current = File.fromUri(actualScriptUri).parent;
      for (var i = 0; i < 5; i++) {
        final pubspec = File(path.join(current!.path, 'pubspec.yaml'));
        if (pubspec.existsSync()) return current.path;
        if (current.parent.path == current.path) break;
        current = current.parent;
      }
    }

    // 3. Last resort: check next to resolved executable
    final execDir = File(Platform.resolvedExecutable).parent;
    final pubspec = File(path.join(execDir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) return execDir.path;

    return null;
  }

  static String? _checkAssetsAt(String basePath) {
    final candidate = path.join(
      basePath,
      'assets',
      'skills',
      'air_framework',
    );
    if (Directory(candidate).existsSync()) return candidate;
    return null;
  }
}
