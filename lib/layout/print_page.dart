import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gt_guild_records_v2/layout/home_page.dart';
import '../database/database.dart';


class PrintPage extends StatefulWidget {
  final DatabaseManager databaseManager;

  const PrintPage({super.key, required this.databaseManager});

  @override
  PrintPageState createState() => PrintPageState();
}

class PrintPageState extends State<PrintPage> {
  List<List<String>> _data = [];
  final TextEditingController _textFieldController = TextEditingController();
  bool showRaidInfoButton = false;
  bool showMemberInfoButtom = false;
  bool showBackToRaidsButton = false;
  bool showBackToMembersButton = false;
  double buttonHeight = 40;
  double buttonWidth = 180;
  bool _isSnackbarVisible = false;
  bool _filterActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
        _data = [['Select a option below...']];
        showRaidInfoButton = false;
        showMemberInfoButtom = false;
    });
  }
  void _updateMembersData() async {
    try {
      final newData = await widget.databaseManager.getMembersData();
      setState(() {
        _data = newData;
        showRaidInfoButton = false;
        showMemberInfoButtom = true;
        showBackToRaidsButton = false;
        showBackToMembersButton = false;
      });
    } catch (error) {
      debugPrint('Erro members: $error');
    }
  }
  void _updateRaidsData()async{
    try{
      final newData = await widget.databaseManager.getRaidsData();
      setState(() {
        _data = newData;
        showRaidInfoButton = true;
        showMemberInfoButtom = false;
        showBackToRaidsButton = false;
        showBackToMembersButton = false;
      });
    }catch(e){
      debugPrint("Erro raids: $e");
    }
  }
  void _updateMembersInRaidData()async{
    try{
      final newData = await widget.databaseManager.getMembersInRaidsData();
      setState(() {
        _data = newData;
        showRaidInfoButton = false;
        showMemberInfoButtom = false;
        showBackToRaidsButton = false;
        showBackToMembersButton = false;
      });
    }catch(e){
      debugPrint("Erro members in raids: $e");
    }
  }
  void _updateRaidStats(String title)async{
   try{
      final newData = await widget.databaseManager.getRaidStats(title);
      setState(() {
        _data = newData;
        showRaidInfoButton = false;
        showMemberInfoButtom = false;
        showBackToRaidsButton = true;
        showBackToMembersButton = false;
      });
    }catch(e){
      debugPrint("Erro members in raids: $e");
    }
  }
  void _updateTopDamageRanking(bool filterActive) async{
   try{
      final newData = await widget.databaseManager.getTopDamageRanking(filterActive: filterActive);
      setState(() {
        _data = newData;
        showRaidInfoButton = false;
        showMemberInfoButtom = false;
        showBackToRaidsButton = false;
        showBackToMembersButton = false;
      });
    }catch(e){
      debugPrint("Erro members in raids: $e");
    }
  }
  void _updateMemberStats(String gameName)async{
    try{
      final newData = await widget.databaseManager.getMembersStats(gameName, includeRaids: true);

      setState(() {
        _data = newData;
        showRaidInfoButton = false;
        showMemberInfoButtom = false;
        showBackToRaidsButton = false;
        showBackToMembersButton = true;

      });
    }catch(e){
      debugPrint("Erro members in raids: $e");
    }
  }
  void _updateActiveMembersStats()async{
    try{
      final newData = await widget.databaseManager.getParticipationRankings();

      setState(() {
        _data = newData;
        showRaidInfoButton = false;
        showMemberInfoButtom = false;
        showBackToRaidsButton = false;
        showBackToMembersButton = false;
      });
    }catch(e){
      debugPrint("Erro members in raids: $e");
    }
  }
  void _updateAcumulatedDamageRanking()async{
     try{
      final newData = await widget.databaseManager.getAccumulatedDamageRanking();

      setState(() {
        _data = newData;
        showRaidInfoButton = false;
        showMemberInfoButtom = false;
        showBackToRaidsButton = false;
        showBackToMembersButton = false;
      });
    }catch(e){
      debugPrint("Erro members in raids: $e");
    }
  }
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: _updateMembersData,
                    child: const Text('Members'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: _updateRaidsData,
                    child: const Text('Raids'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: _updateMembersInRaidData,
                    child: const Text('Members In Raids'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: const Text('Raid Stats'),
                    onPressed: () => _showRaidStatsDialog(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child:ElevatedButton.icon(
                    onPressed: () => _updateTopDamageRanking(_filterActive),
                    icon: PopupMenuButton<bool>(
                      icon: const Icon(Icons.settings),
                      onSelected: (bool result) {
                        setState(() {
                          _filterActive = result;
                        });
                      },
                      itemBuilder: (BuildContext context) => [
                        CheckedPopupMenuItem<bool>(
                          value: false,
                          checked: !_filterActive,
                          child: const Text('All Members'),
                        ),
                        CheckedPopupMenuItem<bool>(
                          value: true,
                          checked: _filterActive,
                          child: const Text('Active Members'),
                        ),
                      ],
                    ),
                    label: const Text('Best Damages'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: () => _showMemberStatsDialog(context),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Member Stats'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: _updateActiveMembersStats,
                    icon: const Icon(Icons.format_list_numbered),
                    label: const Text('Best Participations'),
                  ),
                ),
              ),
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: _updateAcumulatedDamageRanking,
                    icon: const Icon(Icons.format_list_numbered),
                    label: const Text('Acumulated damages'),
                  ),
                ),
              ),
              const Row(children: [SizedBox(height: 20)])
            ],
          ),
        );
      },
    );
  }

 @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  child: Stack(
                    children: [
                      ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          final rowData = _data[index];
                          String raidTitle = '';
                          String memberName = '';
                          if (showRaidInfoButton) {
                            raidTitle = rowData[1];
                          }
                          if (showMemberInfoButtom) {
                            memberName = rowData[1];
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    rowData.join('    '),
                                  ),
                                ),
                                if (showRaidInfoButton && index < _data.length - 1)
                                IconButton(
                                  icon: const Tooltip(
                                    message: 'More info', // Texto explicativo exibido ao segurar o ícone
                                    child: Icon(Icons.info),
                                  ),
                                  onPressed: () {
                                    _updateRaidStats(raidTitle);

                                  },
                                ),
                                if (showMemberInfoButtom && index < _data.length - 1)
                                IconButton(
                                  icon: const Tooltip(
                                    message: 'More info', // Texto explicativo exibido ao segurar o ícone
                                    child: Icon(Icons.info),
                                  ),
                                  onPressed: () {
                                    _updateMemberStats(memberName);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Tooltip(
                            message: 'Copy all',
                            child: Icon(Icons.copy),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _data.map((rowData) => rowData.join('    ')).join('\n')));
                            if(!_isSnackbarVisible){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                  behavior: SnackBarBehavior.floating,
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
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
             Center(
              child: Row(
                children: [
                  if(showBackToRaidsButton || showBackToMembersButton)
                  const SizedBox(width: 56),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onVerticalDragEnd: (details) {
                          if (details.primaryVelocity! < 0) {
                            _showBottomSheet(context); // Chama o método ao deslizar para cima
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Theme.of(context).colorScheme.primaryContainer,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),  
                          width: 180, // largura desejada do botão
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextButton(
                              onPressed: () {
                                _showBottomSheet(context);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.keyboard_double_arrow_up), // ícone do botão
                                  SizedBox(width: 8), // espaço entre o ícone e o texto (opcional)
                                  Text('Print options'), // texto do botão
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if(showBackToRaidsButton)
                  FloatingActionButton(
                    onPressed: () {
                      _updateRaidsData();
                    },
                    tooltip: 'Show Raids',
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                  if(showBackToMembersButton)
                  FloatingActionButton(
                    onPressed: () {
                      _updateMembersData();
                    },
                    tooltip: 'Show Members',
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                ],
              ),
             )
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 2, // Índice inicial selecionado
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
  Future<void> _showRaidStatsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Raid Title'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Raid Title"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateRaidStats(_textFieldController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }
   Future<void> _showMemberStatsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Member stats'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "game name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateMemberStats(_textFieldController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }
}