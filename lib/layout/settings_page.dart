import 'package:flutter/material.dart';
import 'package:gt_guild_records_v2/layout/home_page.dart';
import '../database/database.dart';

class SettingsPage extends StatelessWidget{
  final DatabaseManager databaseManager;
  final double buttonHeight = 40.0;
  final double buttonWidth = 200.0;

  const SettingsPage({super.key, required this.databaseManager});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0), // Padding interno do container
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer, // Cor de fundo
                  borderRadius: BorderRadius.circular(16.0), // Bordas levemente arredondadas
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        height: buttonHeight,
                        width: buttonWidth,
                        child: ElevatedButton.icon(
                          onPressed: () {
                              Navigator.pushNamed(context, '/rebuild');
                          },
                          icon: const Icon(Icons.build), // Ícone de edição
                          label: const Text('Rebuild database'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        height: buttonHeight,
                        width: buttonWidth,
                        child: ElevatedButton.icon(
                          onPressed: () {
                              Navigator.pushNamed(context, '/theme');
                          },
                          icon: const Icon(Icons.refresh), // Ícone de edição
                          label: const Text('Change theme'),
                        ),
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