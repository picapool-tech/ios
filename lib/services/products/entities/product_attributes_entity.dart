class Attributes {
    String? size;
    String? type;
    String? year;
    String? brand;
    String? genre;
    String? style;
    String? title;
    String? author;
    String? fabric;
    String? height;
    String? length;
    String? breadth;
    String? material;
    String? condition;
    String? kmsDriven;
    String? modelName;
    String? deviceType;
    String? accessories;
    String? vehicleType;
    String? furnitureType;
    String? specifications;
    String? reasonForSell;

    Attributes({
        this.size,
        this.type,
        this.year,
        this.brand,
        this.genre,
        this.style,
        this.title,
        this.author,
        this.fabric,
        this.height,
        this.length,
        this.breadth,
        this.material,
        this.condition,
        this.kmsDriven,
        this.modelName,
        this.deviceType,
        this.accessories,
        this.vehicleType,
        this.furnitureType,
        this.specifications,
        this.reasonForSell,
    });

    factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        size: json["size"],
        type: json["type"],
        year: json["year"],
        brand: json["brand"],
        genre: json["genre"],
        style: json["style"],
        title: json["title"],
        author: json["author"],
        fabric: json["fabric"],
        height: json["height"],
        length: json["length"],
        breadth: json["breadth"],
        material: json["material"],
        condition: json["condition"],
        kmsDriven: json["kmsDriven"],
        modelName: json["modelName"],
        deviceType: json["deviceType"],
        accessories: json["accessories"],
        vehicleType: json["vehicleType"],
        furnitureType: json["furnitureType"],
        specifications: json["specifications"],
        reasonForSell: json["reasonForSell"],
    );

    Map<String, dynamic> toJson() => {
        "size": size,
        "type": type,
        "year": year,
        "brand": brand,
        "genre": genre,
        "style": style,
        "title": title,
        "author": author,
        "fabric": fabric,
        "height": height,
        "length": length,
        "breadth": breadth,
        "material": material,
        "condition": condition,
        "kmsDriven": kmsDriven,
        "modelName": modelName,
        "deviceType": deviceType,
        "accessories": accessories,
        "vehicleType": vehicleType,
        "furnitureType": furnitureType,
        "specifications": specifications,
        "reasonForSell": reasonForSell,
    };
}
