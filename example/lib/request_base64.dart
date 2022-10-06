import 'dart:typed_data' show Uint8List;
import 'dart:convert' show base64;

Uint8List fromHexString(String hexSrc) {
  var _buffer = Uint8List(hexSrc.length ~/ 2);
  for (var i = 0, j = 0; i < hexSrc.length; i += 2, j++) {
    var v = int.parse(hexSrc.substring(i, i + 2), radix: 16);
    _buffer[j] = v & 0xFF;
  }
  return _buffer;
}

void main() {
  var buffer = fromHexString('1234010000010000000000000667697468756203636f6d0000010001');
  print(base64.encode(buffer));
}
