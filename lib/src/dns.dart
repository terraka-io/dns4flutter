import 'header.dart';
import 'buffer.dart';
import 'question.dart';
import 'record.dart';


class DNSMessage {
  DNSHeader header;
  List<DNSQuestion> question;
  List<DNSRecord> answer;
  List<DNSRecord> authority;
  List<DNSRecord> additional;

  DNSMessage(this.header, this.question, this.answer, this.authority, this.additional);
}

class DNS {
  static const int OPCODE_QUERY = 0;
  static const int OPCPDE_IQUERY = 1;
  static const int OPCODE_STATUS = 2;

  static const int RCODE_NO_ERROR = 0;
  static const int RCODE_FORMAT_ERROR = 1;
  static const int RCODE_SERVER_FAILURE = 2;
  static const int RCODE_NAME_ERROR = 3;
  static const int RCODE_NOT_IMPLEMENTED = 4;
  static const int RCODE_REFUSED = 5;

  static const int QTYPE_A = 1; // a host address
  static const int QTYPE_NS = 2; // an authoritative name server
  static const int QTYPE_MD = 3; // a mail destination (Obsolete - use MX)
  static const int QTYPE_MF = 4; // a mail forwarder (Obsolete - use MX)
  static const int QTYPE_CNAME = 5; // the canonical name for an alias
  static const int QTYPE_SOA = 6; // marks the start of a zone of authority
  static const int QTYPE_MB = 7; // a mailbox domain name (EXPERIMENTAL)
  static const int QTYPE_MG = 8; // a mail group member (EXPERIMENTAL)
  static const int QTYPE_MR = 9; // a mail rename domain name (EXPERIMENTAL)
  static const int QTYPE_NULL = 10; // a null RR (EXPERIMENTAL)
  static const int QTYPE_WKS = 11; // a well known service description
  static const int QTYPE_PTR = 12; // a domain name pointer
  static const int QTYPE_HINFO = 13; // host information
  static const int QTYPE_MINFO = 14; // mailbox or mail list information
  static const int QTYPE_MX = 15; // mail exchange
  static const int QTYPE_TXT = 16; // text strings

  static const int QCLASS_IN = 1; // the Internet
  static const  int QCLASS_CS = 2; // the CSNET class (Obsolete - used only for examples in some obsolete RFCs)
  static const  int QCLASS_CH = 3; // the CHAOS class
  static const  int QCLASS_HS = 4; // Hesiod [Dyer 87]

  static DNSBuffer generateAMessage(String host, {int id = 0x1234,int type = DNS.QTYPE_TXT}) {
    var headerBuffer = (DNSHeader()..id = id).generateBuffer();
    var questionBuffer = (DNSQuestion()..qName = host ..qType =type).generateBuffer();
    return DNSBuffer.combine([headerBuffer, questionBuffer]);
  }

  static DNSMessage parseMessage(DNSBuffer dnsBuffer) {
    var header = DNSHeader.decode(dnsBuffer);
    var questionInfo = DNSQuestion.decode(dnsBuffer, DNSHeader.BUFFER_SIZE, header.qdcount);
    var answerInfo = DNSRecord.decode(dnsBuffer, DNSHeader.BUFFER_SIZE + questionInfo.item2, header.ancount);
    var authorityInfo = DNSRecord.decode(dnsBuffer, DNSHeader.BUFFER_SIZE + questionInfo.item2 + answerInfo.item2, header.nscount);
    var additionalInfo = DNSRecord.decode(dnsBuffer, DNSHeader.BUFFER_SIZE + questionInfo.item2 + answerInfo.item2 + authorityInfo.item2, header.arcount);
    return DNSMessage(
        header,
        questionInfo.item1 ,
        answerInfo.item1 ,
        authorityInfo.item1,
        additionalInfo.item1
    ) ;
  }
}
