class PackingDangerousGood {
  String dangerType;
  String iataId;
  String properShippingName;
  double maxWeightPAX;
  double maxWeightCargo;
  String remarks;
  String imagePath;

  PackingDangerousGood(this.dangerType, this.iataId, this.properShippingName,
      this.maxWeightPAX, this.maxWeightCargo, this.remarks, this.imagePath);
}
