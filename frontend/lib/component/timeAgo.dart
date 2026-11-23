// 投稿時間を「〇〇前」の形式で表示する関数
String timeAgo(DateTime createdAt) {
  final difference = DateTime.now().difference(createdAt);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}秒前';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}分前';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours}時間前';
  }

  if (difference.inDays < 30) {
    return '${difference.inDays}日前';
  }

  if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()}ヶ月前';
  }

  return '${(difference.inDays / 365).floor()}年前';
}

// 投稿時間をフォーマットする関数
String formatCreatedAt(DateTime createdAt) {
  final hour = createdAt.hour;
  final minute = createdAt.minute.toString().padLeft(2, '0');

  final ampm = hour >= 12 ? '午後' : '午前';
  final hour12 = hour == 0
      ? 12
      : hour > 12
          ? hour - 12
          : hour;

  return '$ampm$hour12:$minute · '
      '${createdAt.year}年'
      '${createdAt.month}月'
      '${createdAt.day}日';
}