import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AppState extends ChangeNotifier {
  bool isDarkMode = false;
  bool isPlaying = false;
  double fontSize = 26.0;
  
  String currentFileName = 'demo-speech.txt';
  List<String> scriptLines = [
    "Welcome to Echoly -",
    "Web Teleprompter",
    "",
    "This is a sample speech to demonstrate the app.",
    "",
    "Press the Play button to begin.",
    "",
    "Then press Return or Enter to advance through your script.",
    "",
    "You can adjust the font size using the A- and A+ buttons.",
  ];
  
  int currentLineIndex = 0;
  
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
  
  void togglePlay() {
    isPlaying = !isPlaying;
    notifyListeners();
  }
  
  void increaseFontSize() {
    if (fontSize < 100) {
      fontSize += 2;
      notifyListeners();
    }
  }
  
  void decreaseFontSize() {
    if (fontSize > 12) {
      fontSize -= 2;
      notifyListeners();
    }
  }

  void setCurrentLine(int index) {
    if (index != currentLineIndex && index >= 0 && index < scriptLines.length) {
      currentLineIndex = index;
      notifyListeners();
    }
  }

  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String contents = await file.readAsString();
      
      scriptLines = contents.split('\n');
      currentFileName = result.files.single.name;
      currentLineIndex = 0;
      isPlaying = false;
      notifyListeners();
    }
  }
}
