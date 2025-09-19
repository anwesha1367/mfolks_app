class AppUser {
  final String? fullname;
  final String? email;
  final int? countryCode;
  final String? phone;
  final String? profilePictureUrl;
  final int? industryId;
  final bool? hasPassword;

  const AppUser({
    this.fullname,
    this.email,
    this.countryCode,
    this.phone,
    this.profilePictureUrl,
    this.industryId,
    this.hasPassword,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      fullname: json['fullname'] as String?,
      email: json['email'] as String?,
      countryCode: (json['country_code'] is String)
          ? int.tryParse(json['country_code'] as String)
          : json['country_code'] as int?,
      phone: (json['phone']?.toString()),
      profilePictureUrl: json['profile_picture_url'] as String?,
      industryId: (json['industry_id'] is String)
          ? int.tryParse(json['industry_id'] as String)
          : json['industry_id'] as int?,
      hasPassword: (json['has_password'] is bool)
          ? json['has_password'] as bool
          : (json['has_password']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() => {
        'fullname': fullname,
        'email': email,
        'country_code': countryCode,
        'phone': phone,
        'profile_picture_url': profilePictureUrl,
        'industry_id': industryId,
        'has_password': hasPassword,
      };

  AppUser copyWith({
    String? fullname,
    String? email,
    int? countryCode,
    String? phone,
    String? profilePictureUrl,
    int? industryId,
    bool? hasPassword,
  }) {
    return AppUser(
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      industryId: industryId ?? this.industryId,
      hasPassword: hasPassword ?? this.hasPassword,
    );
  }
}


