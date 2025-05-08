import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkedQuotesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Bookmarks')),
        body: Center(child: Text('Please log in to view bookmarks.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarked Quotes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('bookmarked_quotes')
            .snapshots(),
        builder: (context, bookmarkSnapshot) {
          if (bookmarkSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (bookmarkSnapshot.hasError) {
            return Center(child: Text('Error: ${bookmarkSnapshot.error}'));
          }

          final bookmarkDocs = bookmarkSnapshot.data!.docs;
          if (bookmarkDocs.isEmpty) {
            return Center(child: Text('No bookmarked quotes found.'));
          }

          final quoteIds = bookmarkDocs.map((doc) => doc.id).toList();

          return FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('quotes')
                .where(FieldPath.documentId, whereIn: quoteIds)
                .get(),
            builder: (context, quotesSnapshot) {
              if (quotesSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (quotesSnapshot.hasError) {
                return Center(child: Text('Error: ${quotesSnapshot.error}'));
              }

              final quotes = quotesSnapshot.data!.docs;

              return ListView.builder(
                itemCount: quotes.length,
                itemBuilder: (context, index) {
                  final quote = quotes[index].data() as Map<String, dynamic>;
                  final content = quote['content'] ?? 'No text';
                  final author = quote['author'] ?? 'Unknown';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text('"$content"', style: TextStyle(fontSize: 16)),
                      subtitle: Text('- $author'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
