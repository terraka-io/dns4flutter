import 'package:dns4flutter/src/tuple.dart';
import 'buffer.dart';
import 'name.dart';

class DNSRecord {

  String name; //xx bit
  int type; //16bit
  int clazz; //16bit
  int ttl; // 32bit
  int rdlength; // 16bit
  List<int> rdata; // edlength bytes;

  DNSRecord(this.name, this.type, this.clazz, this.ttl, this.rdlength, this.rdata);

  static Tuple2<List<DNSRecord>, int> decode(DNSBuffer buffer, int index, int count) {
    var indexTmp = index;
    var records = <DNSRecord>[];
    for (var i = 0; i < count; i++) {

      var name = DNSName.createUrlFromName(buffer.raw, indexTmp);

      var rdlength = buffer.getInt16AtBE(indexTmp + name.item2 + 2 + 2 + 4);
      var record = DNSRecord(name.item1,
          buffer.getInt16AtBE(indexTmp + name.item2),
          buffer.getInt16AtBE(indexTmp + name.item2 + 2),
          buffer.getInt32AtBE(indexTmp + name.item2 + 2 + 2),
          rdlength,
          buffer.subBuffer(indexTmp + name.item2 + 2 + 2 + 4 + 2, rdlength).raw
      );

      indexTmp += indexTmp + name.item2 + 2 + 2 + 4 + 2 + record.rdlength;
      records.add(record);
    }
    return Tuple2(records, indexTmp - index);
  }


}
