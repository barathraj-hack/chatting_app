import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // sign user out
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Chats",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            //sign out button
            IconButton(
              onPressed: signOut,
              icon: const Icon(Icons.logout, color: Colors.black, size: 26),
            ),
          ],
        ),
        body: _buildUserList(),
      ),
    );
  }

  //build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  //build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    //display all users except the current user
    if (_auth.currentUser!.email != data['email']) {
      return Padding(
        padding: const EdgeInsets.all(7.0),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 223, 234, 241),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      data['email'],
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right_sharp, color: Colors.black),
              ],
            ),
            onTap: () {
              //pass the clicked user's UID to the chat page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    userEmail: data['email'],
                    receiverUserId: data['uid'],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // return empty container
      return Container();
    }
  }
}
