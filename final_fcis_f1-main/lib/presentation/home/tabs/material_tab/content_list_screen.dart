import 'package:FCIS_F1/core/utils/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for clipboard functionality

class ContentListPage extends StatelessWidget {
  final String title;
  final Map<String, String> content; // Now we pass a map (name → URL)

  ContentListPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        title,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      )),
      body: ListView.builder(
        itemCount: content.length,
        itemBuilder: (context, index) {
          String lectureName = content.keys.elementAt(index);
          String lectureUrl = content.values.elementAt(index);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    _showUrlDialog(context, lectureName, lectureUrl);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: ColorsManager.darkGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text(
                      lectureName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: ColorsManager.backGroundColor),
                    )),
                  ),
                ),
              ),
            ],
          );

          ListTile(
            title: Text(lectureName),
            onTap: () {
              _showUrlDialog(context, lectureName, lectureUrl);
            },
          );
        },
      ),
    );
  }

  void _showUrlDialog(BuildContext context, String name, String url) {
    showDialog(
      barrierColor: ColorsManager.darkGrey,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
              child: Text(
            name,
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(url,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey)), // Allow URL selection
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("URL copied to clipboard!")),
                  );
                },
                icon: Icon(
                  Icons.copy,
                  color: Colors.black,
                ),
                label: Text(
                  "Copy URL",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
