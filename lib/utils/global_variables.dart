import 'package:flutter/material.dart';
import 'package:instagram/screens/add_post_screen.dart';

// Define the screen size breakpoint for web vs. mobile
const webScreenSize = 600;

// Define the items for the home screen navigation
final homeScreenItems = [
  const Text('feed'), // Feed screen placeholder
  Text('search'), // Search screen placeholder
  AddPostScreen(), // Add Post screen
  Text('notif'), // Notifications screen placeholder
  Text('profile'), // Profile screen placeholder
];
