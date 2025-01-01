class Brand {
    int? id;
    String? pic;
    String? name;

    Brand({
        this.id,
        this.pic,
        this.name,
    });

    factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        pic: json["pic"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "pic": pic,
        "name": name,
    };
}