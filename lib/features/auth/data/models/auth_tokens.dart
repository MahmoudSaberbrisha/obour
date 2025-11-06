class AuthTokens {
  final String accessToken;
  final String? refreshToken;
  final String? userName;
  final String? userEmail;
  final String? identificationType;
  final String? identificationNumber;

  AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.userName,
    this.userEmail,
    this.identificationType,
    this.identificationNumber,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    String? userName;
    String? userEmail;
    String? identificationType;
    String? identificationNumber;

    if (json['data'] != null && json['data']['user'] != null) {
      final user = json['data']['user'];
      userName = user['name']?.toString();
      userEmail = user['email']?.toString();
      identificationType = user['identification_type']?.toString();
      identificationNumber = user['identification_number']?.toString();
    } else {
      userName = json['userName']?.toString() ?? json['name']?.toString() ?? json['username']?.toString();
      userEmail = json['userEmail']?.toString() ?? json['email']?.toString();
      identificationType = json['identification_type']?.toString();
      identificationNumber = json['identification_number']?.toString();
    }

    return AuthTokens(
      accessToken:
          json['token'] ?? json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      userName: (userName != null && userName.isNotEmpty) ? userName : null,
      userEmail: (userEmail != null && userEmail.isNotEmpty) ? userEmail : null,
      identificationType: (identificationType != null && identificationType.isNotEmpty) ? identificationType : null,
      identificationNumber: (identificationNumber != null && identificationNumber.isNotEmpty) ? identificationNumber : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    if (userName != null) 'userName': userName,
    if (userEmail != null) 'userEmail': userEmail,
    if (identificationType != null) 'identification_type': identificationType,
    if (identificationNumber != null)
      'identification_number': identificationNumber,
  };
}
