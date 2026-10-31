import 'package:flutter/foundation.dart';

import 'json_utils.dart';

@immutable
class UserProfile {
  final String uid;
  final String email;
  final String name;
  final bool isAdmin;

  /// Avatar uchun tanlangan rang indeksi (rasm yuklashsiz shaxsiylashtirish).
  final int avatarColor;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.avatarColor = 0,
  });

  String get displayName =>
      name.trim().isNotEmpty ? name.trim() : email.split('@').first;

  factory UserProfile.fromJson(
    String uid,
    String email,
    Map<String, dynamic> json, {
    bool isAdmin = false,
  }) =>
      UserProfile(
        uid: uid,
        email: email,
        name: asString(json['name']),
        avatarColor: asInt(json['avatarColor']),
        isAdmin: isAdmin,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarColor': avatarColor,
      };

  UserProfile copyWith({String? name, int? avatarColor, bool? isAdmin}) =>
      UserProfile(
        uid: uid,
        email: email,
        name: name ?? this.name,
        avatarColor: avatarColor ?? this.avatarColor,
        isAdmin: isAdmin ?? this.isAdmin,
      );
}
