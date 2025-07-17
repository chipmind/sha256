//======================================================================
//
// sha256_final_padding.v
// ----------------------
// Implementation of SHA-256 final padding according to
// NIST FIPS 180-4. By and large a combinational module with some
// muxes and a FSM.
//
// Assumptions:
// - The final block contain at most 63 bytes.
// - The final block is zero padded.
//
//
// Author: Joachim Strömbergson
// Copyright (c) 2024,  Asssured AB
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
//
//======================================================================

module sha256_final_padding(
			    input wire            clk,
			    input wire            reset_n,

			    input wire            init_in,
			    input wire            next_in,
			    input wire            final_in,
			    input wire [5 : 0]    final_len,
			    input wire [511 : 0]  block_in,

			    input wire            core_ready,

			    output wire           init_out,
			    output wire           next_out,
			    output wire           ready_out,
			    output wire [511 : 0] block_out
			   );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam CTRL_IDLE        = 3'h0;
  localparam CTRL_FINAL_BLOCK = 3'h1;
  localparam CTRL_WAIT_FINAL  = 3'h2;
  localparam CTRL_EXTRA_BLOCK = 3'h3;
  localparam CTRL_WAIT_EXTRA  = 3'h4;

  localparam NEXT_BLOCK  = 2'h0;
  localparam FINAL_BLOCK = 2'h1;
  localparam EXTRA_BLOCK = 2'h2;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [511 : 0] block_reg;
  reg           block_we;

  reg [5 : 0]   final_len_reg;
  reg           final_len_we;

  reg           ready_out_new;
  reg           ready_out_reg;

  reg [63 : 0]  bit_ctr_reg;
  reg [63 : 0]  bit_ctr_new;
  reg           bit_ctr_rst;
  reg           bit_ctr_next;
  reg           bit_ctr_final;
  reg           bit_ctr_we;

  reg           init_in_reg;
  reg           next_in_reg;
  reg           final_in_reg;
  reg           core_ready_reg;

  reg [2 : 0]   sha256_final_padding_ctrl_reg;
  reg [2 : 0]   sha256_final_padding_ctrl_new;
  reg           sha256_final_padding_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [511 : 0] final_block;
  reg [511 : 0] extra_block;
  reg [511 : 0] tmp_block_out;
  reg           tmp_next_out;
  reg [1 : 0]   block_out_mux_ctrl;

  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign init_out  = init_in_reg;
  assign next_out  = tmp_next_out;
  assign ready_out = ready_out_reg;
  assign block_out = tmp_block_out;


  //----------------------------------------------------------------
  //
  //----------------------------------------------------------------
  function automatic [511 : 0] gen_padded_block(
                                               input [511 : 0] msg_block,
                                               input [63 : 0] msg_len,
                                               input [5 : 0] num_bytes
                                               );
    begin
      case(num_bytes)
        00: gen_padded_block = {8'h80, 440'h0, msg_len};
        01: gen_padded_block = {msg_block[511 : 504], 8'h80, 432'h0, msg_len};
        02: gen_padded_block = {msg_block[511 : 496], 8'h80, 424'h0, msg_len};
        03: gen_padded_block = {msg_block[511 : 488], 8'h80, 416'h0, msg_len};
        04: gen_padded_block = {msg_block[511 : 480], 8'h80, 408'h0, msg_len};
        05: gen_padded_block = {msg_block[511 : 472], 8'h80, 400'h0, msg_len};
        06: gen_padded_block = {msg_block[511 : 464], 8'h80, 392'h0, msg_len};
        07: gen_padded_block = {msg_block[511 : 456], 8'h80, 384'h0, msg_len};
        08: gen_padded_block = {msg_block[511 : 448], 8'h80, 376'h0, msg_len};
        09: gen_padded_block = {msg_block[511 : 440], 8'h80, 368'h0, msg_len};
        10: gen_padded_block = {msg_block[511 : 432], 8'h80, 360'h0, msg_len};
        11: gen_padded_block = {msg_block[511 : 424], 8'h80, 352'h0, msg_len};
        12: gen_padded_block = {msg_block[511 : 416], 8'h80, 344'h0, msg_len};
        13: gen_padded_block = {msg_block[511 : 408], 8'h80, 336'h0, msg_len};
        14: gen_padded_block = {msg_block[511 : 400], 8'h80, 328'h0, msg_len};
        15: gen_padded_block = {msg_block[511 : 392], 8'h80, 320'h0, msg_len};
        16: gen_padded_block = {msg_block[511 : 384], 8'h80, 312'h0, msg_len};
        17: gen_padded_block = {msg_block[511 : 376], 8'h80, 304'h0, msg_len};
        18: gen_padded_block = {msg_block[511 : 368], 8'h80, 296'h0, msg_len};
        19: gen_padded_block = {msg_block[511 : 360], 8'h80, 288'h0, msg_len};
        20: gen_padded_block = {msg_block[511 : 352], 8'h80, 280'h0, msg_len};
        21: gen_padded_block = {msg_block[511 : 344], 8'h80, 272'h0, msg_len};
        22: gen_padded_block = {msg_block[511 : 336], 8'h80, 264'h0, msg_len};
        23: gen_padded_block = {msg_block[511 : 328], 8'h80, 256'h0, msg_len};
        24: gen_padded_block = {msg_block[511 : 320], 8'h80, 248'h0, msg_len};
        25: gen_padded_block = {msg_block[511 : 312], 8'h80, 240'h0, msg_len};
        26: gen_padded_block = {msg_block[511 : 304], 8'h80, 232'h0, msg_len};
        27: gen_padded_block = {msg_block[511 : 296], 8'h80, 224'h0, msg_len};
        28: gen_padded_block = {msg_block[511 : 288], 8'h80, 216'h0, msg_len};
        29: gen_padded_block = {msg_block[511 : 280], 8'h80, 208'h0, msg_len};
        30: gen_padded_block = {msg_block[511 : 272], 8'h80, 200'h0, msg_len};
        31: gen_padded_block = {msg_block[511 : 264], 8'h80, 192'h0, msg_len};
        32: gen_padded_block = {msg_block[511 : 256], 8'h80, 184'h0, msg_len};
        33: gen_padded_block = {msg_block[511 : 248], 8'h80, 176'h0, msg_len};
        34: gen_padded_block = {msg_block[511 : 240], 8'h80, 168'h0, msg_len};
        35: gen_padded_block = {msg_block[511 : 232], 8'h80, 160'h0, msg_len};
        36: gen_padded_block = {msg_block[511 : 224], 8'h80, 152'h0, msg_len};
        37: gen_padded_block = {msg_block[511 : 216], 8'h80, 144'h0, msg_len};
        38: gen_padded_block = {msg_block[511 : 208], 8'h80, 136'h0, msg_len};
        39: gen_padded_block = {msg_block[511 : 200], 8'h80, 128'h0, msg_len};
        40: gen_padded_block = {msg_block[511 : 192], 8'h80, 120'h0, msg_len};
        41: gen_padded_block = {msg_block[511 : 184], 8'h80, 112'h0, msg_len};
        42: gen_padded_block = {msg_block[511 : 176], 8'h80, 104'h0, msg_len};
        43: gen_padded_block = {msg_block[511 : 168], 8'h80, 096'h0, msg_len};
        44: gen_padded_block = {msg_block[511 : 160], 8'h80, 088'h0, msg_len};
        45: gen_padded_block = {msg_block[511 : 152], 8'h80, 080'h0, msg_len};
        46: gen_padded_block = {msg_block[511 : 144], 8'h80, 072'h0, msg_len};
        47: gen_padded_block = {msg_block[511 : 136], 8'h80, 064'h0, msg_len};
        48: gen_padded_block = {msg_block[511 : 128], 8'h80, 056'h0, msg_len};
        49: gen_padded_block = {msg_block[511 : 120], 8'h80, 048'h0, msg_len};
        50: gen_padded_block = {msg_block[511 : 112], 8'h80, 040'h0, msg_len};
        51: gen_padded_block = {msg_block[511 : 104], 8'h80, 032'h0, msg_len};
        52: gen_padded_block = {msg_block[511 : 096], 8'h80, 024'h0, msg_len};
        53: gen_padded_block = {msg_block[511 : 088], 8'h80, 016'h0, msg_len};
        54: gen_padded_block = {msg_block[511 : 080], 8'h80, 008'h0, msg_len};
        55: gen_padded_block = {msg_block[511 : 072], 8'h80, msg_len};
        56: gen_padded_block = {msg_block[511 : 064], 8'h80, 056'h0};
        57: gen_padded_block = {msg_block[511 : 056], 8'h80, 048'h0};
        58: gen_padded_block = {msg_block[511 : 048], 8'h80, 040'h0};
        59: gen_padded_block = {msg_block[511 : 040], 8'h80, 032'h0};
        60: gen_padded_block = {msg_block[511 : 032], 8'h80, 024'h0};
        61: gen_padded_block = {msg_block[511 : 024], 8'h80, 016'h0};
        62: gen_padded_block = {msg_block[511 : 016], 8'h80, 008'h0};
        63: gen_padded_block = {msg_block[511 : 008], 8'h80};
        default
          begin
            gen_padded_block = 512'h0;
          end
      endcase // case (num_bytes)
    end
  endfunction // gen_padded_block


  //----------------------------------------------------------------
  // reg_update
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin : reg_update
      if (!reset_n) begin
	    block_reg                     <= 512'h0;
        ready_out_reg                 <= 1'h0;
	    final_len_reg                 <= 6'h0;
	    bit_ctr_reg                   <= 64'h0;
        init_in_reg                   <= 1'h0;
        next_in_reg                   <= 1'h0;
        final_in_reg                  <= 1'h0;
        core_ready_reg                <= 1'h0;
	    sha256_final_padding_ctrl_reg <= CTRL_IDLE;
      end

      else begin
        ready_out_reg  <= ready_out_new;
        core_ready_reg <= core_ready;
        init_in_reg    <= init_in;
        next_in_reg    <= next_in;
        final_in_reg   <= final_in;

	    if (block_we) begin
	      block_reg <= block_in;
	    end

	    if (final_len_we) begin
	      final_len_reg <= final_len;
	    end

	    if (bit_ctr_we) begin
	      bit_ctr_reg <= bit_ctr_new;
	    end

	    if (sha256_final_padding_ctrl_we) begin
	      sha256_final_padding_ctrl_reg <= sha256_final_padding_ctrl_new;
	    end
      end // reg_update
    end


  //----------------------------------------------------------------
  // block_out_mux
  //----------------------------------------------------------------
  always @*
    begin : block_out_mux
      final_block = gen_padded_block(block_reg, bit_ctr_reg, final_len_reg);
      extra_block = {448'h0, bit_ctr_reg};

      case (block_out_mux_ctrl)
        NEXT_BLOCK :  tmp_block_out = block_in;
        FINAL_BLOCK : tmp_block_out = final_block;
        EXTRA_BLOCK : tmp_block_out = extra_block;
        default begin
          tmp_block_out = 512'h0;
        end
      endcase // case (block_out_mux_ctrl)
    end


  //----------------------------------------------------------------
  // bit_ctr
  //----------------------------------------------------------------
  always @*
    begin : bit_ctr
      bit_ctr_new = 64'h0;
      bit_ctr_we  = 1'h0;

      if (bit_ctr_rst) begin
	    bit_ctr_new = 64'h0;
 	    bit_ctr_we  = 1'h1;
      end

      if (bit_ctr_next) begin
	    bit_ctr_new = bit_ctr_reg + {55'h0, 9'h100};
 	    bit_ctr_we  = 1'h1;
      end

      if (bit_ctr_final) begin
	    bit_ctr_new = bit_ctr_reg + {55'h0, final_len, 3'h0};
 	    bit_ctr_we  = 1'h1;
      end
    end


  //----------------------------------------------------------------
  // sha256_final_padding_ctrl
  // Yes, mix of data and control path.
  //----------------------------------------------------------------
  always @*
    begin : sha256_final_padding_ctrl
      final_len_we                  = 1'h0;
      bit_ctr_rst                   = 1'h0;
      bit_ctr_next                  = 1'h0;
      bit_ctr_final                 = 1'h0;
      tmp_next_out                  = next_in_reg;
      ready_out_new                 = core_ready_reg;
      block_we                      = 1'h0;
      block_out_mux_ctrl            = NEXT_BLOCK;
      sha256_final_padding_ctrl_new = CTRL_IDLE;
      sha256_final_padding_ctrl_we  = 1'h0;

      case (sha256_final_padding_ctrl_reg)
	    CTRL_IDLE: begin
	      ready_out_new = core_ready_reg;
	      if (init_in_reg) begin
	        bit_ctr_rst = 1'h1;
	      end

	      if (next_in_reg) begin
	        ready_out_new      = core_ready_reg;
            block_out_mux_ctrl = NEXT_BLOCK;
            bit_ctr_next       = 1'h1;
	      end

	      if (final_in_reg) begin
	        tmp_next_out                  = 1'h0;
	        ready_out_new                 = 1'h0;
	        final_len_we                  = 1'h1;
            block_out_mux_ctrl            = FINAL_BLOCK;
	        block_we                      = 1'h1;
            bit_ctr_final                 = 1'h1;
	        sha256_final_padding_ctrl_new = CTRL_FINAL_BLOCK;
	        sha256_final_padding_ctrl_we  = 1'h1;
	      end
	    end

	    CTRL_FINAL_BLOCK: begin
          block_out_mux_ctrl = FINAL_BLOCK;
	      tmp_next_out       = 1'h1;
	      ready_out_new      = 1'h0;

          if (!core_ready_reg) begin
            // Do we need an extra block?
	        if (final_len_reg > 6'd55) begin
	          sha256_final_padding_ctrl_new = CTRL_EXTRA_BLOCK;
	          sha256_final_padding_ctrl_we  = 1'h1;
	        end
            else begin
	          sha256_final_padding_ctrl_new = CTRL_WAIT_FINAL;
	          sha256_final_padding_ctrl_we  = 1'h1;
            end
          end
        end

	    CTRL_WAIT_FINAL: begin
          block_out_mux_ctrl = FINAL_BLOCK;
	      ready_out_new      = 1'h0;
	      if (core_ready_reg) begin
	        sha256_final_padding_ctrl_new = CTRL_IDLE;
	        sha256_final_padding_ctrl_we  = 1'h1;
	      end
	    end

	    CTRL_EXTRA_BLOCK: begin
          block_out_mux_ctrl = EXTRA_BLOCK;
	      ready_out_new      = 1'h0;

	      if (core_ready_reg) begin
	        tmp_next_out                  = 1'h1;
	        sha256_final_padding_ctrl_new = CTRL_WAIT_EXTRA;
	        sha256_final_padding_ctrl_we  = 1'h1;
	      end
        end

	    CTRL_WAIT_EXTRA: begin
          block_out_mux_ctrl = EXTRA_BLOCK;
	      ready_out_new      = 1'h0;
	      if (core_ready_reg) begin
	        sha256_final_padding_ctrl_new = CTRL_IDLE;
	        sha256_final_padding_ctrl_we  = 1'h1;
	      end
	    end

	    default:
	      begin
	      end
      endcase // case (sha26_padding_ctrl_reg)
    end

endmodule // sha256_final_padding

//======================================================================
// EOF sha256_final_padding.v
//======================================================================
