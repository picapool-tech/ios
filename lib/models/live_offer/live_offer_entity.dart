class LiveOffer {
  int? id;
  String? fromAddress;
  String? toAddress;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? expiryAt;
  int? seats;
  dynamic userId;
  dynamic livePartnerId;

  LiveOffer({
    this.id,
    this.fromAddress,
    this.toAddress,
    this.createdAt,
    this.updatedAt,
    this.expiryAt,
    this.seats,
    this.userId,
    this.livePartnerId,
  });

  factory LiveOffer.fromJson(Map<String, dynamic> json) => LiveOffer(
        id: json["id"],
        fromAddress: json["fromAddress"],
        toAddress: json["toAddress"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]).toLocal(),
        expiryAt: json["expiryAt"] == null
            ? null
            : DateTime.parse(json["expiryAt"]).toLocal(),
        seats: json["seats"],
        userId: json["userId"],
        livePartnerId: json["livePartnerId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fromAddress": fromAddress,
        "toAddress": toAddress,
        "createdAt": createdAt?.toUtc().toIso8601String(),
        "updatedAt": updatedAt?.toUtc().toIso8601String(),
        "expiryAt": expiryAt?.toUtc().toIso8601String(),
        "seats": seats,
        "userId": userId,
        "livePartnerId": livePartnerId,
      };
}
