import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuoteDisplayScreen extends StatelessWidget {
  final String category;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  QuoteDisplayScreen({required this.category});

  void _markAsRead(String quoteId, BuildContext context) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('read_quotes')
          .doc(quoteId)
          .set({'read': true, 'timestamp': FieldValue.serverTimestamp()});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Quote marked as read')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking as read: ${e.toString()}')),
      );
    }
  }

  void _bookmark(String quoteId, BuildContext context) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('bookmarked_quotes')
          .doc(quoteId)
          .set({'bookmarked': true, 'timestamp': FieldValue.serverTimestamp()});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Quote bookmarked')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error bookmarking: ${e.toString()}')),
      );
    }
  }

  void _rate(String quoteId, int rating, BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ratingsRef = _firestore.collection('quotes').doc(quoteId).collection('ratings');
    final quoteRef = _firestore.collection('quotes').doc(quoteId);

    try {
      // Set user's rating
      await ratingsRef.doc(uid).set({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Fetch all ratings for this quote
      final allRatingsSnapshot = await ratingsRef.get();

      int total = 0;
      int count = allRatingsSnapshot.docs.length;

      for (var doc in allRatingsSnapshot.docs) {
        total += (doc['rating'] as int);
      }

      double averageRating = count > 0 ? total / count : 0;

      // Update quote document with the average rating
      await quoteRef.update({'rating': averageRating});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quote rated: $rating')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rating: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
                    .collection('quotes')
                    .where('category', isEqualTo: category)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final quotes = snapshot.data!.docs;
              if (quotes.isEmpty) {
                return Center(
                  child: Text('No quotes available for $category.'),
                );
              }
              final quote = quotes[0].data() as Map<String, dynamic>;
              final quoteId = quotes[0].id;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    quote['content'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '- ${quote['author'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed:
                            FirebaseAuth.instance.currentUser == null
                                ? null
                                : () => _markAsRead(quoteId, context),
                        child: Text('Mark as Read'),
                      ),
                      ElevatedButton(
                        onPressed:
                            FirebaseAuth.instance.currentUser == null
                                ? null
                                : () => _bookmark(quoteId, context),
                        child: Text('Bookmark'),
                      ),
                      ElevatedButton(
                        onPressed:
                            FirebaseAuth.instance.currentUser == null
                                ? null
                                : () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('Rate Quote'),
                                          content: Text(
                                            'Rate this quote (1-5):',
                                          ),
                                          actions: [
                                            for (int i = 1; i <= 5; i++)
                                              TextButton(
                                                onPressed: () {
                                                  _rate(quoteId, i, context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('$i'),
                                              ),
                                          ],
                                        ),
                                  );
                                },
                        child: Text('Rate'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
