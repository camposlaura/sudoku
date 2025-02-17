// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sudoku/history.dart';
import 'package:sudoku/game.dart';
import 'package:sudoku/home.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/home': (context) => HomePage(),
      '/historico': (context) => Historico(),
      Game.routeName: (context) => Game()
    },
    title: 'Sudoku',
    debugShowCheckedModeBanner: false,
    home: HomePage()
  ));
}