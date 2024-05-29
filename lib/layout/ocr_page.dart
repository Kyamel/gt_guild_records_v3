import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:gt_guild_records_v2/database/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';

class OcrPage extends StatefulWidget {
  final DatabaseManager databaseManager;

  const OcrPage({super.key, required this.databaseManager});

  @override
  _OcrPageState createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  String _text = "Raid Title    MM/DD/YYYY    SXX    RXX\n";  // Inicialmente, coloque algum texto de exemplo
  final ImagePicker _picker = ImagePicker();
  bool _isSnackbarVisible = false;
  String raidTitle = 'Raid tiitle';
  String raidDate = 'MM/DD/YYYY';
  String raidSeason = 'SXX';
  String raidRanking = 'RXX';
  final _textController = TextEditingController();

   @override
  void initState() {
    super.initState();
    _textController.text = _text;
    _textController.addListener(_updateText);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateText);
    _textController.dispose();
    super.dispose();
  }

  void _updateText() {
    setState(() {
      _text = _textController.text;
    });
  }

  void _copyText() {
    if (!_isSnackbarVisible) {
      Clipboard.setData(ClipboardData(text: _text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
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

  void _clearText() {
    setState(() {
        String header = [raidTitle, raidDate, raidSeason, raidRanking].join('    ');
        _text = '$header\n';
        _textController.text = _text;
    });
  }

  void _saveText() {   
    var result = extractData(_text);
    _text = _convertListToString(result);
    _textController.text = _text;
    if (!_isSnackbarVisible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trying to save text into the database')),
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      '''
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageCrop(
            imageFile: image,
            onCrop: (rect) {
              _performOcr(image, rect);
            },
          ),
        ),
      );
      ''';
      _performOcr(image);
    }
  }

  Future<void> _performOcr(XFile image) async {
    try {
      String ocrText = await FlutterTesseractOcr.extractText(
        image.path,
        language: 'eng',
        args: {
          "psm": "4",
          "preserve_interword_spaces": "0",
          "tessedit_char_blacklist": "@©®&*!{}{[]()+='#-*+",
        },
      );
      setState(() {
        List<List<String>> result = _processText(ocrText);
        var aux =_convertListToString(result);
        _text += '\n$aux';
        _textController.text = _text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro executing OCR: $e')),
      );
    }finally {
      // Delete the image after OCR processing
      try {
        final file = File(image.path);
        await file.delete();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: $e')),
        );
      }
    }
  }

  String _convertListToString(List<List<dynamic>> data) {
    return data.map((entry) => entry.join('    ')).join('\n');
  }

  List<List<String>> _processText(String data) {
    List<List<String>> result = [];
    // Separar linhas
    List<String> lines = data.trim().split('\n');
    // Regular expressions para os padrões
    RegExp nameRegExp = RegExp(r'(\S+)\s+Lv\.(\d+)\s+(\d+/\d+)\s+([\d,]+)');
    for (var line in lines) {
      RegExpMatch? match = nameRegExp.firstMatch(line);
      if (match != null) {
        String name = match.group(1)!.trim();
        //String level = match.group(2)!;
        String participation = match.group(3)!.trim();
        String damage = match.group(4)!.trim();

        result.add([name, participation, damage]);
      }
    }

    return result;
  }

  void _setRaid(String header){
    setState(() {
      List<String> lines = _text.split('\n');
      if (lines.isNotEmpty) {
        lines[0] = header;
      }
      _text = lines.join('\n');
      _textController.text = _text;
    });
  }

  List<List<dynamic>> extractData(String input) {
    // Split the input into lines and filter out empty lines
    List<String> lines = input.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // Define the regex for splitting columns by three or more spaces
    RegExp columnRegex = RegExp(r'\s{3,}');

    // Process the first line separately to get title, date, number, and ranking
    List<String> firstLineColumns = lines[0].split(columnRegex);

    String title = firstLineColumns[0].trim();
    String date = firstLineColumns[1].trim();
    int number = int.parse(firstLineColumns[2].replaceAll('S', '').trim());
    int ranking = int.parse(firstLineColumns[3].replaceAll('R', '').trim());

    List<dynamic> headerData = [title, date, number, ranking];
    try{
      widget.databaseManager.addRaid(title, date, number, ranking);
    }catch(e){
      debugPrint('Error: inserting raid: $e');
    }
    // Process the remaining lines for name, participation, and damage
    List<List<dynamic>> result = [headerData];

    for (int i = 1; i < lines.length; i++) {
      List<String> columns = lines[i].split(columnRegex);

      if (columns.length == 3) {
        String name = columns[0].trim();
        String participation = columns[1].replaceAll('/', '').trim();
        int damage = int.parse(columns[2].replaceAll(',', '').trim());

        result.add([name, participation, damage]);
        try{
          widget.databaseManager.addMember(name, 'undefined');
          widget.databaseManager.addMemberInRaid(name, title, damage, participation);
        }catch(e){
          debugPrint('Error inserting member or member in raid: $e');
        }    
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondaryContainer, // Cor da linha demarcadora
                      width: 1.0, // Largura da linha
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _textController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(8.0),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete all',
                            onPressed: _clearText,
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy all',
                            onPressed: _copyText,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: IconButton(
                          icon: const Icon(Icons.settings),
                          tooltip: 'Set raid',
                          onPressed: () {
                            _showAddRaidDialog(context);
                          },
                        ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: IconButton(
                        icon: const Icon(Icons.image),
                        tooltip: 'Select image',
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child:  Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: IconButton(
                        icon: const Icon(Icons.save_alt),
                        tooltip: 'Save',
                        onPressed: _saveText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 4, // Índice inicial selecionado
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pop(context);
              Navigator.pushNamed(context, '/database');
              break;
            case 2:
              Navigator.pop(context);
              Navigator.pushNamed(context, '/print');
              break;
            case 3:
              Navigator.pop(context);
              Navigator.pushNamed(context, '/extract');
              break;
            case 4:
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

  void _showAddRaidDialog(BuildContext context){
    String title = raidTitle;
    String date = raidDate;
    String season = raidSeason;
    String ranking = raidRanking;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return AlertDialog(
          title: const Text('Set Raid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter title'),
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if(value.isNotEmpty){
                    title = value;
                    raidTitle = value;
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter date'),
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if(value.isNotEmpty){
                     date = value;
                     raidDate = value;
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter season'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if(value.isNotEmpty){
                    season = 'S$value';
                    raidSeason = season;
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter ranking'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if(value.isNotEmpty){
                    ranking = 'R$value';
                    raidRanking = ranking;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(content).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ()async{
                int result = 0;
                try{
                  String header = [title, date, season, ranking].join('    ');
                  _setRaid(header);
                }catch(e){
                  result = -1;
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save')),
          ],
        );
      },
    );
  }
}

class ImageCrop extends StatefulWidget {
  final XFile imageFile;
  final Function(Rect) onCrop;

  const ImageCrop({required this.imageFile, required this.onCrop});

  @override
  _ImageCropState createState() => _ImageCropState();
}

class _ImageCropState extends State<ImageCrop> {
  ui.Image? _image;
  Offset? _start;
  Offset? _end;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await widget.imageFile.readAsBytes();
    final image = await decodeImageFromList(data);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _crop,
          ),
        ],
      ),
      body: _image == null
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _start = details.localPosition;
                  _end = _start;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _end = details.localPosition;
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _end = details.localPosition;
                });
              },
              child: Stack(
                children: [
                  Center(
                    child: CustomPaint(
                      painter: ImagePainter(_image!, _start, _end),
                      child: Container(),
                    ),
                  ),
                  if (_start != null && _end != null)
                    Positioned(
                      left: _start!.dx,
                      top: _start!.dy,
                      child: Container(
                        width: _end!.dx - _start!.dx,
                        height: _end!.dy - _start!.dy,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  void _crop() {
    if (_start == null || _end == null) return;

    final rect = Rect.fromPoints(_start!, _end!);
    widget.onCrop(rect);
    Navigator.pop(context);
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final Offset? start;
  final Offset? end;

  ImagePainter(this.image, this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final src = Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
    final dst = Offset.zero & size;

    canvas.drawImageRect(image, src, dst, paint);

    if (start != null && end != null) {
      final rectPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRect(Rect.fromPoints(start!, end!), rectPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
