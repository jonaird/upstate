import 'package:flutter/material.dart';
import 'builder_example.dart';
import 'package:upstate/upstate.dart';

void main() {
 runApp(StateWidget(
    state: StateObject({'counter': 0}), 
    child: MyApp()));
}