import 'package:flutter/material.dart';
import '../../../screens/drivers/driver_profile.dart';

class ProfileSection extends StatelessWidget {
  final String token;
  final String userName;

  const ProfileSection({
    super.key,
    required this.token,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return DriverProfileScreen(token: token);
  }
}