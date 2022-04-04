class UserModel {
  String uid = "";
  String fullName;
  String email;
  String password;
  String img_url = "";
  String device_id = "";
  String device_type = "";
  String device_token = "";

  bool followed = false;
  int followers = 0;
  int followings = 0;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : uid = json["uid"],
        fullName = json["fullName"],
        email = json["email"],
        password = json["password"],
        img_url = json["img_url"],
        device_id = json["device_id"]??"",
        device_type = json["device_type"]??"",
        device_token = json["device_token"]??"";

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "fullName": fullName,
    "email": email,
    "password": password,
    "img_url": img_url,
    'device_id': device_id,
    'device_type': device_type,
    'device_token': device_token,
  };

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is UserModel && other.uid == uid;
  }
}