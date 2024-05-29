import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gt_guild_records_v2/layout/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';
import 'package:path/path.dart' as path;

class OpenPage extends StatefulWidget {
  final SharedPreferences prefs;
  final DatabaseManager databaseManager;

  const OpenPage({super.key, required this.databaseManager, required this.prefs});

  @override
   createState() => OpenPageState();
}

class OpenPageState extends State<OpenPage> {
  String folderPath = 'undefined';
  String databaseName = 'GTGuildRecords';
  final butttonWidth = 180.0;
  final buttonHeight = 40.0;

  @override
  void initState() {
    super.initState();
    folderPath = widget.prefs.getString('folderPath') ?? 'undefined';
  }

  @override
  Widget build(BuildContext context) {
    var name = widget.databaseManager.getName();
    String fullPath = path.join(widget.databaseManager.getPath(), '$name.db');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 const Text(
                  "On android, Pick file will make a copy of your database file inside the app's internal storage. "
                  "Use Save to external storage to copy it back to your phone's external storage.",
                  textAlign: TextAlign.center, 
                ),
                const SizedBox(height: 8),
                const Text(
                  "On android, if you use Pick file and then use Pick file again without before using Save to external storage to copy "
                  "your database file to your phone's external storage, you will lose any changes mades in your database file.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "On android, due to memory restricciones, some folders may not work to save your database file.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height:8),
                 Container(
                  padding: const EdgeInsets.all(4.0), // Padding interno do container
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer, // Cor de fundo
                    borderRadius: BorderRadius.circular(12.0), // Bordas levemente arredondadas
                  ),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Selected name: ',
                              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color),
                            ),
                            WidgetSpan(
                              child: SelectableText(
                                widget.databaseManager.getName(),
                                style: const TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Selected Folder: ',
                              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color),
                            ),
                            WidgetSpan(
                              child: SelectableText(
                                widget.databaseManager.getPath(),
                                style: const TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy full path',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: fullPath));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Full path copied to clipboard'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                  // Define o tamanho fixo do Container como uma fração da largura disponível
                  return SizedBox( 
                    child: Container(
                      padding: const EdgeInsets.all(4.0), // Padding interno do container
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer, // Cor de fundo
                        borderRadius: BorderRadius.circular(12.0), // Bordas levemente arredondadas
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.spaceEvenly, 
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: butttonWidth,
                                  height: buttonHeight,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      var path = await FilePicker.platform.getDirectoryPath() ?? 'undefined';
                                      if (path != 'undefined') {
                                        if(widget.databaseManager.isOpen){
                                          widget.databaseManager.closeDatabase();
                                        }
                                        widget.databaseManager.setPath(path);                       
                                        await widget.databaseManager.openDatabase();  
                                        widget.databaseManager.initTables();    
                                        widget.databaseManager.createTables();
                                        widget.prefs.setString('folderPath', path);
                                        setState(() {
                                          folderPath = path;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.folder_open), // Ícone para abrir a pasta
                                    label: const Text('Select folder'),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: butttonWidth,
                                  height: buttonHeight,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      String path = await widget.databaseManager.pickDatabaseFile();
                                      if(path != 'undefined'){
                                        widget.databaseManager.initTables();
                                        widget.databaseManager.createTables();
                                        widget.prefs.setString('folderPath', path);
                                        setState(() {
                                          folderPath = path;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.file_upload), // Ícone para selecionar um arquivo
                                    label: const Text('Pick file'),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: butttonWidth,
                                  height: buttonHeight,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      int response = await widget.databaseManager.moveDatabaseToExternalFolder();
                                      setState(() {
                                        showSnackBarMessage(context, response);
                                      });
                                    },
                                    icon: const Icon(Icons.save), // Ícone para selecionar um arquivo
                                    label: const Text('Save to external storage'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 512, // Defina o tamanho máximo do TextFormField
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter database name',
                    ),
                    onEditingComplete: () {
                      setState(() {
                        if(databaseName == ''){
                          databaseName = 'GTGuildRecords';
                        }
                        widget.databaseManager.setName(databaseName);
                      });
                    },
                    onChanged: (value) {
                      // Atualize a variável databaseName sempre que o texto for alterado
                      setState(() {
                        databaseName = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/database');
              break;
            case 2:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/print');
              break;
            case 3:
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/extract');
              break;
            case 4:
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

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0, // Sem sombra
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Borda com curvas
              ),
              icon: const Icon(
                Icons.home,
              ),
              label: const Text(
                'Home',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showSnackBarMessage(BuildContext context, int response) {
  Color backgroundColor = Colors.white;
  Color textColor = Colors.white;
  String message;

  if (response == 1) {
    backgroundColor = Colors.yellow;
    textColor = Colors.black;
    message = 'No folder selected';
  } else if (response == 0) {
    backgroundColor = Colors.green;
    message = 'Backup successfully done';
  } else if (response == -1) {
    backgroundColor = Colors.red;
    message = 'Error: Try another folder';
  }
  else {
    backgroundColor = Colors.purple;
    textColor = Colors.black;
    message = 'Unknow error';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        message,
        textAlign: TextAlign.center,
         style: TextStyle(color: textColor),
      ),
    ),
  );
}