import 'package:flutter/material.dart';

class StText extends StatelessWidget {
  final Color? color;
  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final bool? softWrap;
  final double? styleHeight;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  StText(
    this.text, {
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.styleHeight,
    this.softWrap,
    this.textAlign,
    this.overflow,
  });

  StText.white(
    this.text, {
    this.fontWeight,
    this.maxLines,
    this.softWrap,
    this.textAlign,
    this.overflow,
    this.fontSize = TextSize.normal,
    this.styleHeight = 1.2,
    this.color = Colors.white,
  });

  StText.black(
    this.text, {
    this.fontWeight,
    this.maxLines,
    this.softWrap,
    this.textAlign,
    this.overflow,
    this.fontSize = TextSize.normal,
    this.styleHeight = 1.2,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      softWrap: this.softWrap,
      textAlign: textAlign,
      style: TextStyle(
        height: styleHeight,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }
}

class TextSize {
  static const double huge = 24;
  static const double xxxlarge = 22;
  static const double xxlarge = 20;
  static const double xlarge = 18;
  static const double large = 16;
  static const double normal = 14;
  static const double small = 12;
  static const double tiny = 10;
}

String filterText(String text) {
  String tag = '<br>';
  while (text.contains('<br>')) {
// flutter 算高度,单个\n算不准,必须加两个
    text = text.replaceAll(tag, '\n\n');
  }
  return text;
}

///value: 文本内容；fontSize : 文字的大小；fontWeight：文字权重；maxWidth：文本框的最大宽度；maxLines：文本支持最大多少行
Size calculateTextSize(
  BuildContext context,
  String value, {
  FontWeight? fontWeight,
  final double? styleHeight,
  double maxWidth = double.infinity,
  int maxLines = 1,
  double fontSize = 14,
}) {
  value = filterText(value);
  TextPainter painter = TextPainter(

      ///AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
      locale: Localizations.localeOf(context),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      text: TextSpan(
          text: value,
          style: TextStyle(
            height: styleHeight,
            fontWeight: fontWeight,
            fontSize: fontSize,
          )));
  painter.layout(maxWidth: maxWidth);
  return Size(painter.width, painter.height);
}
