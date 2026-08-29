import 'dart:io';

void main() async {
  final dir = Directory('lib/core/models');
  if (!await dir.exists()) return;

  await for (final file in dir.list()) {
    if (file is File && file.path.endsWith('.dart')) {
      String content = await file.readAsString();
      bool modified = false;

      // Add fromMap alias if fromJson exists but fromMap doesn't
      if (content.contains('.fromJson(') && !content.contains('.fromMap(')) {
        final classNameMatch = RegExp(r'class ([a-zA-Z0-9_]+)').firstMatch(content);
        if (classNameMatch != null) {
          final className = classNameMatch.group(1)!;
          content = content.replaceAll(
            'factory $className.fromJson(Map<String, dynamic> json)',
            'factory $className.fromJson(Map<String, dynamic> json) => $className.fromMap(json);\n  factory $className.fromMap(Map<String, dynamic> json)'
          );
          modified = true;
        }
      }

      // Add toJson alias if toMap or toRequestJson exists but toJson doesn't
      if (!content.contains('toJson(') && (content.contains('toMap()') || content.contains('toRequestJson()'))) {
        final mapMethod = content.contains('toMap()') ? 'toMap' : 'toRequestJson';
        content = content.replaceFirst(
          'Map<String, dynamic> $mapMethod()',
          'Map<String, dynamic> toJson() => $mapMethod();\n  Map<String, dynamic> $mapMethod()'
        );
        modified = true;
      }

      if (modified) {
        await file.writeAsString(content);
        print('Updated aliases in ${file.path}');
      }
    }
  }
}
