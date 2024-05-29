import 'package:flutter/material.dart';
import 'package:gt_guild_records_v2/layout/home_page.dart';
import '../database/database.dart';

class DatabasePage extends StatelessWidget {
  final DatabaseManager databaseManager;

  const DatabasePage({super.key, required this.databaseManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database'),
        centerTitle: true,
      ),
      body:Center(
        child:  LayoutBuilder(
          builder: (context, constraints) {
          // Define o tamanho fixo do Container como uma fração da largura disponível
          double containerWidth = 380; // 100% da largura disponível
          double containerHeight = 250; // Altura fixa
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: containerWidth,
                  height: containerHeight,
                  child: Container(
                    padding: const EdgeInsets.all(4.0), // Padding interno do container
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer, // Cor de fundo
                      borderRadius: BorderRadius.circular(24.0), // Bordas levemente arredondadas
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Layout para MEMBER
                        const Text(
                          'MEMBER',
                          style: TextStyle(fontSize: 16),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showAddMemberDialog(context);
                                },
                                icon: const Icon(Icons.add), // Ícone de adição
                                label: const Text('ADD'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showRemoveMemberDialog(context);
                                },
                                icon: const Icon(Icons.delete_forever), // Ícone de remoção
                                label: const Text('REMOVE'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showEditMemberDialog(context);
                                },
                                icon: const Icon(Icons.edit), // Ícone de edição
                                label: const Text('EDIT'),
                              ),
                            ),
                          ],
                        ),
                        // Layout para RAID
                        const Text(
                          'RAID',
                          style: TextStyle(fontSize: 16),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showAddRaidDialog(context);
                                },
                                icon: const Icon(Icons.add), // Ícone de adição
                                label: const Text('ADD'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showRemoveRaidDialog(context);
                                },
                                icon: const Icon(Icons.delete_forever), // Ícone de remoção
                                label: const Text('REMOVE'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showEditRaidDialog(context);
                                },
                                icon: const Icon(Icons.edit), // Ícone de edição
                                label: const Text('EDIT'),
                              ),
                            ),
                          ],
                        ),
                        // Layout para MEMBER IN RAID
                        const Text(
                          'MEMBER IN RAID',
                          style: TextStyle(fontSize: 16),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showAddMemberInRaidDialog(context);
                                },
                                icon: const Icon(Icons.add), // Ícone de adição
                                label: const Text('ADD'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showRemoveMemberInRaidDialog(context);
                                },
                                icon: const Icon(Icons.delete_forever), // Ícone de remoção
                                label: const Text('REMOVE'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showEditMemberInRaidDialog(context);
                                },
                                icon: const Icon(Icons.edit), // Ícone de edição
                                label: const Text('EDIT'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 1,
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

  void _showAddMemberDialog(BuildContext context){
    var gameName = 'undefined', discordName = 'undefined'; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter game name'),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                gameName = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter discord name'),
              onChanged: (value) {
                discordName = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: ()async{
              int result = 0;
              try{
                await databaseManager.addMember(gameName, discordName);
              }catch(e){
                result = -1;
              }
              if (context.mounted) Navigator.of(context).pop();
              if (context.mounted) _showSnackBar(context, result, 'Add Member');
            },
            child: const Text('Save'))
        ],
        );
      }
    );
  }

  void _showSnackBar(BuildContext context, int result, String msg){
    if (result == 0) {
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green, // Cor de fundo da barra verde
            content: Text('Success: $msg'), // Mensagem de sucesso
          ),
        );
      }
    } else {
      if(context.mounted){
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red, // Cor de fundo da barra vermelha
              content: Text('Error: $msg'), // Mensagem de erro
            ),
          );
      }
    }
  }

  void _showAddRaidDialog(BuildContext context){
    String title = 'undefined';
    String date = 'undefined';
    int season = -1;
    int ranking = 0;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return AlertDialog(
          title: const Text('Add Raid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter title'),
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  title = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter date'),
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  date = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter season'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  season = int.tryParse(value) ?? -1;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter ranking'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  ranking = int.tryParse(value) ?? -1;
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
                  await databaseManager.addRaid(title, date, season, ranking);  
                }catch(e){
                  result = -1;
                }
                if (context.mounted) Navigator.of(context).pop();
                if (context.mounted) _showSnackBar(context, result, 'Add Raid');
              },
              child: const Text('Save')),
          ],
        );
      },
    );
  }

  void _showAddMemberInRaidDialog(BuildContext context){
    String gameName = 'undefined', title = 'undefined', participation = 'undefined'; 
    int damage = -1;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return AlertDialog(
          title: const Text('Add Member in Raid'),
          content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter game name'),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                gameName = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter title'),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                title = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter damage'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                damage = int.tryParse(value) ?? -1;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter participation'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                participation = value;
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
                await databaseManager.addMemberInRaid(gameName, title, damage, participation);
              }catch(e){
                result = -1;
              }
              if (context.mounted) Navigator.of(context).pop();
              if (context.mounted) _showSnackBar(context, result, 'Add Member in Raid');
            },
            child: const Text('Save')
          ),
        ],
        );
      }
    );
  }

  void _showRemoveMemberDialog(BuildContext context) {
    var gameName = TextEditingController();
    var key = TextEditingController();
    int id = -1;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Remove Member'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: gameName,
                          decoration: const InputDecoration(hintText: 'Enter game name'),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          id = await databaseManager.getMemberID(gameName.text.trim());
                          setState(() {
                            key.text = id.toString();
                          });
                        },
                        icon: const Tooltip(
                          message: 'Search id',
                          child: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter id'),
                    keyboardType: TextInputType.number,
                    controller: key,
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
                      await databaseManager.removeMember(int.tryParse(key.text) ?? -1);
                    }catch(e){
                      result = -1;
                    }
                    if (context.mounted) Navigator.of(context).pop();
                    if (context.mounted) _showSnackBar(context, result, 'Remove Member');
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showRemoveRaidDialog(BuildContext context) {
    var title = TextEditingController();
    var key = TextEditingController();
    int id = -1;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Remove Raid'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: title,
                          decoration: const InputDecoration(hintText: 'Enter title'),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          id = await databaseManager.getRaidID(title.text.trim());
                          setState(() {
                            key.text = id.toString();
                          });
                        },
                        icon: const Tooltip(
                          message: 'Search id',
                          child: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter id'),
                    keyboardType: TextInputType.number,
                    controller: key,
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
                  onPressed: () async{
                    int result = 0;
                    try{
                      await databaseManager.removeRaid(int.tryParse(key.text) ?? -1);
                    }catch(e){
                      result = -1;
                    }
                    if (context.mounted) Navigator.of(context).pop();
                    if (context.mounted) _showSnackBar(context, result, 'Remove Raid');
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showRemoveMemberInRaidDialog(BuildContext context) {
    var gameName = TextEditingController();
    var title = TextEditingController();
    var keyN = TextEditingController();
    var keyT = TextEditingController();
    int idN = -1, idT = -1;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Remove Member in Raid'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: gameName,
                          decoration: const InputDecoration(hintText: 'Enter game name'),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          idN = await databaseManager.getMemberID(gameName.text.trim());
                          setState(() {
                            keyN.text = idN.toString();
                          });
                        },
                        icon: const Tooltip(
                          message: 'Search id',
                          child: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: title,
                          decoration: const InputDecoration(hintText: 'Enter title'),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          idT = await databaseManager.getRaidID(title.text.trim());
                          setState(() {
                            keyT.text = idT.toString();
                          });
                        },
                        icon: const Tooltip(
                          message: 'Search id',
                          child: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter member id'),
                    keyboardType: TextInputType.number,
                    controller: keyN,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter raid id'),
                    keyboardType: TextInputType.number,
                    controller: keyT,
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
                  onPressed: () async{
                    int result = 0;
                    try{
                      await databaseManager.removeMemberInRaid(int.tryParse(keyN.text) ?? -1, int.tryParse(keyT.text) ?? -1);
                    }catch(e){
                      result = -1;
                    }
                    if (context.mounted) Navigator.of(context).pop();
                    if (context.mounted) _showSnackBar(context, result, 'Remove Member In Raid');
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showEditMemberDialog(BuildContext context) {
    var gameName = TextEditingController();
    var key = TextEditingController();
    var newGameName = TextEditingController();
    var newDiscordName = TextEditingController();
    int id = -1;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Member'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: gameName,
                          decoration: const InputDecoration(hintText: 'Enter game name'),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          id = await databaseManager.getMemberID(gameName.text.trim());
                          setState(() {
                            key.text = id.toString();
                          });
                        },
                        icon: const Tooltip(
                          message: 'Search id',
                          child: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter id'),
                    keyboardType: TextInputType.number,
                    controller: key,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter new game name'),
                    controller: newGameName,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter new discord name'),
                    controller: newDiscordName,
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
                      await databaseManager.updateMember(int.tryParse(key.text) ?? -1,
                       newGameName: newGameName.text.trim(), newDiscordName: newDiscordName.text.trim());
                    }catch(e){
                      result = -1;
                    }
                    if (context.mounted) Navigator.of(context).pop();
                    if (context.mounted) _showSnackBar(context, result, 'Edit Member');
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showEditRaidDialog(BuildContext context) {
    var title = TextEditingController();
    var key = TextEditingController();
    var newTitle = TextEditingController();
    var newDate = TextEditingController();
    var newSeason = TextEditingController();
    var newRanking = TextEditingController();
    int id = -1;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Raid'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: title,
                          decoration: const InputDecoration(hintText: 'Enter title'),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          id = await databaseManager.getRaidID(title.text.trim());
                          setState(() {
                            key.text = id.toString();
                          });
                        },
                        icon: const Tooltip(
                          message: 'Search id',
                          child: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter id'),
                    keyboardType: TextInputType.number,
                    controller: key,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter new title'),
                    controller: newTitle,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter new date'),
                    keyboardType: TextInputType.datetime,
                    controller: newDate,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter new season'),
                    keyboardType: TextInputType.number,
                    controller: newSeason,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter new ranking'),
                    keyboardType: TextInputType.number,
                    controller: newRanking,
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
                  onPressed: () async{
                    int result = 0;
                    try{
                      await databaseManager.updateRaid(int.tryParse(key.text) ?? -1,
                       newTitle: newTitle.text.trim(), newDate: newDate.text.trim(), newSeason: int.tryParse(newSeason.text), newRanking: int.tryParse(newRanking.text));
                    }catch(e){
                      result = -1;
                    }
                    if (context.mounted) Navigator.of(context).pop();
                    if (context.mounted) _showSnackBar(context, result, 'Edit Raid');
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showEditMemberInRaidDialog(BuildContext context) {
    var gameName = TextEditingController();
    var title = TextEditingController();
    var keyN = TextEditingController();
    var keyT = TextEditingController();
    var newDamage = TextEditingController();
    var newParticipation = TextEditingController();
    int idN = -1, idT = -1;

    showDialog(
      context: context,
      builder: (BuildContext content) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Member in Raid'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: gameName,
                          decoration: const InputDecoration(hintText: 'Enter game name'),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          idN = await databaseManager.getMemberID(gameName.text.trim());
                          setState(() {
                            keyN.text = idN.toString();
                          });
                        },
                        icon: const Tooltip(
                          message: 'Search id',
                          child: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: title,
                          decoration: const InputDecoration(hintText: 'Enter title'),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          idT = await databaseManager.getRaidID(title.text.trim());
                          setState(() {
                            keyT.text = idT.toString();
                          });
                        },
                        icon: const Tooltip(
                          message: 'Search id',
                          child: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter member id'),
                    keyboardType: TextInputType.number,
                    controller: keyN,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter raid id'),
                    keyboardType: TextInputType.number,
                    controller: keyT,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter new damage'),
                    keyboardType: TextInputType.number,
                    controller: newDamage,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter new participation'),
                    keyboardType: TextInputType.number,
                    controller: newParticipation,
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
                  onPressed: () async{
                    int result = 0;
                    try{
                      await databaseManager.updateMemberInRaid(int.tryParse(keyN.text) ?? -1, int.tryParse(keyT.text) ?? -1,
                       newDamage: int.tryParse(newDamage.text), newParticipation: int.tryParse(newParticipation.text));
                    }catch(e){
                      result = -1;
                    }
                    if (context.mounted) Navigator.of(context).pop();
                    if (context.mounted) _showSnackBar(context, result, 'Edit Member In Raid');
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}