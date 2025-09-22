import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/custom_header.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? _selectedLang;

  final List<Map<String, String>> _indianLanguages = [
    {"code": "hi", "name": "Hindi"},
    {"code": "bn", "name": "Bengali"},
    {"code": "te", "name": "Telugu"},
    {"code": "ta", "name": "Tamil"},
    {"code": "mr", "name": "Marathi"},
    {"code": "gu", "name": "Gujarati"},
    {"code": "kn", "name": "Kannada"},
    {"code": "ml", "name": "Malayalam"},
    {"code": "pa", "name": "Punjabi"},
    {"code": "or", "name": "Odia"},
    {"code": "as", "name": "Assamese"},
    {"code": "ur", "name": "Urdu"},
    {"code": "ks", "name": "Kashmiri"},
    {"code": "sd", "name": "Sindhi"},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('selected_language');
    });
  }

  Future<void> _saveLanguage(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', code);
    setState(() {
      _selectedLang = code;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Language set to: $code")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(isHome: false),
      body: ListView.builder(
        itemCount: _indianLanguages.length,
        itemBuilder: (context, index) {
          final lang = _indianLanguages[index];
          return ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: Text(lang["name"]!),
            subtitle: Text(lang["code"]!),
            trailing: (_selectedLang == lang["code"])
                ? const Icon(Icons.check, color: Colors.teal)
                : null,
            onTap: () => _saveLanguage(lang["code"]!),
          );
        },
      ),
    );
  }
}
