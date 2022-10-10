
import 'dart:math' show Random;

import 'dns.dart';
import 'buffer.dart';

class DNSHeader {
  static final BUFFER_SIZE = 12;

  //
  int id = 0; // ID: 16bit if 0 generate RandomID
  int qr = 0; // QR: 1bit  query (0), or a response (1).
  int opcode = DNS.OPCODE_QUERY; // OPCODE: 4bit
  bool aa = false; // AA: 1bit
  bool tc = false; // TC: 1bit
  bool rd = true; // RD: 1bit
  bool ra = false; // RA: 1bit
  int z = 0; // Z: 3bit
  int rcode = DNS.RCODE_NO_ERROR; // RCODE: 4bit
  int qdcount = 1; // QDCOUNT: 16bit
  int ancount = 0; // ANCOUNT: 16bit
  int nscount = 0; // NSCOUNT: 16bit
  int arcount = 0; // ARCOUNT: 16bit

  DNSBuffer generateBuffer() {
    return DNSHeader.encode(this);
  }

  static DNSHeader decode(DNSBuffer buffer) {
    var header = DNSHeader();
    header.id = buffer.getInt16AtBE(0);
    {
      var tmp = buffer.getByte(2);
      header.qr = (tmp >> 7) & 0x01;
      header.opcode = (tmp >> 3) & 0x0F;
      header.aa = ((tmp >> 2) & 0x01) == 1;
      header.tc = ((tmp >> 1) & 0x01) == 1;
      header.rd = ((tmp >> 0) & 0x01) == 1;
    }
    {
      var tmp = buffer.getByte(3);
      header.ra = ((tmp >> 7) & 0x01) == 1;
      header.z = (tmp >> 4) & 0x07;
      header.rcode = (tmp >> 0) & 0x0F;
    }

    {
      header.qdcount = buffer.getInt16AtBE(4);
      header.ancount = buffer.getInt16AtBE(6);
      header.nscount = buffer.getInt16AtBE(8);
      header.arcount = buffer.getInt16AtBE(10);
    }
    return header;
  }

  static DNSBuffer encode(DNSHeader header) {
    var buffer = DNSBuffer(12);

    ///
    /// HEADER
    ///
    {
      // ID: 16bit
      var id = header.id;
      if (id == 0) {
        id = Random.secure().nextInt(0xFFFF);
      }
      buffer.setInt16AtBE(0, id);
    }
    {
      var tmp = 0x00;
      tmp |= (header.qr << 7) & 0xFF;
      tmp |= (header.opcode << 3);
      if (header.aa) {
        tmp |= (0x01 << 2) & 0xFF;
      }
      if (header.tc) {
        tmp |= (0x01 << 1) & 0xFF;
      }
      if (header.rd) {
        tmp |= (0x01 << 0) & 0xFF;
      }
      buffer.setByte(2, tmp);
    }
    {
      var tmp = 0x00;
      if (header.ra) {
        tmp |= (0x01 << 7) & 0xFF;
      }
      tmp |= (header.z << 4) & 0xFF;
      tmp |= (header.rcode) & 0xFF;

      buffer.setByte(3, tmp);
    }

    buffer.setInt16AtBE(4, header.qdcount);
    buffer.setInt16AtBE(6, header.ancount);
    buffer.setInt16AtBE(8, header.nscount);
    buffer.setInt16AtBE(10, header.arcount);
    return buffer;
  }
}
