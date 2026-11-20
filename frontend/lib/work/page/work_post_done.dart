import 'package:flutter/material.dart';

import '../../component/navbar.dart';

class WorkPostDonePage extends StatelessWidget {
  const WorkPostDonePage({super.key});

  // カラー設定
  static const Color bgColor = Color(0xFF2D2016);
  static const Color orangeColor = Color(0xFFE9782B);
  static const Color mainTextColor = Color(0xFFE9D9C6);
  static const Color subTextColor = Color(0xFFB5A18A);
  static const Color borderColor = Color(0xFF51402D);

  @override
  Widget build(BuildContext context) {
    // ナビ付きの枠に、この画面の中身を渡す(作品タブを選択状態にする)
    return Navbar(
      selectedIndex: NavIndex.work,
      child: Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー部分
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 戻る表示
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: subTextColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '作品',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ページタイトル
                  const Text(
                    '作品投稿',
                    style: TextStyle(
                      color: mainTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    '文字・画像・動画の作品をアップロードできます',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // メニュー
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(
                          Icons.add,
                          size: 17,
                        ),
                        label: const Text('作品投稿'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeColor,
                          disabledBackgroundColor: orangeColor,
                          foregroundColor: bgColor,
                          disabledForegroundColor: bgColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(
                          Icons.grid_view,
                          size: 15,
                        ),
                        label: const Text('マイ作品'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: mainTextColor,
                          disabledForegroundColor: mainTextColor,
                          side: const BorderSide(
                            color: borderColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 投稿完了エリア
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 完了アイコン
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: orangeColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: bgColor,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 投稿完了メッセージ
                    const Text(
                      '「ｐｐ」を投稿しました',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mainTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'みんなに見てもらいましょう。',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // マイ作品を見るボタン
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        disabledBackgroundColor: orangeColor,
                        foregroundColor: bgColor,
                        disabledForegroundColor: bgColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'マイ作品を見る',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}