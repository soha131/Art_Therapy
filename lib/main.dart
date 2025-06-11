import 'package:arttherapy/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'cubit/Art_cubit.dart';
import 'cubit/auth_cubit.dart';
import 'hisrory.dart';
import 'login.dart';
import 'models/local_language.dart';
import 'setting.dart';
import 'signup.dart';
import 'upload_file.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ArtCubit()),
        BlocProvider(create: (context) => AuthCubit()),
      ],
      child: Directionality( textDirection: TextDirection.rtl,child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final box = Hive.box('settings');
    String langCode = box.get('language', defaultValue: 'en');
    setState(() {
      _locale = Locale(langCode);
    });
  }

  void _changeLanguage(String langCode) {
    final box = Hive.box('settings');
    box.put('language', langCode);
    setState(() {
      _locale = Locale(langCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          _locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: MaterialApp(
        locale: _locale,
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ar', 'EG'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xff736253),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
        routes: {
          "Login": (context) => LoginScreen(),
          "Signup": (context) => SignUpScreen(),
          "Setting":
              (context) => SettingsScreen(
                onLanguageChange: _changeLanguage,
                currentLocale: _locale,
              ),
          "History": (context) => HistoryScreen(),
          "upload": (context) => UploadFileScreen(),
          "update": (context) => UpdateProfileScreen(),
        },
      ),
    );
  }
}
