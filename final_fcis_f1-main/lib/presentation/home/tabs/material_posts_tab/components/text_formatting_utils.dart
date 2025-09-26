import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextFormattingUtils {
  static Widget buildMixedDirectionText(String text, {TextStyle? style}) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final List<InlineSpan> spans = [];
    StringBuffer? currentBuffer;
    bool? isCurrentArabic;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isArabic = arabicRegex.hasMatch(char);

      if (isCurrentArabic == null) {
        isCurrentArabic = isArabic;
        currentBuffer = StringBuffer(char);
      } else if (isArabic == isCurrentArabic) {
        currentBuffer!.write(char);
      } else {
        spans.add(TextSpan(
          text: currentBuffer.toString(),
          style: style,
        ));
        isCurrentArabic = isArabic;
        currentBuffer = StringBuffer(char);
      }
    }

    if (currentBuffer != null && currentBuffer.isNotEmpty) {
      spans.add(TextSpan(
        text: currentBuffer.toString(),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textDirection:
          containsArabic(text) ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  static bool containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  static List<InlineSpan> parseTextWithLinks(String text,
      {TextStyle? baseStyle, TextStyle? linkStyle}) {
    final urlRegex = RegExp(r"(https?:\/\/[^\s]+)", caseSensitive: false);
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in urlRegex.allMatches(text)) {
      // Add text before the URL
      if (match.start > lastEnd) {
        spans.addAll(
            _buildTextSpans(text.substring(lastEnd, match.start), baseStyle));
      }

      // Add the URL
      spans.add(TextSpan(
        text: match.group(0),
        style: linkStyle ??
            TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => launchUrl(Uri.parse(match.group(0)!)),
      ));

      lastEnd = match.end;
    }

    // Add remaining text after last URL
    if (lastEnd < text.length) {
      spans.addAll(_buildTextSpans(text.substring(lastEnd), baseStyle));
    }

    return spans;
  }

  static List<InlineSpan> _buildTextSpans(String text, TextStyle? style) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final spans = <InlineSpan>[];
    StringBuffer? currentBuffer;
    bool? isCurrentArabic;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isArabic = arabicRegex.hasMatch(char);

      if (isCurrentArabic == null) {
        isCurrentArabic = isArabic;
        currentBuffer = StringBuffer(char);
      } else if (isArabic == isCurrentArabic) {
        currentBuffer!.write(char);
      } else {
        spans.add(TextSpan(
          text: currentBuffer.toString(),
          style: style,
        ));
        isCurrentArabic = isArabic;
        currentBuffer = StringBuffer(char);
      }
    }

    if (currentBuffer != null && currentBuffer.isNotEmpty) {
      spans.add(TextSpan(
        text: currentBuffer.toString(),
        style: style,
      ));
    }

    return spans;
  }
}
