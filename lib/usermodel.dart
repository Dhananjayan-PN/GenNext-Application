class User {
  int id;
  String email;
  String username;
  String firstname;
  String lastname;
  String usertype;
  String dob;
  String country;
  String dp;

  User(
      {this.id,
      this.email,
      this.username,
      this.firstname,
      this.lastname,
      this.usertype,
      this.dob,
      this.country,
      this.dp});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      firstname: json['first_name'],
      lastname: json['last_name'],
      usertype: json['user_type'],
      dob: json['dob'],
      country: json['country'],
      dp: json['profile_pic_url'] ??
          'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png',
    );
  }
}
