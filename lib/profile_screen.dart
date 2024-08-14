import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserModel>(context);

    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        user.updateProfile(pickedFile.path, user.phoneNumber, user.address);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                pickImage();
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user.profilePicture != null
                    ? FileImage(File(user.profilePicture!))
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.userName ?? 'Guest',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email ?? '',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 1, color: Colors.grey[300]),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(user.phoneNumber ?? 'Add Phone Number'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController(text: user.phoneNumber);
                    return AlertDialog(
                      title: const Text('Edit Phone Number'),
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
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(user.address ?? 'Add Delivery Address'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController(text: user.address);
                    return AlertDialog(
                      title: const Text('Edit Delivery Address'),
                      content: TextField(
                        controller: controller,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            user.updateProfile(user.profilePicture, user.phoneNumber, controller.text);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Spacer(),
            if (user.currentUser != 'Log In to Fill Details') ...[
              ElevatedButton.icon(
                onPressed: () {
                  user.logout();
                  Navigator.pushReplacementNamed(context, '/'); // Navigate to HomeScreen
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
            if (user.currentUser == 'Log In to Fill Details') ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Navigate to LoginScreen
                },
                icon: const Icon(Icons.login),
                label: const Text('Log In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
