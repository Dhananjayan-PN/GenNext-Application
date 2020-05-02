class User {
  String email;
  String username;
  String firstname;
  String lastname;
  String usertype;
  String dob;
  String country;

  User({
    this.email,
    this.username,
    this.firstname,
    this.lastname,
    this.usertype,
    this.dob,
    this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      username: json['username'],
      firstname: json['first_name'],
      lastname: json['last_name'],
      usertype: json['user_type'],
      dob: json['dob'],
      country: json['coutry'],
    );
  }
}
