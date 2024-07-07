import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'user_model.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserModel>(context);

    Future<void> _pickImage() async {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        user.updateProfile(pickedFile.path, user.phoneNumber, user.address);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user.profilePicture != null
                    ? FileImage(File(user.profilePicture!))
                    : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            Text(
              user.userName ?? 'Guest',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email ?? '',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Divider(thickness: 1, color: Colors.grey[300]),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(user.phoneNumber ?? 'Add Phone Number'),
              trailing: Icon(Icons.edit),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController(text: user.phoneNumber);
                    return AlertDialog(
                      title: Text('Edit Phone Number'),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            user.updateProfile(user.profilePicture, controller.text, user.address);
                            Navigator.of(context).pop();
                          },
                          child: Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(user.address ?? 'Add Delivery Address'),
              trailing: Icon(Icons.edit),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController(text: user.address);
                    return AlertDialog(
                      title: Text('Edit Delivery Address'),
                      content: TextField(
                        controller: controller,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            user.updateProfile(user.profilePicture, user.phoneNumber, controller.text);
                            Navigator.of(context).pop();
                          },
                          child: Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Spacer(),
            if (user.currentUser != 'Log In to Fill Details') ...[
              ElevatedButton.icon(
                onPressed: () {
                  user.logout();
                  Navigator.pushReplacementNamed(context, '/'); // Navigate to HomeScreen
                },
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
            if (user.currentUser == 'Log In to Fill Details') ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Navigate to LoginScreen
                },
                icon: Icon(Icons.login),
                label: Text('Log In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
