class OfferChat {
    int? id;
    DateTime? updatedAt;
    bool? isMain;
    dynamic status;
    dynamic liveOfferId;
    dynamic userAdminId;
    int? offerId;

    OfferChat({
        this.id,
        this.updatedAt,
        this.isMain,
        this.status,
        this.liveOfferId,
        this.userAdminId,
        this.offerId,
    });

    factory OfferChat.fromJson(Map<String, dynamic> json) => OfferChat(
        id: json["id"],
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        isMain: json["isMain"],
        status: json["status"],
        liveOfferId: json["liveOfferId"],
        userAdminId: json["userAdminId"],
        offerId: json["offerId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "updatedAt": updatedAt?.toIso8601String(),
        "isMain": isMain,
        "status": status,
        "liveOfferId": liveOfferId,
        "userAdminId": userAdminId,
        "offerId": offerId,
    };
}