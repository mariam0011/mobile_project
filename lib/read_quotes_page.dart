import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReadQuotesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReadQuotesPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchReadQuotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final readQuotesSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('read_quotes')
        .orderBy('timestamp', descending: true)
        .get();

    List<String> quoteIds =
    readQuotesSnapshot.docs.map((doc) => doc.id).toList();

    if (quoteIds.isEmpty) return [];

    // Fetch corresponding quote data from 'quotes' collection
    List<Map<String, dynamic>> quotes = [];
    for (String quoteId in quoteIds) {
      final quoteDoc =
      await _firestore.collection('quotes').doc(quoteId).get();
      if (quoteDoc.exists) {
        quotes.add({'id': quoteId, ...quoteDoc.data()!});
      }
    }

    return quotes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Read Quotes')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReadQuotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No read quotes found.'));
          }

          final quotes = snapshot.data!;

          return ListView.builder(
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    quote['content'] ?? '',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  subtitle: Text('- ${quote['author'] ?? 'Unknown'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
