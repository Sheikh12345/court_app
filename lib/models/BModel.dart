
class Lawyer {
    Lawyer({
        this.email,
        this.bLatitude,
        this.address,
        this.city,
        this.specialization,
        this.userPhoto,
        this.name,
        this.overAllRating,
        this.courtType,
        this.barCouncil,
        this.phoneNo,
        this.cnic,
        this.bLongitude,
    });

    String email;
    double bLatitude;
    String address;
    String city;
    String specialization;
    String userPhoto;
    String name;
    String overAllRating;
    String courtType;
    String barCouncil;
    String phoneNo;
    String cnic;
    double bLongitude;

    factory Lawyer.fromJson(Map<String, dynamic> json) => Lawyer(
        email: json["Email"],
        bLatitude: json["BLatitude"].toDouble(),
        address: json["Address"],
        city: json["city"],
        specialization: json["Specialization"],
        userPhoto: json["User Photo"],
        name: json["Name"],
        overAllRating: json["overAllRating"],
        courtType: json["CourtType"],
        barCouncil: json["BarCouncil"],
        phoneNo: json["PhoneNo"],
        cnic: json["CNIC"],
        bLongitude: json["BLongitude"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "Email": email,
        "BLatitude": bLatitude,
        "Address": address,
        "city": city,
        "Specialization": specialization,
        "User Photo": userPhoto,
        "Name": name,
        "overAllRating": overAllRating,
        "CourtType": courtType,
        "BarCouncil": barCouncil,
        "PhoneNo": phoneNo,
        "CNIC": cnic,
        "BLongitude": bLongitude,
    };
}
