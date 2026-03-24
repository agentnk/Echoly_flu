import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/app_state.dart';
import '../widgets/teleprompter_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    
    // Theme colors
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedTextColor = isDark ? Colors.grey[400] : const Color(0xFF94A3B8);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final bgHeader = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      body: Column(
        children: [
          // Header / Custom Window Titlebar
          Container(
            height: 48,
            color: bgHeader,
            child: Row(
              children: [
                // Window controls area (macOS native buttons sit here when titleBarStyle is hidden)
                const SizedBox(width: 80), 
                
                // App Title
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 16),
                    Text(
                      'ECHOLY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // File Name
                Text(
                  state.currentFileName,
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontFamily: 'Courier', 
                  ),
                ),
                
                const Spacer(),
                
                // Theme Toggle
                IconButton(
                  icon: Icon(
                    isDark ? LucideIcons.sun : LucideIcons.moon,
                    size: 16,
                    color: textColor,
                  ),
                  onPressed: () => context.read<AppState>().toggleTheme(),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          
          // Toolbar
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: bgHeader,
              border: Border(
                top: BorderSide(color: borderColor),
                bottom: BorderSide(color: borderColor),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(LucideIcons.folder, color: textColor),
                  onPressed: () => context.read<AppState>().openFile(),
                ),
                
                VerticalDivider(color: borderColor, indent: 16, endIndent: 16),
                
                IconButton(
                  icon: Icon(state.isPlaying ? LucideIcons.pause : LucideIcons.play, color: textColor),
                  onPressed: () => context.read<AppState>().togglePlay(),
                ),
                
                VerticalDivider(color: borderColor, indent: 16, endIndent: 16),
                
                IconButton(
                  icon: Text('A-', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  onPressed: () => context.read<AppState>().decreaseFontSize(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.fontSize.toInt()}pt',
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: Text('A+', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  onPressed: () => context.read<AppState>().increaseFontSize(),
                ),
                
                VerticalDivider(color: borderColor, indent: 16, endIndent: 16),
                
                IconButton(
                  icon: Icon(LucideIcons.settings, color: textColor),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Main Teleprompter View
          const Expanded(
            child: TeleprompterView(),
          ),
          
          // Footer
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: bgHeader,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: state.isPlaying ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.isPlaying ? 'PLAYING' : 'PAUSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: mutedTextColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${state.currentLineIndex + 1} / ${state.scriptLines.isEmpty ? 1 : state.scriptLines.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedTextColor,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
