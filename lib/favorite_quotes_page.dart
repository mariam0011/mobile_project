import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteQuotesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Rated Quotes (4★ - 5★)'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('quotes')
            .where('rating', isGreaterThanOrEqualTo: 4)
            .where('rating', isLessThanOrEqualTo: 5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final quotes = snapshot.data!.docs;
          if (quotes.isEmpty) {
            return Center(child: Text('No high-rated quotes found.'));
          }

          return ListView.builder(
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index].data() as Map<String, dynamic>;
              final text = quote['content'] ?? 'No text';
              final author = quote['author'] ?? 'Unknown';
              final rating = quote['rating'] ?? 0;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('"$text"', style: TextStyle(fontSize: 16)),
                  subtitle: Text('- $author'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(rating.toString()),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
