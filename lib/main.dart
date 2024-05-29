import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gt_guild_records_v2/layout/rebuild_page.dart';
import 'package:gt_guild_records_v2/layout/settings_page.dart';
import 'package:gt_guild_records_v2/layout/theme_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '/layout/home_page.dart';
import 'database/database.dart';
import 'layout/database_page.dart';
import 'layout/print_page.dart';
import 'layout/open_page.dart';
import 'layout/extract_page.dart';
import 'layout/ocr_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final path = prefs.getString('folderPath') ?? 'undefined';
  final databaseManager = DatabaseManager(path);
  ThemeManager themeManager = ThemeManager(prefs);

  Logger.log('\n>>>>>> INITIALIZING APP <<<<<<\n');
  await requestPermissions();
  
  runApp(MyApp(databaseManager: databaseManager, prefs: prefs, themeManager: themeManager));
}

Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    // Verifica se a permissão de leitura externa já foi concedida
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // Solicita permissão de leitura e escrita externa
      var result = await Permission.storage.request();
      if (result.isDenied) {
        // Trate a negação da permissão se necessário
      }
    }
  }
}

class MyApp extends StatefulWidget {
  final DatabaseManager databaseManager;
  final SharedPreferences prefs;
  final ThemeManager themeManager;

  const MyApp({super.key, required this.prefs, required this.databaseManager, required this.themeManager});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  @override
  void dispose() {
    widget.databaseManager.closeDatabase();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GT Guild Records',
      theme: widget.themeManager._themeLight,
      darkTheme: widget.themeManager._themeDark,
      themeMode: widget.themeManager.themeMode,
      home: HomePage(databaseManager: widget.databaseManager),                  
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) {
            // Aqui você pode decidir qual widget retornar com base na rota
            switch (settings.name) {
              case '/home':
                return HomePage(databaseManager: widget.databaseManager);
              case '/database':
                return DatabasePage(databaseManager: widget.databaseManager);
              case '/print':
                return PrintPage(databaseManager: widget.databaseManager);
              case '/extract':
                return ExtractPage(databaseManager: widget.databaseManager);
              case '/ocr':
                return OcrPage(databaseManager: widget.databaseManager);
              case '/open':
                return OpenPage(databaseManager: widget.databaseManager, prefs: widget.prefs);
              case '/theme': 
                return ThemePage(themeManager: widget.themeManager);
              case '/settings':
                return SettingsPage(databaseManager: widget.databaseManager);
              case '/rebuild':
                return RebuildPage(databaseManager: widget.databaseManager);
              default:
                return HomePage(databaseManager: widget.databaseManager); // Página padrão, caso a rota não seja encontrada
            }
          },
        );
      },
    );
  }
}

class MyAppLifecycleObserver extends WidgetsBindingObserver {
  final DatabaseManager databaseManager;

  MyAppLifecycleObserver({required this.databaseManager});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      databaseManager.closeDatabase();
    } else if (state == AppLifecycleState.resumed) {
      databaseManager.openDatabase();
    }
  }
}

class ThemeManager extends ChangeNotifier {
  ThemeData _themeLight;
  ThemeData _themeDark;
  ThemeMode _themeMode;
  int _mode;
  Color _colorLight;
  Color _colorDark;
  final SharedPreferences prefs;

  ThemeManager._internal(this.prefs)
      : _themeLight = ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Color(prefs.getInt('lightThemeColor') ?? Colors.green.value),
        ),
        _themeDark = ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: Color(prefs.getInt('darkThemeColor') ?? Colors.deepPurple.value),
        ),
        _mode = prefs.getInt('themeMode') ?? 0,
        _colorLight = Color(prefs.getInt('lightThemeColor') ?? Colors.green.value),
        _colorDark = Color(prefs.getInt('darkThemeColor') ?? Colors.deepPurple.value),
        _themeMode = ThemeMode.system {
    _themeMode = _mode == 1 ? ThemeMode.light : (_mode == -1 ? ThemeMode.dark : ThemeMode.system);
  }

  factory ThemeManager(SharedPreferences prefs) {
    return ThemeManager._internal(prefs);
  }

  ThemeData get theme => _themeLight;
  ThemeData get themeDark => _themeDark;
  ThemeMode get themeMode => _themeMode;
  int getMode() => _mode;

  void setLightTheme(Color themeColor) {
    _themeLight = ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: themeColor,
    );
    prefs.setInt('lightThemeColor', themeColor.value);
    notifyListeners();
  }

  void setDarkTheme(Color themeColor) {
    _themeDark = ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: themeColor,
    );
    prefs.setInt('darkThemeColor', themeColor.value);
    notifyListeners();
  }

  void setDefaultTheme() {
    _themeLight = ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: Color(Colors.green.value),
    );
    prefs.setInt('lightThemeColor', Colors.green.value);
    _themeDark = ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Color(Colors.deepPurple.value),
    );
    prefs.setInt('darkThemeColor', Colors.deepPurple.value);
    prefs.setInt('themeMode', 0);
    _mode = 0;
    _colorLight = Colors.green;
    _colorDark = Colors.deepPurple;
    notifyListeners();
  }

  void setThemeMode({bool? darkMode}) {
    if (darkMode == true) {
      _themeMode = ThemeMode.dark;
      _mode = -1;
      prefs.setInt('themeMode', -1);
    } else if (darkMode == false) {
      _themeMode = ThemeMode.light;
      _mode = 1;
      prefs.setInt('themeMode', 1);
    } else {
      _themeMode = ThemeMode.system;
      _mode = 0;
      prefs.setInt('themeMode', 0);
    }
    notifyListeners();
  }

  void setLightColor(Color color) {
    _colorLight = color;
    prefs.setInt('lightThemeColor', color.value);
    notifyListeners();
  }

  void setDarkColor(Color color) {
    _colorDark = color;
    prefs.setInt('darkThemeColor', color.value);
    notifyListeners();
  }

  Color getLightColor() => _colorLight;

  Color getDarkColor() => _colorDark;
}
