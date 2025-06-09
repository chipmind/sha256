//======================================================================
//
// calc_padding
// ------------
// Model used to learn and test how to calculate final padding. his
// padding is limited to messages in whole bytes.
//
// Build with:
// iverilog -o calc_padding calc_padding.v
//
//
// Author: Joachim Strömbergson
// Copyright (c) 2013 Secworks Sweden AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//======================================================================

`default_nettype none

module calc_padding();

  //----------------------------------------------------------------
  //----------------------------------------------------------------
  reg [63 : 0]  num_msg_blocks;
  reg [6 : 0]   final_num_bytes;
  reg [511 : 0] last_block;
  reg [63 : 0]  msg_len_in_bytes;
  reg [511 : 0] padded_last_block;
  reg [511 : 0] extra_padding_block;


  function automatic [511 : 0] gen_padded_last_block(
                                                      input [511 : 0] last_block,
                                                      input [63 : 0] msg_len,
                                                      input [5 : 0] num_bytes
                                                     );
    begin
      case(num_bytes)
        00: gen_padded_last_block = {last_block[511 : 511], 8'h80, 440'h0, msg_len};
        01: gen_padded_last_block = {last_block[511 : 496], 8'h80, 432'h0, msg_len};
        02: gen_padded_last_block = {last_block[511 : 488], 8'h80, 424'h0, msg_len};
        03: gen_padded_last_block = {last_block[511 : 480], 8'h80, 416'h0, msg_len};
        04: gen_padded_last_block = {last_block[511 : 472], 8'h80, 408'h0, msg_len};
        05: gen_padded_last_block = {last_block[511 : 464], 8'h80, 400'h0, msg_len};
        06: gen_padded_last_block = {last_block[511 : 456], 8'h80, 392'h0, msg_len};
        07: gen_padded_last_block = {last_block[511 : 448], 8'h80, 384'h0, msg_len};
        08: gen_padded_last_block = {last_block[511 : 440], 8'h80, 376'h0, msg_len};
        09: gen_padded_last_block = {last_block[511 : 432], 8'h80, 368'h0, msg_len};
        10: gen_padded_last_block = {last_block[511 : 424], 8'h80, 360'h0, msg_len};
        11: gen_padded_last_block = {last_block[511 : 416], 8'h80, 352'h0, msg_len};
        12: gen_padded_last_block = {last_block[511 : 408], 8'h80, 344'h0, msg_len};
        13: gen_padded_last_block = {last_block[511 : 400], 8'h80, 336'h0, msg_len};
        14: gen_padded_last_block = {last_block[511 : 392], 8'h80, 328'h0, msg_len};
        15: gen_padded_last_block = {last_block[511 : 384], 8'h80, 320'h0, msg_len};
        16: gen_padded_last_block = {last_block[511 : 376], 8'h80, 312'h0, msg_len};
        17: gen_padded_last_block = {last_block[511 : 368], 8'h80, 304'h0, msg_len};
        18: gen_padded_last_block = {last_block[511 : 360], 8'h80, 296'h0, msg_len};
        19: gen_padded_last_block = {last_block[511 : 352], 8'h80, 288'h0, msg_len};
        20: gen_padded_last_block = {last_block[511 : 344], 8'h80, 280'h0, msg_len};
        21: gen_padded_last_block = {last_block[511 : 336], 8'h80, 272'h0, msg_len};
        22: gen_padded_last_block = {last_block[511 : 328], 8'h80, 264'h0, msg_len};
        23: gen_padded_last_block = {last_block[511 : 320], 8'h80, 256'h0, msg_len};
        24: gen_padded_last_block = {last_block[511 : 312], 8'h80, 248'h0, msg_len};
        25: gen_padded_last_block = {last_block[511 : 304], 8'h80, 240'h0, msg_len};
        26: gen_padded_last_block = {last_block[511 : 296], 8'h80, 232'h0, msg_len};
        27: gen_padded_last_block = {last_block[511 : 288], 8'h80, 224'h0, msg_len};
        28: gen_padded_last_block = {last_block[511 : 280], 8'h80, 216'h0, msg_len};
        29: gen_padded_last_block = {last_block[511 : 272], 8'h80, 208'h0, msg_len};
        30: gen_padded_last_block = {last_block[511 : 264], 8'h80, 200'h0, msg_len};
        31: gen_padded_last_block = {last_block[511 : 256], 8'h80, 192'h0, msg_len};
        32: gen_padded_last_block = {last_block[511 : 248], 8'h80, 184'h0, msg_len};
        33: gen_padded_last_block = {last_block[511 : 240], 8'h80, 176'h0, msg_len};
        34: gen_padded_last_block = {last_block[511 : 232], 8'h80, 168'h0, msg_len};
        35: gen_padded_last_block = {last_block[511 : 224], 8'h80, 160'h0, msg_len};
        36: gen_padded_last_block = {last_block[511 : 216], 8'h80, 152'h0, msg_len};
        37: gen_padded_last_block = {last_block[511 : 208], 8'h80, 144'h0, msg_len};
        38: gen_padded_last_block = {last_block[511 : 200], 8'h80, 136'h0, msg_len};
        39: gen_padded_last_block = {last_block[511 : 192], 8'h80, 128'h0, msg_len};
        40: gen_padded_last_block = {last_block[511 : 184], 8'h80, 120'h0, msg_len};
        41: gen_padded_last_block = {last_block[511 : 176], 8'h80, 112'h0, msg_len};
        42: gen_padded_last_block = {last_block[511 : 168], 8'h80, 104'h0, msg_len};
        43: gen_padded_last_block = {last_block[511 : 160], 8'h80, 096'h0, msg_len};
        44: gen_padded_last_block = {last_block[511 : 152], 8'h80, 088'h0, msg_len};
        45: gen_padded_last_block = {last_block[511 : 144], 8'h80, 080'h0, msg_len};
        46: gen_padded_last_block = {last_block[511 : 136], 8'h80, 072'h0, msg_len};
        47: gen_padded_last_block = {last_block[511 : 128], 8'h80, 064'h0, msg_len};
        48: gen_padded_last_block = {last_block[511 : 120], 8'h80, 056'h0, msg_len};
        49: gen_padded_last_block = {last_block[511 : 112], 8'h80, 048'h0, msg_len};
        50: gen_padded_last_block = {last_block[511 : 104], 8'h80, 040'h0, msg_len};
        51: gen_padded_last_block = {last_block[511 : 096], 8'h80, 032'h0, msg_len};
        52: gen_padded_last_block = {last_block[511 : 088], 8'h80, 024'h0, msg_len};
        53: gen_padded_last_block = {last_block[511 : 080], 8'h80, 016'h0, msg_len};
        54: gen_padded_last_block = {last_block[511 : 072], 8'h80, 008'h0, msg_len};
        55: gen_padded_last_block = {last_block[511 : 064], 8'h80, msg_len};
        56: gen_padded_last_block = {last_block[511 : 056], 8'h80, 056'h0};
        57: gen_padded_last_block = {last_block[511 : 048], 8'h80, 048'h0};
        58: gen_padded_last_block = {last_block[511 : 040], 8'h80, 032'h0};
        59: gen_padded_last_block = {last_block[511 : 032], 8'h80, 024'h0};
        60: gen_padded_last_block = {last_block[511 : 024], 8'h80, 016'h0};
        61: gen_padded_last_block = {last_block[511 : 016], 8'h80, 008'h0};
        62: gen_padded_last_block = {last_block[511 : 008], 8'h80};
        default
          begin
            gen_padded_last_block = 512'h0;
          end
      endcase // case (num_final_byte)
    end
  endfunction // gen_padded_last_block


  //----------------------------------------------------------------
  // main()
  //----------------------------------------------------------------
  initial
    begin : main
      $display("Calculate final padding.");

//      last_block = {64{8'h61}};
//      num_msg_blocks = 64'd12000;
//      final_num_bytes = 6'd62;

      // NIST std testvector 'abc'.
//      num_msg_blocks = 64'h0;
//      last_block = {8'h61, 8'h62, 8'h63, {60{8'h0}}};
//      final_num_bytes = 6'd3;

      // An empty final block after a complete block.
      num_msg_blocks = 64'h1;
      last_block = 64'h0;
      final_num_bytes = 6'd0;


      // Calculate total messge length
      msg_len_in_bytes = (num_msg_blocks * 512) + (final_num_bytes * 8);

      $display("Number of blocks in mesaage:    %04d", num_msg_blocks);
      $display("Number of bytes in final block: %02d", final_num_bytes);
      $display("Number of bytes in message:     %08d (0x%08x)", msg_len_in_bytes, msg_len_in_bytes);

      padded_last_block = gen_padded_last_block(last_block, msg_len_in_bytes, final_num_bytes);
      $display("Padded final block:  0x%064x", padded_last_block);

      if (final_num_bytes > 6'd55) begin
        extra_padding_block = {448'h0, msg_len_in_bytes};
        $display("Extra padding block: 0x%064x", extra_padding_block);
      end
    end // main
endmodule // calc_padding

//======================================================================
// EOF calc_padding.v
//======================================================================
