import 'package:flutter/material.dart';

import '../../core/kakko_theme.dart';

/// ================================================================
/// 認証画面の共通の外枠（背景、ラジアルグラデーション、カード状のレイアウト、ロゴ）
/// ================================================================
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.children, this.showBack = false});

  // カードの中に並べるウィジェットのリスト（入力欄やボタンなど）
  final List<Widget> children;
  
  // 「← 戻る」ボタンを表示するかどうか（デフォルトは非表示）
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // アプリ全体（またはこの画面専用）のデザインテーマを適用
      data: kakkoTheme(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // 背景全体に、上部からうっすらとオレンジ系のグラデーションをかける
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.2), // グラデーションの中心位置（画面上部寄り）
              radius: 1.1,
              colors: [Color(0x1AE07B2E), Color(0x00E07B2E)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView( // キーボードが表示されたときに画面が潰れてエラーになるのを防ぐ
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400), // カードの最大幅を400pxに制限（PCやタブレットで広がりすぎないようにする）
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28), // カード内の余白
                    decoration: BoxDecoration(
                      color: KakkoColors.inkSoft, // カードの背景色
                      borderRadius: BorderRadius.circular(16), // カードの角を丸くする
                      border: Border.all(color: KakkoColors.inkLine), // カードの枠線
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // showBackがtrueの場合のみ、「戻る」リンクを表示する
                        if (showBack) const AuthBackLink(),
                        
                        // 共通のロゴ（アイコン ＋ kakko. という文字）を表示
                        const AuthWordmark(),
                        
                        // 画面ごとに渡された子要素（入力欄やボタンなど）を並べる
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ================================================================
/// 「← 戻る」リンクボタン
/// ================================================================
class AuthBackLink extends StatelessWidget {
  const AuthBackLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: TextButton(
          // 押されたら前の画面に戻る（履歴がなければ何もしない safe な戻り方）
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(
            foregroundColor: KakkoColors.muted, // 文字色を落ち着いた色に
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 余計なタップ領域を削る
            textStyle: TextStyle(fontSize: 12.5),
          ),
          child: const Text('← 戻る'),
        ),
      ),
    );
  }
}

/// ================================================================
/// アプリのロゴ・ブランド名（kakko.）を表示するパーツ
/// ================================================================
class AuthWordmark extends StatelessWidget {
  const AuthWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 月や三日月をイメージさせるアイコン
          const Icon(Icons.dark_mode_outlined,
              size: 20, color: KakkoColors.accent),
          const SizedBox(width: 8),
          // ブランド名（イタリック体のスタイリッシュな文字）
          Text(
            'kakko.',
            style: TextStyle(
              fontSize: 26,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.26,
              color: KakkoColors.paperText,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================================================================
/// 画面のタイトル（例：「ログイン」）とサブタイトル（説明文）
/// ================================================================
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key, required this.title, required this.sub});

  final String title; // 大見出し
  final String sub;   // 説明文

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: KakkoColors.paperText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: KakkoColors.muted),
        ),
        const SizedBox(height: 22), // タイトル下の余白
      ],
    );
  }
}

/// ================================================================
/// ラベル付きのテキスト入力欄（メールアドレス、パスワード、ユーザー名など）
/// ================================================================
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;                          // 入力欄の上部に表示するラベル名
  final TextEditingController controller;      // 入力された文字を管理・取得するコントローラー
  final String? error;                         // エラーメッセージ（存在する場合は赤枠＆赤字エラーを表示）
  final bool obscure;                          // パスワードのように「●●●」で隠すかどうか
  final TextInputType? keyboardType;           // キーボードの種類（メールアドレス用キーボードなど）
  final TextInputAction? textInputAction;      // キーボードの右下のボタンの種類（次へ、完了など）
  final ValueChanged<String>? onChanged;       // 文字が入力されるたびに呼ばれるコールバック
  final ValueChanged<String>? onSubmitted;     // キーボードの決定ボタンが押されたときに呼ばれるコールバック

  // 入力欄の枠線デザインを色指定で動的に生成するヘルパー関数
  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // 角丸の入力ボックス
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = error != null; // エラーメッセージがあるかどうかを判定
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 項目名ラベル
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: KakkoColors.paperText,
            ),
          ),
          const SizedBox(height: 8),
          
          // 実際の入力ボックス
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            cursorColor: KakkoColors.accent, // カーソルの色
            style: TextStyle(
                fontSize: 14, color: KakkoColors.paperText),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: KakkoColors.fieldFill, // 入力欄の背景色
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              // 通常時の枠線
              border: _border(KakkoColors.inkLine),
              // フォーカスが当たっていないときの枠線（エラー時は赤枠にする）
              enabledBorder:
                  _border(hasError ? KakkoColors.errorBorder : KakkoColors.inkLine),
              // 選択中（タップ中）のときの枠線
              focusedBorder:
                  _border(hasError ? KakkoColors.errorBorder : KakkoColors.muted),
            ),
          ),
          
          // エラーがある場合のみ、入力欄の下に赤い文字でエラーメッセージを表示
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                error!,
                style: TextStyle(
                    fontSize: 12, color: KakkoColors.errorText),
              ),
            ),
        ],
      ),
    );
  }
}

