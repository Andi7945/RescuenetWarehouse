class Sign {
  String id;
  String? unNumber;
  String? imagePath;
  String? instructions;
  String? remarks;
  String? sdsPath;
  List<String> otherDocuments = List.empty();

  Sign(this.id, this.imagePath);

  Sign.from(
      {required Sign sign,
        String? id,
      String? unNumber,
      String? imagePath,
      String? instructions,
      String? remarks,
      String? sdsPath,
      List<String>? otherDocuments})
      : id = id ?? sign.id,
        unNumber = unNumber ?? sign.unNumber,
        imagePath = imagePath ?? sign.imagePath,
        instructions = instructions ?? sign.instructions,
        remarks = remarks ?? sign.remarks,
        sdsPath = sdsPath ?? sign.sdsPath,
        otherDocuments = otherDocuments ?? sign.otherDocuments;
}
