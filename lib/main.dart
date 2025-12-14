import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodel.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 모든 텍스트 스타일을 흰색으로 설정하는 TextTheme
    const whiteTextTheme = TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      displayLarge: TextStyle(color: Colors.white),
      displayMedium: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white),
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Colors.white),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InterviewViewModel()),
      ],
      child: MaterialApp(
        title: 'Interview Dashboard',
        theme: ThemeData(
          // 기본 색상표를 어둡게 설정
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          // Scaffold의 기본 배경색을 어둡게 설정하여 흰색 텍스트가 잘 보이도록 함
          scaffoldBackgroundColor: Colors.grey[900],
          // 텍스트 테마 적용
          textTheme: whiteTextTheme,
          // 아이콘 색상도 흰색으로 통일
          iconTheme: const IconThemeData(color: Colors.white),
          fontFamily: 'NotoSansKR',
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}