/// ================================================================
/// メインのアクションボタン（「ログインする」「登録する」など）
/// ================================================================
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.loading = false,
  });

  final String label;          // ボタンの文字
  final VoidCallback? onPressed; // ボタンが押されたときの処理
  final bool primary;          // メインボタン（塗りつぶし）かサブボタン（枠線のみ）か
  final bool loading;          // 通信中（ローディング中）かどうか

  @override
  Widget build(BuildContext context) {
    final textStyle =
        TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    const padding = EdgeInsets.symmetric(vertical: 14, horizontal: 18);
    
    // ローディング中のときはボタンを無効化（nullを渡す）する
    final VoidCallback? action = loading ? null : onPressed;

    // ローディング中ならボタンの文字の代わりに「くるくる回るインジケーター」を表示する
    final Widget child = loading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: KakkoColors.ink),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity, // 横幅いっぱいにボタンを広げる
      child: primary
          // プライマリボタン（アクセントカラーで塗りつぶし、角丸がカプセルのような形）
          ? FilledButton(
              onPressed: action,
              style: FilledButton.styleFrom(
                backgroundColor: KakkoColors.accent,
                foregroundColor: KakkoColors.ink,
                disabledBackgroundColor: KakkoColors.accentDisabled, // 無効化時の背景色
                disabledForegroundColor: KakkoColors.ink,
                padding: padding,
                shape: const StadiumBorder(), // 丸みを帯びたカプセル型
                textStyle: textStyle,
              ),
              child: child,
            )
          // セカンダリボタン（枠線のみのデザイン）
          : OutlinedButton(
              onPressed: action,
              style: OutlinedButton.styleFrom(
                foregroundColor: KakkoColors.paperText,
                side: const BorderSide(color: KakkoColors.inkLine),
                padding: padding,
                shape: const StadiumBorder(),
                textStyle: textStyle,
              ),
              child: child,
            ),
    );
  }
}

/// ================================================================
/// サーバーやFirebaseから返ってきたエラーメッセージを大きく表示するボックス
/// ================================================================
class AuthMessage extends StatelessWidget {
  const AuthMessage({super.key, required this.message});

  final String message; // 表示するエラー文章

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: KakkoColors.errorFill, // エラー用の薄い背景色
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: KakkoColors.errorBorder), // エラー用の枠線
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KakkoColors.errorText, // エラー用の文字色
          ),
        ),
      ),
    );
  }
}

/// ================================================================
/// 画面下部の切り替えリンク（例：「アカウントをお持ちでない方は 新規登録」）
/// ================================================================
class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    super.key,
    required this.text,
    required this.linkLabel,
    required this.onTap,
  });

  final String text;      // 「アカウントをお持ちでない方は」などの説明文
  final String linkLabel; // 「新規登録」などのリンク部分の文字
  final VoidCallback? onTap; // リンクが押されたときの画面遷移処理

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$text ',
            style: TextStyle(fontSize: 13, color: KakkoColors.muted),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: KakkoColors.accent, // 目立つアクセントカラー
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            child: Text(linkLabel),
          ),
        ],
      ),
    );
  }
}