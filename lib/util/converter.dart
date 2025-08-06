String convertName(String churchName) {
  return churchName
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll(RegExp(r'[^a-z0-9_-]'), '');
}
