import 'package:flutter/services.dart';

Future<void> lightHapticImpact() => HapticFeedback.lightImpact();

Future<void> heavyHapticImpact() => HapticFeedback.heavyImpact();
