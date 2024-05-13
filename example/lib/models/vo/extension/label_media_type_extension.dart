import 'package:bxlflutterbgatelib_example/models/vo/label_media_type.dart';

extension LabelMediaTypeExtension on LabelMediaType {
  int get convertedInteger {
    switch (this) {
      case LabelMediaType.gap:
        return 0;
      case LabelMediaType.blackMark:
        return 1;
      case LabelMediaType.continuous:
        return 2;
      default:
        return 0;
    }
  }

  String get convertedText {
    switch (this) {
      case LabelMediaType.gap:
        return 'G';
      case LabelMediaType.blackMark:
        return 'B';
      case LabelMediaType.continuous:
        return 'C';
      default:
        return '';
    }
  }
}
