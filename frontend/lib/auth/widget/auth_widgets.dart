import 'package:flutter/material.dart';

import '../../core/kakko_theme.dart';

/// 認証画面の共通の外枠(背景、角丸のカード、ロゴ)
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.children, this.showBack = false});

  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kakkoTheme(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.2),
              radius: 1.1,
              colors: [Color(0x1AE07B2E), Color(0x00E07B2E)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                    decoration: BoxDecoration(
                      color: KakkoColors.inkSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: KakkoColors.inkLine),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showBack) const AuthBackLink(),
                        const AuthWordmark(),
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

class AuthBackLink extends StatelessWidget {
  const AuthBackLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(
            foregroundColor: KakkoColors.muted,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: TextStyle(fontSize: 12.5),
          ),
          child: const Text('← 戻る'),
        ),
      ),
    );
  }
}

class AuthWordmark extends StatelessWidget {
  const AuthWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dark_mode_outlined,
              size: 20, color: KakkoColors.accent),
          const SizedBox(width: 8),
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

/// 画面のタイトルと説明文(.auth-title / .auth-sub)
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key, required this.title, required this.sub});

  final String title;
  final String sub;

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
        const SizedBox(height: 22),
      ],
    );
  }
}

/// ラベル付きの入力欄(.form-field / .form-label / .form-input / .auth-field-error)
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

  final String label;
  final TextEditingController controller;
  final String? error;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: KakkoColors.paperText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            cursorColor: KakkoColors.accent,
            style: TextStyle(
                fontSize: 14, color: KakkoColors.paperText),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: KakkoColors.fieldFill,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: _border(KakkoColors.inkLine),
              enabledBorder:
                  _border(hasError ? KakkoColors.errorBorder : KakkoColors.inkLine),
              focusedBorder:
                  _border(hasError ? KakkoColors.errorBorder : KakkoColors.muted),
            ),
          ),
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

/// 丸いボタン(.auth-btn-primary / .auth-btn-secondary)
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    const padding = EdgeInsets.symmetric(vertical: 14, horizontal: 18);
    final VoidCallback? action = loading ? null : onPressed;

    final Widget child = loading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: KakkoColors.ink),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      child: primary
          ? FilledButton(
              onPressed: action,
              style: FilledButton.styleFrom(
                backgroundColor: KakkoColors.accent,
                foregroundColor: KakkoColors.ink,
                disabledBackgroundColor: KakkoColors.accentDisabled,
                disabledForegroundColor: KakkoColors.ink,
                padding: padding,
                shape: const StadiumBorder(),
                textStyle: textStyle,
              ),
              child: child,
            )
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

/// サーバーやFirebaseから返ったエラーの表示
class AuthMessage extends StatelessWidget {
  const AuthMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: KakkoColors.errorFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: KakkoColors.errorBorder),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KakkoColors.errorText,
          ),
        ),
      ),
    );
  }
}

/// 「アカウントをお持ちでない方は 新規登録」のような切り替えリンク
class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    super.key,
    required this.text,
    required this.linkLabel,
    required this.onTap,
  });

  final String text;
  final String linkLabel;
  final VoidCallback? onTap;

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
              foregroundColor: KakkoColors.accent,
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
