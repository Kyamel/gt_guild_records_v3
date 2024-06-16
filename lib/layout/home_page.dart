import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gt_guild_records_v2/database/database.dart';

class HomePage extends StatefulWidget {
  final DatabaseManager databaseManager;

  const HomePage({required this.databaseManager, super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isScrollingDown = false;
  bool _isFabVisible = true;
  final String imageFile = "assets/images/exemple_in_game_log.jpg";

  @override
  void initState() {
    super.initState();
    _openDatabaseIfNecessary(widget.databaseManager.getPath());
  }

  void _openDatabaseIfNecessary(String path) async {
    if (path != 'undefined' && !widget.databaseManager.isOpen) {
      await widget.databaseManager.openDatabase();
      widget.databaseManager.initTables();
      widget.databaseManager.createTables();
    }
  }

  void _onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse && !_isScrollingDown) {
        setState(() {
          _isScrollingDown = true;
          _isFabVisible = false;
        });
      } else if (notification.direction == ScrollDirection.forward && _isScrollingDown) {
        setState(() {
          _isScrollingDown = false;
          _isFabVisible = true;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          _onScrollNotification(scrollNotification);
          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GTGuildRecords',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 100),
                      Text(
                        'Instructions:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 10),
                                  Flexible( // Envolva o texto com Flexible
                                    child: Text(
                                      'Use the Open button to select or create a database file.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.stacked_bar_chart),
                                  SizedBox(width: 10),
                                  Flexible( // Envolva o texto com Flexible
                                    child: Text(
                                      'Use the Database menu for advanced database operations.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.print),
                                  SizedBox(width: 10),
                                  Flexible( // Envolva o texto com Flexible
                                    child: Text(
                                      'Use the Print menu to choose a way to print the database data.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.copy_all),
                                  SizedBox(width: 10),
                                  Flexible( // Envolva o texto com Flexible
                                    child: Text(
                                      'Use the Extract menu to copy paste a text block to be extracted into the database.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 10),
                                  Flexible( // Envolva o texto com Flexible
                                    child: Text(
                                      'Use the OCR menu to extract data from photos.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'How to use the Extract feature:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'You can choose between 3 options: Discord, Google Lens, and CopyFish.',
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Discord - follow the template:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Great Forest of Connectivity    04/04/2024    S77    R33\n\n'
                              '1. Noir    1,534,752,243    21/21\n'
                              '2. EndSeraph    1,151,220,175    21/21\n'
                              '...\n'
                              '30. Derp19    182,722,061    6/21',
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Google Lens - copy text from Google Lens and paste, the first line must specify the raid title:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Great Forest of Connectivity    04/04/2024    S77    R33\n'
                              'Noir Lv.300\n'
                              'Deve Lv.300\n'
                              '21/21\n'
                              '1,495,188,503\n'
                              '21/21\n'
                              '1,163,997,683\n'
                              '1,043,540,454\n'
                              'LisaLisa Lv.300\n'
                              'Hayai Lv.300\n'
                              '19/21\n'
                              '947,151,068\n'
                              '18/21',
                            ),
                            const SizedBox(height: 10),
                            const Text('As long as the data is in correct order, it does not matter if 2 or 3 names apears '
                            'in sequence and they damages apepears apread all over the place, what counts is: the fisrt damage to appear ' 
                            'will be related to the fisrt name to appear and first participation to appear, the second name will be related to the second '
                            'damage and second participation and so on.'),
                            const SizedBox(height: 10),
                            const Text(
                              'CopyFish - copy text from CopyFish browser extension and paste, the first line must specify the raid title:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Great Forest of Connectivity    04/04/2024    S77    R33\n'
                              'Noir\n'
                              'Lv.300\n'
                              'Deve\n'
                              'Lv.300\n'
                              'LisaLisa\n'
                              'Lv.300\n'
                              'Hayai\n'
                              'Lv.300\n'
                              '21/21\n'
                              '21/21\n'
                              '19/21\n'
                              '18/21\n'
                              '1,495,188,503\n'
                              '1,163,997,683\n'
                              '1,056,802,361\n'
                              '947,151,068',
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'To use Google Lens or CopyFish or the OCR feature, take a picture of the in game raid log and crop it like this: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Image.asset(
                              imageFile,
                              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                debugPrint('Error loading image: $error');
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 400,
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: 
             
              
          
             FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  tooltip: 'Settings',
                  child: const Icon(Icons.settings),
                ),
              
          
        
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 0,
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
}
class InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const InstructionItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.stacked_bar_chart),
          label: 'Database',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.print),
          label: 'Print',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.copy_all),
          label: 'Extract',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'OCR',
        ),
      ],
      showUnselectedLabels: true,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
