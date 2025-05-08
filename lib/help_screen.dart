import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildHelpItem(
                'Search for quotes',
                Icons.search,
                'Enter keywords in the search bar to find quotes.',
              ),
              _buildHelpItem(
                'Bookmark a quote',
                Icons.bookmark,
                'Click "Bookmark" to save a quote for later.',
              ),
              _buildHelpItem(
                'Mark as Read',
                Icons.check,
                'Click "Mark as Read" to track quotes you’ve viewed.',
              ),
              _buildHelpItem(
                'Rate a quote',
                Icons.star,
                'Click "Rate" and select 1-5 to rate a quote.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(String text, IconData icon, String description) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      subtitle: Text(description),
    );
  }
}
