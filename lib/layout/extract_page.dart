import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gt_guild_records_v2/layout/home_page.dart';
import '../database/database.dart';

class ExtractPage extends StatefulWidget {
  final DatabaseManager databaseManager;

  const ExtractPage({super.key, required this.databaseManager});

  @override
  _ExtractPageState createState() => _ExtractPageState();
}

class _ExtractPageState extends State<ExtractPage> {
  final TextEditingController _textEditingController = TextEditingController();
  List<List<String>> extractedData = [];
  String saveOption = 'Discord'; // Opção padrão
  bool _isSnackbarVisible = false;

  void _copyText() {
    if (!_isSnackbarVisible) {
      Clipboard.setData(ClipboardData(text: _textEditingController.text));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extract'),
        centerTitle: true,
      ),
      body: Column(
        children: [
         Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  TextField(
                    controller: _textEditingController,
                    maxLines: null, // Permite várias linhas de texto
                    expands: true, // Expande o campo de texto para preencher o espaço disponível
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      hintText: "See Extract templates in Home page.\nSelect a template to extract "
                          "\nusing the button below.\nPaste text here folowing this template,\nthen use the Save button:"
                          "\nIt will extract the pasted text \nand save into the database..."
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy all',
                      onPressed: _copyText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 9.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: saveOption,
                          onChanged: (String? newValue) {
                            setState(() {
                              saveOption = newValue!;
                            });
                          },
                          items: <String>['Discord', 'Google Lens', 'CopyFish'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        IconButton(
                          icon: const Tooltip(
                            message: 'Save', // Texto explicativo exibido ao segurar o ícone
                            child: Icon(Icons.save_alt),
                          ),
                          onPressed: () {
                            if (saveOption == 'Discord') {
                              saveDataFromDiscord();
                            } else if (saveOption == 'Google Lens') {
                              saveDataFromLens();
                            }else if(saveOption == 'CopyFish'){
                              saveDataFromCopyFish();
                            }
                          },   
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 3, // Índice inicial selecionado
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
  void saveDataFromCopyFish()async{
    String text = _textEditingController.text;
    List<String> lines = text.split('\n');

     if (lines.isNotEmpty) {
      // Expressão regular para encontrar o título da raid até o primeiro número
      RegExp regExp = RegExp(r'^(.*?)(?=\d)');
      // Encontra o título da raid usando a expressão regular
      String raidTitle = regExp.firstMatch(lines.first)?.group(0) ?? '';
      // Remove espaços extras do título
      raidTitle = raidTitle.trim();
      // Remove o título da linha para obter as informações restantes
      String remainingInfo = lines.first.replaceFirst(raidTitle, '');
      // Separa a data e o número usando espaços como delimitador
      List<String> dateAndNumber = remainingInfo.trim().split(RegExp(r'\s+'));
      String date = dateAndNumber.first;
      RegExp raidNumberRegExp = RegExp(r'S(\d+)');
      String number = raidNumberRegExp.firstMatch(lines.first)?.group(1) ?? '';
      RegExp raidRankingRegExp = RegExp(r'R(\d+)');
      String raidRanking = raidRankingRegExp.firstMatch(lines.first)?.group(1) ?? '';
  

      List<String> names = [];
      List<int> damages = [];
      List<String> participations = [];

    // Expressões regulares para capturar o nome, participação e dano
  // Expressões regulares para capturar o nome, participação e dano
  RegExp nameRegExp = RegExp(r'^([^0-9]+)(?:\s+Lv\.\d+|LV\.\d+)?$');
  RegExp participationRegExp = RegExp(r'(\d+)/(\d+)'); // Alterada para capturar o formato "21/21"
  RegExp damageRegExp = RegExp(r'(\d{1,3}(?:,\d{3})*,\d{1,3})');

    // Loop pelas linhas para extrair os dados
  for (int i = 1; i < lines.length; i++) {
    String line = lines[i].trim();

    // Tentar extrair o nome
    Match? nameMatch = nameRegExp.firstMatch(line);
    if (nameMatch != null) {
      String name = nameMatch.group(1)?.trim() ?? '';
      names.add(name);
      continue; // Passa para a próxima linha
    }

    // Tentar extrair a participação
    Match? participationMatch = participationRegExp.firstMatch(line);
   if (participationMatch != null) {
      String participation = '${participationMatch.group(1)}${participationMatch.group(2)}'; // Remover a barra '/'
      participations.add(participation);
      continue; // Passa para a próxima linha
    }
    // Tentar extrair o dano
    Match? damageMatch = damageRegExp.firstMatch(line);
    if (damageMatch != null) {
      String damageString = damageMatch.group(1) ?? '';
      int damage = int.tryParse(damageString.replaceAll(',', '')) ?? 0;
      damages.add(damage);
    }
  }
    // Exibir os dados extraídos
    debugPrint('Título da Raid: $raidTitle');
    debugPrint('Data: $date');
    debugPrint('Número: $number');
    debugPrint('Nomes: $names');
    debugPrint('Danos: $damages');
    debugPrint('Participações: $participations');

      widget.databaseManager.addRaid(raidTitle, date, int.tryParse(number) ?? -1, int.tryParse(raidRanking) ?? 0); //Corrigir addRaid 0
      if (names.length == damages.length && damages.length == participations.length) {
        for (int i = 0; i < names.length; i++) {
          widget.databaseManager.addMember(names[i], 'undefined');
          widget.databaseManager.addMemberInRaid(names[i], raidTitle, damages[i], participations[i].toString());
        }
      }
      _textEditingController.clear();  
    }
  }
  void saveDataFromDiscord() async {
    String text = _textEditingController.text;
    List<String> lines = text.split('\n');
    if (lines.isNotEmpty) {
      // Expressão regular para encontrar o título da raid até o primeiro número
      RegExp regExp = RegExp(r'^(.*?)(?=\d)');
      // Encontra o título da raid usando a expressão regular
      String raidTitle = regExp.firstMatch(lines.first)?.group(0) ?? '';
      // Remove espaços extras do título
      raidTitle = raidTitle.trim();
      // Remove o título da linha para obter as informações restantes
      String remainingInfo = lines.first.replaceFirst(raidTitle, '');
      // Separa a data e o número usando espaços como delimitador
      List<String> dateAndNumber = remainingInfo.trim().split(RegExp(r'\s+'));
      String date = dateAndNumber.first;
      RegExp raidNumberRegExp = RegExp(r'S(\d+)');
      String number = raidNumberRegExp.firstMatch(lines.first)?.group(1) ?? '';
      RegExp raidRankingRegExp = RegExp(r'R(\d+)');
      String raidRanking = raidRankingRegExp.firstMatch(lines.first)?.group(1) ?? '';
  
      List<String> names = [];
      List<int> damages = [];
      List<int> participations = [];
      // Loop pelas linhas restantes para extrair os dados dos membros
     RegExp regex = RegExp(r'^(\d+)\.\s+([\w\d]+)\s+(\d+(?:,\d+)*)\s+(\d+)\/(\d+)$');

      for (int i = 1; i < lines.length; i++) {
        String line = lines[i];
        
        // Verifica se a linha corresponde ao padrão usando a expressão regular
        RegExpMatch? match = regex.firstMatch(line);
        
        if (match != null) {
          // Extrai os dados do membro
          String? name = match.group(2);
          
          // Verifica se o nome não é nulo
          if (name != null) {
            // Remove as vírgulas dos danos e converte para inteiro
            String? damageString = match.group(3)?.replaceAll(',', '');
            int? damage = damageString != null ? int.tryParse(damageString) : null;

            // Extrai a participação e converte para inteiro
            String? participationString = match.group(4);
          participationString ??= '';
            participationString += match.group(5) ?? '';
            int participation = int.tryParse(participationString) ?? -1;

            // Verifica se damage e participation não são nulos antes de adicioná-los às listas
            if (damage != null) {
              names.add(name);
              damages.add(damage);
              participations.add(participation);
            }
          }
        }
      }
      widget.databaseManager.addRaid(raidTitle, date, int.tryParse(number) ?? -1, int.tryParse(raidRanking) ?? 0); //Corrigir addRaid 0
      if (names.length == damages.length && damages.length == participations.length) {
        for (int i = 0; i < names.length; i++) {
          widget.databaseManager.addMember(names[i], 'undefined');
          widget.databaseManager.addMemberInRaid(names[i], raidTitle, damages[i], participations[i].toString());
        }
      }
      _textEditingController.clear();
      // Atualiza a UI para refletir as mudanças
      setState(() {});
    }
  }
  void saveDataFromLens() async {
    String text = _textEditingController.text;
    List<String> lines = text.split('\n');

     if (lines.isNotEmpty) {
      // Expressão regular para encontrar o título da raid até o primeiro número
      RegExp regExp = RegExp(r'^(.*?)(?=\d)');
      // Encontra o título da raid usando a expressão regular
      String raidTitle = regExp.firstMatch(lines.first)?.group(0) ?? '';
      // Remove espaços extras do título
      raidTitle = raidTitle.trim();
      // Remove o título da linha para obter as informações restantes
      String remainingInfo = lines.first.replaceFirst(raidTitle, '');
      // Separa a data e o número usando espaços como delimitador
      List<String> dateAndNumber = remainingInfo.trim().split(RegExp(r'\s+'));
      String date = dateAndNumber.first;
      RegExp raidNumberRegExp = RegExp(r'S(\d+)');
      String number = raidNumberRegExp.firstMatch(lines.first)?.group(1) ?? '';
      RegExp raidRankingRegExp = RegExp(r'R(\d+)');
      String raidRanking = raidRankingRegExp.firstMatch(lines.first)?.group(1) ?? '';

      List<String> names = [];
      List<int> damages = [];
      List<String> participations = [];

    // Expressões regulares para capturar o nome, participação e dano
  // Expressões regulares para capturar o nome, participação e dano
  RegExp nameRegExp = RegExp(r'^(.*?)\s+Lv\.\d+$');
  RegExp participationRegExp = RegExp(r'(\d+)/(\d+)'); // Alterada para capturar o formato "21/21"
  RegExp damageRegExp = RegExp(r'(\d{1,3}(?:,\d{3})*,\d{1,3})');

  // Loop pelas linhas para extrair os dados
  for (int i = 1; i < lines.length; i++) {
    String line = lines[i].trim();

    // Tentar extrair o nome
    Match? nameMatch = nameRegExp.firstMatch(line);
    if (nameMatch != null) {
      String name = nameMatch.group(1)?.trim() ?? '';
      names.add(name);
      continue; // Passa para a próxima linha
    }

    // Tentar extrair a participação
    Match? participationMatch = participationRegExp.firstMatch(line);
    if (participationMatch != null) {
      String participation = participationMatch.group(1) ?? '';
      participation += participationMatch.group(2) ?? ''; // Concatena os dois números
      participations.add(participation);
      continue; // Passa para a próxima linha
    }

    // Tentar extrair o dano
    Match? damageMatch = damageRegExp.firstMatch(line);
    if (damageMatch != null) {
      String damageString = damageMatch.group(1) ?? '';
      int damage = int.tryParse(damageString.replaceAll(',', '')) ?? 0;
      damages.add(damage);
    }
  }
    // Exibir os dados extraídos
    debugPrint('Título da Raid: $raidTitle');
    debugPrint('Data: $date');
    debugPrint('Número: $number');
    debugPrint('Nomes: $names');
    debugPrint('Danos: $damages');
    debugPrint('Participações: $participations');

      widget.databaseManager.addRaid(raidTitle, date, int.tryParse(number) ?? -1, int.tryParse(raidRanking) ?? 0); //Corrigir addRaid 0
      if (names.length == damages.length && damages.length == participations.length) {
        for (int i = 0; i < names.length; i++) {
          widget.databaseManager.addMember(names[i], 'undefined');
          widget.databaseManager.addMemberInRaid(names[i], raidTitle, damages[i], participations[i].toString());
        }
      }
      _textEditingController.clear();  
    }
  }
}
