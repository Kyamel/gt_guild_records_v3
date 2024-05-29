import 'package:flutter/material.dart';
import 'package:gt_guild_records_v2/layout/home_page.dart';
import 'package:gt_guild_records_v2/main.dart';
import 'package:url_launcher/url_launcher.dart';

class ThemePage extends StatefulWidget {
  final ThemeManager themeManager;

  const ThemePage({super.key, required this.themeManager});

  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  Color? selectedColor;
  bool _isSnackbarVisible = false;
  late String themeMode;
  final bool _proVersion =  true;
  // Lista de cores para selecionar
  final List<Color> themeColors = [
    Colors.red,
    Colors.redAccent,
    Colors.pink,
    Colors.pinkAccent,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.orange,
    Colors.orangeAccent,
    Colors.yellow,
    Colors.yellowAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.lightGreen,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.purple,
    Colors.purpleAccent,
    Colors.blue,
    Colors.blueAccent,
    Colors.lightBlue,
    Colors.lightBlueAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.teal,
    Colors.tealAccent,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    themeMode = _getThemeModeString(widget.themeManager.getMode());
    
    selectedColor = widget.themeManager.getLightColor();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This method will be called every time the dependencies change
    themeMode = _getThemeModeString(widget.themeManager.getMode());
    selectedColor = widget.themeManager.getLightColor();
  }

  void _updateTheme(Color color) {
    setState(() {
      widget.themeManager.setLightTheme(color);
      widget.themeManager.setDarkTheme(color);
      selectedColor = color;
    });
  }
  void _showThemeChangeMessage(BuildContext context) {
    if (!_isSnackbarVisible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme will apply after application restart.'),
        ),
      );
      _isSnackbarVisible = true;

      // Configura um temporizador para redefinir _isSnackbarVisible após um período de tempo
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _isSnackbarVisible = false;
        });
      });
    }
  }

  int _getThemeModeInt(String mode) {
    switch (mode) {
      case 'Light':
        return 1;
      case 'Dark':
        return -1;
      case 'System':
      default:
        return 0;
    }
  }

  String _getThemeModeString(int mode) {
    switch (mode) {
      case 1:
        return 'Light';
      case -1:
        return 'Dark';
      case 0:
      default:
        return 'System';
    }
  }

  void _showProVersionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upgrade to Pro Version'),
          content: const Text('To customize yout theme, please upgrade to the Pro version. This helps support the developer.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Download'),
              onPressed: () async {
                final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=your_app_id');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  // Can't launch URL, handle the error
                
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open the Play Store')),
                    );
                  
                }
               
                  Navigator.of(context).pop();
                
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Envolver o Column com SingleChildScrollView
        child: Center(
          child: Padding(
             padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Select a theme color:',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        blurRadius: 10.0,
                        spreadRadius: 4.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: themeColors.map((color) {
                       return GestureDetector(
                        onTap: () {
                          selectedColor = color;
                            if (_proVersion) {
                              setState(() {
                                selectedColor = Colors.blue; // Replace with the actual color selection logic
                                _updateTheme(color);
                                _showThemeChangeMessage(context);
                              });
                            } else {
                              _showProVersionDialog();
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: selectedColor == color ? Theme.of(context).colorScheme.surface : Colors.transparent,
                                width: 4.0,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Selected theme:  ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Definindo o texto como negrito
                                    // Você pode adicionar outras propriedades de estilo aqui, como cor, tamanho da fonte, etc.
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: themeMode, // Use a função _getThemeModeString para obter o valor atual do themeMode
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      themeMode = newValue!;
                                      int newMode = _getThemeModeInt(newValue);
                                      if (newMode == 1) {
                                        widget.themeManager.setThemeMode(darkMode: false);
                                      } else if (newMode == -1) {
                                        widget.themeManager.setThemeMode(darkMode: true);
                                      } else if (newMode == 0) {
                                        widget.themeManager.setThemeMode();
                                      }
                                    });
                                    _showThemeChangeMessage(context);
                                  },
                                  items: <String>['System', 'Light', 'Dark']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  widget.themeManager.setDefaultTheme();
                                  setState(() {
                                    themeMode = _getThemeModeString(widget.themeManager.getMode());
                                    
                                  });
                                  _showThemeChangeMessage(context);
                                },
                                icon: const Icon(Icons.restore), // Ícone de remoção
                                label: const Text('Restore default'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 0, // Índice inicial selecionado
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/database');
              break;
            case 2:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/print');
              break;
            case 3:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/extract');
              break;
            case 4:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ocr');
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}
