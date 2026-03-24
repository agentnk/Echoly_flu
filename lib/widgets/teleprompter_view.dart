import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class TeleprompterView extends StatefulWidget {
  const TeleprompterView({super.key});

  @override
  State<TeleprompterView> createState() => _TeleprompterViewState();
}

class _TeleprompterViewState extends State<TeleprompterView> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to add listener after initial build
    Future.microtask(() {
      final appState = context.read<AppState>();
      appState.addListener(_onAppStateChanged);
    });
  }
  
  void _onAppStateChanged() {
    // Check if widget is still mounted
    if (!mounted) return;
    
    final appState = context.read<AppState>();
    if (appState.isPlaying && _scrollTimer == null) {
      _startScrolling();
    } else if (!appState.isPlaying && _scrollTimer != null) {
      _stopScrolling();
    }
  }

  void _startScrolling() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        
        if (currentScroll < maxScroll) {
          _scrollController.jumpTo(currentScroll + 1.0); // Adjust speed scalar here
          _updateActiveLine();
        } else {
          context.read<AppState>().togglePlay();
        }
      }
    });
  }
  
  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }
  
  void _updateActiveLine() {
    if (_scrollController.hasClients) {
      final appState = context.read<AppState>();
      // Heuristic height estimation based on font size + padding
      final itemHeight = appState.fontSize * 1.5 + 16.0; 
      
      // Calculate which text index is currently near the center of the viewport
      final viewCenter = _scrollController.offset + (_scrollController.position.viewportDimension / 2.5);
      
      int activeIndex = (viewCenter / itemHeight).floor();
      if (activeIndex < 0) activeIndex = 0;
      if (activeIndex >= appState.scriptLines.length) activeIndex = appState.scriptLines.length - 1;
      
      if (activeIndex != appState.currentLineIndex) {
        // Queue the state update to avoid 'setState during build' errors
        Future.microtask(() => appState.setCurrentLine(activeIndex));
      }
    }
  }

  @override
  void dispose() {
    _stopScrolling();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    
    final activeTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final inactiveTextColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 3, // Starting empty space
              bottom: MediaQuery.of(context).size.height / 2, // Ending empty space
            ),
            itemCount: state.scriptLines.length,
            itemBuilder: (context, index) {
              final line = state.scriptLines[index];
              final isActive = index == state.currentLineIndex;
              
              // Handle main bold title styling based on UI screenshot
              final isTitle = index <= 1;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: isTitle ? state.fontSize * 1.5 : state.fontSize,
                    fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
                    fontFamily: 'Courier', 
                    color: isActive ? activeTextColor : inactiveTextColor,
                    height: 1.4,
                  ),
                ),
              );
            },
          ),
          
          // Side indicator dots
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
