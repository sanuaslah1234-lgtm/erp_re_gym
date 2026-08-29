class Helpers {
  static String generateInitials(String name) {
    if (name.isEmpty) return '';
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0].substring(0, names[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
