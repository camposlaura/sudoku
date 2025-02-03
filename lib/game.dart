// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, avoid_print, unnecessary_null_comparison

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:sudoku_dart/sudoku_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

String createTableRodadas = '''
CREATE TABLE IF NOT EXISTS rodadas(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR NOT NULL,
  result INTEGER,
  level INTEGER,
  date TEXT
);
''';

class Game extends StatefulWidget {
  const Game({super.key});
  static String routeName = '/game';

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late Sudoku sudoku;
  List<int> playerInputs = List.filled(81, -1);
  List<TextEditingController> cellControllers = List.generate(81, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final selectedDifficultyLevel = arguments['level'] as int;

      switch (selectedDifficultyLevel) {
        case 1:
          sudoku = Sudoku.generate(Level.easy);
          break;
        case 2:
          sudoku = Sudoku.generate(Level.medium);
          break;
        case 3:
          sudoku = Sudoku.generate(Level.hard);
          break;
        case 4:
          sudoku = Sudoku.generate(Level.expert);
          break;
        default:
          sudoku = Sudoku.generate(Level.easy);
      }

      for (int i = 0; i < 81; i++) {
        playerInputs[i] = sudoku.puzzle[i];
        if (sudoku.puzzle[i] != -1) {
          cellControllers[i].text = sudoku.puzzle[i].toString();
        }
      }

      setState(() {});
    });
  }

  Future<void> _saveRodada(String name, int result, int level) async {
    try {
      sqfliteFfiInit();
      var dbFactory = databaseFactoryFfi;
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, 'sudoku.db');
      final database = await dbFactory.openDatabase(path);

      String currentDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      await database.insert(
        'rodadas',
        {
          'name': name,
          'result': result,
          'level': level,
          'date': currentDate,
        },
      );
      print('Rodada salva: Jogador=$name, Resultado=$result, Nível=$level, Data=$currentDate');
    } catch (e) {
      print('Erro ao salvar rodada: $e');
    }
  }

  void _validatePlayerSolution() {
    bool isComplete = true;

    for (int i = 0; i < 81; i++) {
      if (playerInputs[i] == -1) return;
    }

    for (int i = 0; i < 81; i++) {
      if (playerInputs[i] != sudoku.solution[i]) {
        isComplete = false;
        break;
      }
    }

    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final playerName = arguments['name'] as String;
    final gameLevel = arguments['level'] as int;

    _saveRodada(playerName, isComplete ? 1 : 0, gameLevel);

    if (isComplete) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Parabéns!'),
          content: Text('Você completou o tabuleiro!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ops!'),
          content: Text('O tabuleiro tem algum valor errado. Tente novamente!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sudoku')),
      body: sudoku == null
        ? Center(child: CircularProgressIndicator())
        : Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      int row = index ~/ 9;
                      int col = index % 9;
                      int cellValue = sudoku.puzzle[row * 9 + col];

                      Color cellColor;
                      if (playerInputs[index] != -1 && playerInputs[index] != sudoku.solution[row * 9 + col]) {
                        cellColor = Colors.red[200]!;
                      } else {
                        cellColor = Colors.white;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: cellColor,
                          border: Border(
                            top: BorderSide(
                              color: row % 3 == 0 ? Colors.black : Colors.grey,
                              width: 0.5,
                            ),
                            left: BorderSide(
                              color: col % 3 == 0 ? Colors.black : Colors.grey,
                              width: 0.5,
                            ),
                            right: BorderSide(
                              color: (col + 1) % 3 == 0 ? Colors.black : Colors.grey,
                              width: 0.5,
                            ),
                            bottom: BorderSide(
                              color: (row + 1) % 3 == 0 ? Colors.black : Colors.grey,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Center(
                          child: cellValue == -1
                            ? TextField(
                              controller: cellControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              onChanged: (input) {
                                int? newValue = int.tryParse(input);
                                if (newValue != null && newValue >= 1 && newValue <= 9) {
                                  setState(() {
                                    playerInputs[index] = newValue;
                                  });
                                  _validatePlayerSolution();
                                } else {
                                  setState(() {
                                    playerInputs[index] = -1;
                                    cellControllers[index].clear();
                                  });
                                }
                              },
                            )
                            : Text(
                              cellValue.toString(),
                              style: TextStyle(fontSize: 20),
                            ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}