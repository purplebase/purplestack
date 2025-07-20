import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final brightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);
