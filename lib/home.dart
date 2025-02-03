// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sudoku/game.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedDifficultyLevel;

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sudoku')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.text,
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escolha o nível de dificuldade:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  RadioListTile(
                    value: 1,
                    groupValue: selectedDifficultyLevel,
                    onChanged: (int? value) {
                      setState(() {
                        selectedDifficultyLevel = value;
                      });
                    },
                    activeColor: Colors.black,
                    title: Text('Fácil'),
                  ),
                  RadioListTile(
                    value: 2,
                    groupValue: selectedDifficultyLevel,
                    onChanged: (int? value) {
                      setState(() {
                        selectedDifficultyLevel = value;
                      });
                    },
                    activeColor: Colors.black,
                    title: Text('Médio'),
                  ),
                  RadioListTile(
                    value: 3,
                    groupValue: selectedDifficultyLevel,
                    onChanged: (int? value) {
                      setState(() {
                        selectedDifficultyLevel = value;
                      });
                    },
                    activeColor: Colors.black,
                    title: Text('Difícil'),
                  ),
                  RadioListTile(
                    value:  4,
                    groupValue: selectedDifficultyLevel,
                    onChanged: (int? value) {
                      setState(() {
                        selectedDifficultyLevel = value;
                      });
                    },
                    activeColor: Colors.black,
                    title: Text('Especialista'),
                  ),
                ],
              ),
              SizedBox(height: 80),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Game.routeName,
                    arguments: {
                      'level': selectedDifficultyLevel!,
                      'name': nameController.text,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text('JOGAR'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                Navigator.pushNamed(context, '/historico');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white),
                child: Text('VER HISTÓRICO'),),
            ],
          ),
        ),
      ),
    );
  }
}