import 'package:flutter/material.dart';

import '../Data/Local/hive_storage.dart';

class Apis {
  //base url

  static const String baseUrl = 'https://api.bumou.space';
  static const String socketUrl = 'http://43.192.67.196:3000';
  // Extra
  static String privacyPolicy =
      '$baseUrl/bumou/privacy-policy?lang=${LocalStorage.getLanguageCode}';

  //Aliyue app data 
  static const String aliyueApiKey='334974694';
  static const String aliyueAppSecret='1b2e1fd964dd4a338d88cde4e468323f';

  //Auth
  static const String signUp = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String getCurrentUser = '$baseUrl/auth/current-user';
  static const String getUserById = '$baseUrl/users/';
  static const String users = '$baseUrl/users';
  static const String updateUser = '$baseUrl/users/update-user';
  static const String updateHelpStatus = '$baseUrl/users/help';
  static const String emailAvailability = '$baseUrl/auth/is-email-available';
  static const String phoneAvailability = '$baseUrl/auth/is-phone-available';
  static const String usernameAvailabile =
      '$baseUrl/auth/is-username-available';
  //Upload file
  static const String uploadFile = '$baseUrl/upload';
  //Friends
  static const String getAllFriends = '$baseUrl/friendship';
  static const String sendFriendRequest = '$baseUrl/friendship/add';
  static const String pending = '$baseUrl/friendship/pending';
  static const String acceptFriendRequest = '$baseUrl/friendship/update';
  static const String searchFriend = '$baseUrl/users/search/';
  static const String suggestedFriend = '$baseUrl/friendship/suggestions';
  static const String removeFriend = '$baseUrl/friendship/remove-friend';
  //Mood
  static const String addMood = '$baseUrl/usermood';
  static const String moodPercentage = '$baseUrl/usermood/moodpercentofdays';
  //Moments
  static const String createPost = '$baseUrl/moments';
  static const String moments = '$baseUrl/moments';
  static const String deletePost = '$baseUrl/moments';
  static const String getUserPosts = '$baseUrl/moments/user';
  //Chat
  static const String chatrooms = '$baseUrl/chat/chatrooms';
  static const String messages = '$baseUrl/chat/messages';
  static const String markRead = '$baseUrl/chat/mark-read';
  //help
  static const String askHelp = '$baseUrl/help/ask';
  static const String deleteHelp = '$baseUrl/help/delete';

  static const String incomingHelps = '$baseUrl/help/incoming-requests';
  static const String myPendingHelp = '$baseUrl/help/my-pending';
  static const String getHelpMessages = '$baseUrl/help/messages';
  static const String cancelHelp = '$baseUrl/help/cancel';
  static const String getOngoingHelp = '$baseUrl/help/ongoing';
  static const String acceptHelp = '$baseUrl/help/accept';
 
}
