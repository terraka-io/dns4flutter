
import 'dart:convert';
import 'dart:typed_data';

class DNSBuffer {
  late Uint8List _buffer;
  Uint8List get raw => _buffer;

  static final List<String> vv = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];

  ///
  /// Create Buffer to join multiple Buffer
  ///
  static DNSBuffer combine(List<DNSBuffer> buffers) {
    var length = 0;
    buffers.forEach((b) {
      length += b.raw.length;
    });
    var buffer = DNSBuffer(length);
    var index = 0;
    buffers.forEach((b) {
      buffer.setBytes(index, b.raw);
      index += b.raw.length;
    });
    return buffer;
  }

  ///
  /// Generate Buffer from List<int>
  ///
  DNSBuffer.fromList(List<int> buffer) {
    _buffer = Uint8List.fromList(buffer);
  }

  ///
  /// Generate Buffer from HexString
  ///
  DNSBuffer.fromHexString(String hexSrc) {
    _buffer = Uint8List(hexSrc.length ~/ 2);
    for (var i = 0, j = 0; i < hexSrc.length; i += 2, j++) {
      var v = int.parse(hexSrc.substring(i, i + 2), radix: 16);
      _buffer[j] = v & 0xFF;
    }
  }

  ///
  /// Create Buffer from Buffer Length
  ///
  DNSBuffer(int length) {
    _buffer = Uint8List(length);

    // ZERO CLEAR
    for (var i = 0; i < length; i++) {
      _buffer[i] = 0;
    }
  }

  DNSBuffer subBuffer(int index, int length) {
    if (length == -1) {
      length = _buffer.length - index;
    }
    return DNSBuffer.fromList(_buffer.sublist(index, index + length));
  }

  int getInt16AtBE(int index) {
    var value = 0;
    var v2 = _buffer[index + 0];
    var v1 = _buffer[index + 1];
    value |= (v1 & 0xFF);
    value |= ((v2 << 8) & 0xFF00);
    return value;
  }

  void setInt16AtBE(int index, int value) {
    _buffer[index + 0] = (value >> 8) & 0xFF;
    _buffer[index + 1] = (value >> 0) & 0xFF;
  }

  int getByte(int index) {
    return _buffer[index] & 0xFF;
  }

  void setByte(int index, int value) {
    _buffer[index] = (value << 0) & 0xFF;
  }

  int getInt32AtBE(int index) {
    var value = 0;
    var v4 = _buffer[index + 0];
    var v3 = _buffer[index + 1];
    var v2 = _buffer[index + 2];
    var v1 = _buffer[index + 3];

    value |= (v1 & 0xFF);
    value |= ((v2 << 8) & 0xFF00);
    value |= ((v3 << 16) & 0xFF0000);
    value |= ((v4 << 24) & 0xFF000000);

    return value;
  }

  void setInt32AtBE(int index, int value) {
    _buffer[index + 0] = (value >> 24) & 0xFF;
    _buffer[index + 1] = (value >> 16) & 0xFF;
    _buffer[index + 2] = (value >> 8) & 0xFF;
    _buffer[index + 3] = (value >> 0) & 0xFF;
  }

  void setBytes(int index, List<int> bytes) {
    _buffer.setRange(index, index + bytes.length, bytes);
  }

  void printAtHex() {
    print(toString());
  }

  @override
  String toString() {
    return toHex();
  }

  String toHex() {
    var b = StringBuffer();
    for (var i = 0; i < _buffer.length; i++) {
      var v = _buffer[i];
      var v1 = (v >> 4) & 0xF;
      var v2 = v & 0xF;
      b.write('${vv[v1]}${vv[v2]}');
    }
    return b.toString();
  }

  String toBase64() {
    return base64.encode(_buffer);
  }
}
