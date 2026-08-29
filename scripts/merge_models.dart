import 'dart:io';

void main() async {
  final backendModelsDir = Directory('lib/backend/models');
  final frontendModelsDir = Directory('lib/frontend/models');
  final coreModelsDir = Directory('lib/core/models');

  if (!coreModelsDir.existsSync()) {
    coreModelsDir.createSync(recursive: true);
  }

  // Iterate backend models
  await for (final entity in backendModelsDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relativePath = entity.path.substring(backendModelsDir.path.length + 1);
      final frontendFile = File('${frontendModelsDir.path}/$relativePath');
      final coreFile = File('${coreModelsDir.path}/$relativePath');

      if (!coreFile.parent.existsSync()) {
        coreFile.parent.createSync(recursive: true);
      }

      if (frontendFile.existsSync()) {
        // Just copy the backend model
        String content = await entity.readAsString();
        
        // Ensure class name matches the file name logic roughly
        final className = entity.uri.pathSegments.last.replaceAll('.dart', '').split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join('');
        
        if (!content.contains('fromJson')) {
            content = content.replaceAll('factory $className.fromMap(', 
            'factory $className.fromJson(Map<String, dynamic> json) => $className.fromMap(json);\n  factory $className.fromMap(');
        }
        if (!content.contains('toJson')) {
            content = content.replaceAll('Map<String, dynamic> toMap()', 'Map<String, dynamic> toJson() => toMap();\n  Map<String, dynamic> toMap()');
        }

        await coreFile.writeAsString(content);
      } else {
        await entity.copy(coreFile.path);
      }
    }
  }

  // Iterate frontend models to catch any that don't exist in backend
  if (frontendModelsDir.existsSync()) {
    await for (final entity in frontendModelsDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final relativePath = entity.path.substring(frontendModelsDir.path.length + 1);
        final coreFile = File('${coreModelsDir.path}/$relativePath');

        if (!coreFile.existsSync()) {
          if (!coreFile.parent.existsSync()) {
            coreFile.parent.createSync(recursive: true);
          }
          await entity.copy(coreFile.path);
        }
      }
    }
  }

  print('Models merged into lib/core/models');
}
