import 'dart:convert' show ascii;
import 'dart:typed_data' show Uint8List;
import 'dict.dart';
import 'tuple.dart';


class DNSName {
  ///
  /// create QName Buffer from url
  ///
  static Uint8List createNameFromUrl(String url, {DNSCompressionDict? dict, int index = 0}) {
    dict ??= DNSCompressionDict();
    return dict.add(url, 0);
  }

  ///
  /// create url string from qname buffer.
  /// return values
  ///   string item is url
  ///   int item is length with Null(0)
  static Tuple2<String, int> createUrlFromName(Uint8List srcBuffer, int index) {
    var outBuffer = StringBuffer();
    var i = index;
    for (; i < srcBuffer.length;) {
      var nameLength = srcBuffer[i];
      if (nameLength == 0) {
        // TEXT END
        i++;
        return Tuple2<String, int>(outBuffer.toString(), i - index);
      } else if ((0xC0 & nameLength) == 0xC0) {
        // Compression
        var v = ((nameLength & 0x3f) << 8) | srcBuffer[++i];
        var r = createUrlFromName(srcBuffer, v);
        if (outBuffer.length > 0) {
          outBuffer.write('.');
        }
        outBuffer.write(r.item1);
        i++;
        return Tuple2<String, int>(outBuffer.toString(), i - index);
      } else {
        var nameBytes = srcBuffer.sublist(i + 1, i + 1 + nameLength);
        if (outBuffer.length > 0) {
          outBuffer.write('.');
        }
        outBuffer.write(ascii.decode(nameBytes, allowInvalid: true));
        i = i + 1 + nameLength;
      }
    }
    throw DNSNameException('Not Found Null Char');
  }
}

class DNSNameException implements Exception {
  String cause;
  DNSNameException(this.cause);
}
