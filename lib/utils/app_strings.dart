import 'package:flutter/material.dart';

class AppStrings {
  static Map<String, Map<String, String>> localizedValues = {
    'en': {
      'app_title': 'Quit What?',
      'subtitle': 'Discipline & Savings',
      'total_saved': 'Total Saved',
      'days': 'Days',
      'check_in': 'Check In',
      'done': 'Done',
      'add_habit': 'Add Habit',
      'habit_name': 'Habit Name',
      'cost_per_day': 'Cost Per Day',
      'save': 'Save',
      'cancel': 'Cancel',
      'purchasable': 'You can buy:',
    },
    'zh': {
      'app_title': '戒什么',
      'subtitle': '自律与搞钱',
      'total_saved': '累计节省',
      'days': '天',
      'check_in': '打卡',
      'done': '已完成',
      'add_habit': '添加习惯',
      'habit_name': '习惯名称',
      'cost_per_day': '日均开销 (元)',
      'save': '保存',
      'cancel': '取消',
      'purchasable': '这笔钱够买：',
    },
  };

  static String get(String key, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final lang = (locale == 'zh') ? 'zh' : 'en';
    return localizedValues[lang]?[key] ?? key;
  }
}
