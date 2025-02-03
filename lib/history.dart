// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, depend_on_referenced_packages, avoid_print, unnecessary_import, unused_element, unused_import, prefer_const_literals_to_create_immutables

import 'dart:io' as io;
import 'package:intl/intl.dart';
import 'package:sudoku/game.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Historico extends StatefulWidget {
  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  late Database database;
  List<Map<String, dynamic>> rounds = [];
  int? selectedDifficultyLevel;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      sqfliteFfiInit();
      var dbFactory = databaseFactoryFfi;
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, 'sudoku.db');
      database = await dbFactory.openDatabase(path);

      await database.execute('''
      CREATE TABLE IF NOT EXISTS rodadas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL,
        result INTEGER,
        level INTEGER,
        date TEXT NOT NULL
      );
      ''');
      await _fetchRounds();
    } catch (e) {
      print('Erro ao inicializar o banco de dados: $e');
    }
  }

  Future<void> _fetchRounds({int? level}) async {
    try {
      final data = level != null
        ? await database.query('rodadas', where: 'level = ?', whereArgs: [level])
        : await database.query('rodadas');
      setState(() {
        rounds = data;
      });
    } catch (e) {
      print('Erro ao buscar histórico de partidas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de partidas'),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                value: selectedDifficultyLevel,
                hint: Text('Filtrar por nível'),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Todos os níveis'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Fácil'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Médio'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Difícil'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Especialista'),
                    ),
                  ),
                ],
                onChanged: (int? value) {
                  setState(() {
                    selectedDifficultyLevel = value;
                  });
                  _fetchRounds(level: value);
                },
                underline: Container(),
                icon: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                dropdownColor: Colors.white,
                focusColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
      body: rounds.isEmpty
        ? Center(
          child: Text('Nenhuma partida encontrada.'),
        )
        : Padding(
          padding: EdgeInsets.all(20),
          child: Table(
            border: TableBorder.all(color: Colors.grey),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[400]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Jogador', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Nível', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Resultado', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              for (final round in rounds.reversed)
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(DateTime.parse(round['date'])),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(round['name'] != '' ? round['name'] : 'Desconhecido'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        round['level'] == 1 ? 'Fácil' :
                        round['level'] == 2 ? 'Médio' :
                        round['level'] == 3 ? 'Difícil' :
                        'Especialista',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(round['result'] == 1 ? 'Vitória' : 'Derrota'),
                    ),
                  ],
                ),
            ],
          ),
        ),
    );
  }
}