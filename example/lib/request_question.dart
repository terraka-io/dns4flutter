import 'dart:typed_data' show Buffer;
import 'dart:convert' show ascii;
import 'dart:typed_data' show Uint8List;

String toHex(Uint8List buffer) {
  const List<String> vv = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];
  var b = StringBuffer();
  for (var i = 0; i < buffer.length; i++) {
    var v = buffer[i];
    var v1 = (v >> 4) & 0xF;
    var v2 = v & 0xF;
    b.write('${vv[v1]}${vv[v2]}');
  }
  return b.toString();
}

void setInt16AtBE(Uint8List _buffer, int index, int value) {
  _buffer[index + 0] = (value >> 8) & 0xFF;
  _buffer[index + 1] = (value >> 0) & 0xFF;
}

void main() {
  var host = 'github.com';
  var splitHost = host.split('.');
  // Calc Buffer Size
  var length = splitHost.length;
  splitHost.forEach((e) {
    length += e.length;
  });
  length += 1; // NULL CHAR
  length += 4; // CLASS  AND TYPE

  // Set Value
  var buffer = Uint8List(length);
  for (var i = 0; i < 12; i++) {
    buffer[i] = 0;
  }

  var index = 0;
  splitHost.forEach((e) {
    buffer[index++] = e.length;
    for (var i = 0; i < e.length; i++) {
      buffer[index++] = ascii.encode(e.substring(i, i + 1))[0];
    }
  });

  setInt16AtBE(buffer, length - 4, 0x01);
  setInt16AtBE(buffer, length - 2, 0x01);
  print(toHex(buffer)); // 0667697468756203636f6d0000010001
}
