import 'dns.dart';
import 'buffer.dart';
import 'name.dart';
import 'tuple.dart';

///
///
/// QCLASS: 16bit
class DNSQuestion {
  String qName = 'github.com'; // QNAME: X bit
  int qType = DNS.QTYPE_A; // QTYPE: 16bit
  int qClass = DNS.QCLASS_IN; // QCLASS: 16bit

  DNSBuffer generateBuffer() {
    return DNSQuestion.encode(this);
  }

  static DNSBuffer encode(DNSQuestion q) {
    var qnameBuffer = DNSName.createNameFromUrl(q.qName);
    var buffer = DNSBuffer(qnameBuffer.length + 2 + 2);
    buffer.setBytes(0, qnameBuffer);
    buffer.setInt16AtBE(qnameBuffer.length, q.qType);
    buffer.setInt16AtBE(qnameBuffer.length + 2, q.qClass);
    return buffer;
  }

  static Tuple2<List<DNSQuestion>, int> decode(DNSBuffer buffer, int index, int count) {
    var questions = <DNSQuestion>[];
    var indexTmp = index;
    for (var i = 0; i < count; i++) {
      var question = DNSQuestion();
      var url = DNSName.createUrlFromName(buffer.raw, indexTmp);
      question.qName = url.item1;
      question.qType = buffer.getInt16AtBE(indexTmp + url.item2);
      question.qClass = buffer.getInt16AtBE(indexTmp + url.item2 + 2);
      questions.add(question);
      indexTmp += url.item2 + 4;
    }
    return Tuple2<List<DNSQuestion>, int>(questions, indexTmp - index);
  }
}
