import 'dart:convert';

String removeHtmlTagFromString(String? text) {
  if (text == null) {
    return "";
  }

  List<String> brs = ['<br>', '<br/>', '<br />'];
  for (String br in brs) {
    text = text!.replaceAll(br, '\n');
    text = text.replaceAll(br.toUpperCase(), '\n');
  }

  RegExp htmlTagRegExp = RegExp(r'<[^>]*>');
  return text!.replaceAll(htmlTagRegExp, '');
}

List splice(List list, int index, [num howMany = 0, dynamic elements]) {
  var endIndex = index + howMany.truncate();
  list.removeRange(index, endIndex >= list.length ? list.length : endIndex);
  if (elements != null) {
    list.insertAll(index, elements is List ? elements : <String>[elements]);
  }
  return list;
}

String printDuration(Duration duration) {
  //String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  //return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  return "$twoDigitMinutes:$twoDigitSeconds";
}

String idGenerator() {
  DateTime now = DateTime.now();
  return now.microsecondsSinceEpoch.toString();
}

String toBase64(String val) {
  List<int> bytes = utf8.encode(val);
  return base64.encode(bytes);
}
