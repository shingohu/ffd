import 'package:flutter/services.dart';

class MoneyTextInputFormatter extends TextInputFormatter {
  static const defaultDouble = 0.000001;

  ///最大输入金额
  final double? maxMoney;

  ///允许的小数位数 默认为2
  final int digit;

  MoneyTextInputFormatter({this.maxMoney, this.digit = 2});

  double strToFloat(String str, [double defaultValue = defaultDouble]) {
    try {
      if (str.length > 1) {
        if (str[0] == "0" && str[1] != ".") {
          return defaultDouble;
        }
      }
      return double.parse(str);
    } catch (e) {
      return defaultValue;
    }
  }

  ///获取目前的小数位数
  int getValueDigit(String value) {
    if (value.contains(".")) {
      return value.split(".")[1].length;
    } else {
      return -1;
    }
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    int selectionIndex = newValue.selection.end;

    if (value == ".") {
      // 如果输入框内容为.直接将输入框赋值为0.
      value = "0.";
      selectionIndex++;
      // 如果输入框内容为-号，也是被允许的，但是需要正则表达式的时候进行处理一下，允许-号被使用
    } else if (value == "-") {
      value = "-";
      selectionIndex++;
    } else if (value != "" && value != defaultDouble.toString() && strToFloat(value, defaultDouble) == defaultDouble || getValueDigit(value) > digit) {
      if (value.length > 1) {
        if (value[0] == "0" && value[1] != ".") {
          value = value.substring(1);
          selectionIndex--;
        } else {
          value = oldValue.text;
          selectionIndex = oldValue.selection.end;
        }
      }
    }
    // 通过最上面的判断，这里返回的都是有限金额形式
    return new TextEditingValue(
      text: value,
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
