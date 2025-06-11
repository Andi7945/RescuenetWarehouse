class PackingItem {
  String name;
  String description;
  double amount;
  double piecePrice;
  double weightTotal;
  DateTime? expirationDate;
  String dangerousGoods;
  String remarks;

  PackingItem(this.name, this.description, this.amount, this.piecePrice,
      this.weightTotal, this.expirationDate, this.dangerousGoods, this.remarks);
}
