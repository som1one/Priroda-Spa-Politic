// Пример файла main.dart после настройки Firebase
// Переименуйте этот файл в main.dart или скопируйте код в существующий main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Этот файл будет создан после выполнения flutterfire configure
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

