import 'package:flutter/material.dart';
import 'package:gt_guild_records_v2/layout/home_page.dart';
import '../database/database.dart';

class RebuildPage extends StatelessWidget{
  final DatabaseManager databaseManager;
  final double buttonHeight = 40.0;
  final double buttonWidth = 180.0;

  const RebuildPage({super.key, required this.databaseManager});

  void _addColumnToRaids(String newColumn, defaultValue){
    //databaseManager.addColumnIntoRaids(newColumn, defaultValue);
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rebuild'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Warning: these operations may corrupt your database file, make a backup before proceding.'),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(16.0), // Padding interno do container
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer, // Cor de fundo
                  borderRadius: BorderRadius.circular(16.0), // Bordas levemente arredondadas
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Raids'),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                            //_addColumnToRaids('Ranking INTEGER NOT NULL CHECK (Ranking >= 0)', 0);
                        },
                        icon: const Icon(Icons.add), // Ícone de edição
                        label: const Text('Add column'),
                      ),
                    ),
                  ],
                ),
              ),  
            ],
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