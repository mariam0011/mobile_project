import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quote_display_screen.dart';
import 'help_screen.dart';
import 'login_screen.dart';
import 'read_quotes_page.dart';
import 'favorite_quotes_page.dart';
import 'BookmarkedQuotesPage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() {
    setState(() => _isLoading = true);
    Future.delayed(Duration(seconds: 1), () {
      setState(() => _isLoading = false);
    });
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  void _refreshCategories() => _fetchCategories();

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Quotes Home', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.refresh), tooltip: 'Refresh', onPressed: _refreshCategories),
          IconButton(icon: Icon(Icons.help_outline), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpScreen()))),
          IconButton(icon: Icon(Icons.bookmark), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookmarkedQuotesPage()))),
          IconButton(icon: Icon(Icons.logout), onPressed: () => _logout(context)),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Welcome, $userEmail',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  MouseRegion(
                    onEnter: (_) => SystemMouseCursors.click,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check_circle_outline),
                      label: Text("Read Quotes"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadQuotesPage())),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => SystemMouseCursors.click,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.star, color: Colors.amber),
                      label: Text("Top Rated"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoriteQuotesPage())),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _errorWidget('Error loading categories: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _errorWidget('No categories available.');
                    }

                    final categories = snapshot.data!.docs;
                    return GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index].data() as Map<String, dynamic>;
                        final categoryName = category['name'] as String?;
                        if (categoryName == null) return SizedBox.shrink();

                        return MouseRegion(
                          onEnter: (_) => SystemMouseCursors.click, // Cursor changes on hover
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => QuoteDisplayScreen(category: categoryName)),
                            ),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    categoryName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _refreshCategories,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
