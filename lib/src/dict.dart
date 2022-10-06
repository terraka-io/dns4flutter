import 'dart:convert';
import 'dart:typed_data' show Uint8List;

class DNSCompressionDictItem {
  int index;

  DNSCompressionDictItem(this.index);
}

class DNSCompressionDict {
  Map<String, DNSCompressionDictItem> dict = {};

  Uint8List add(String item, int index) {
    var items = item.split('.');
    var buffer = <int>[];
    for (var i = 0; i < items.length; i++) {
      var key = items.sublist(i).join('.');
      if (dict.containsKey(key)) {
        var tmp = dict[key]!.index | 0xC000;
        buffer.addAll([(tmp >> 8) & 0xFF, tmp & 0xFF]);
        return Uint8List.fromList(buffer);
      } else {
        buffer.add(items[i].length);
        buffer.addAll(ascii.encode(items[i]));
        dict[key] = DNSCompressionDictItem(index);
        index += items[i].length + 1;
      }
    }
    if (buffer.isNotEmpty) {
      buffer.add(0);
    }
    return Uint8List.fromList(buffer);
  }
}
