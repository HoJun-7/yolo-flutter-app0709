class User {
  final int? id; // user_id 또는 doctor_id
  final String registerId;
  final String? name;
  final String? gender;
  final String? birth;
  final String? phone;
  final String role; // 💡 String? 에서 String으로 변경 (기본값 설정 예정)

  User({
    required this.id,
    required this.registerId,
    this.name,
    this.gender,
    this.birth,
    this.phone,
    required this.role, // 💡 role을 필수 값으로 변경
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as int? ?? json['doctor_id'] as int?,
      registerId: json['register_id'] as String, // register_id도 필수이므로 as String 추가
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      birth: json['birth'] as String?,
      phone: json['phone'] as String?,
      // 💡 수정: role이 null이거나 다른 타입일 경우 빈 문자열로 처리 후 toUpperCase() 적용
      role: (json['role'] as String? ?? '').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'register_id': registerId,
      'name': name,
      'gender': gender,
      'birth': birth,
      'phone': phone,
      'role': role,
    };
  }

  // ✅ Doctor 여부를 확인하는 getter
  // 💡 수정: role이 이미 toUpperCase() 되어있으므로 'D'와 직접 비교
  bool get isDoctor => role == 'D';
}
