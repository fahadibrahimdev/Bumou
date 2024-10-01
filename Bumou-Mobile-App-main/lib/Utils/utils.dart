class AppUtils {
  static String buildChatroomId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id];
    ids.sort();
    return ids.join('_');
  }
}
