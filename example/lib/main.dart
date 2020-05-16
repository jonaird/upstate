import 'package:flutter/material.dart';
import 'custom_state_object_example.dart';
import 'package:upstate/upstate.dart';

void main() {
 runApp(StateWidget(
    state: StateObject({'counter': 0}), 
    child: MyApp()));
}