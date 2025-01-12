class Loc {
    double? lat;
    double? lng;

    Loc({
        this.lat,
        this.lng,
    });

    factory Loc.fromJson(Map<String, dynamic> json) => Loc(
        lat: json["lat"],
        lng: json["lng"],
    );

    Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
    };
}