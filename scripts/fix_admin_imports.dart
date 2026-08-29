import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool modified = false;

      final regex = RegExp(r"package:erp_software/(frontend|backend)/admin/[^/]+/models/([^']+)");
      if (regex.hasMatch(content)) {
        content = content.replaceAllMapped(regex, (match) {
          return "package:erp_software/core/models/${match.group(2)}";
        });
        modified = true;
      }
      
      if (modified) {
        await entity.writeAsString(content);
        print('Updated admin model imports in ${entity.path}');
      }
    }
  }
}
