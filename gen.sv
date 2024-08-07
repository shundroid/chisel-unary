// Generated by CIRCT firtool-1.62.0
module LSZ(
  input  [7:0] io_in,
  output [2:0] io_lszIdx
);

  assign io_lszIdx =
    io_in[0]
      ? (io_in[1]
           ? (io_in[2]
                ? (io_in[3]
                     ? (io_in[4] ? (io_in[5] ? {2'h3, io_in[6]} : 3'h5) : 3'h4)
                     : 3'h3)
                : 3'h2)
           : 3'h1)
      : 3'h0;
endmodule

module SobolRNG(
  input        clock,
               reset,
               io_en,
  input  [2:0] io_vecIdx,
  output [7:0] io_out
);

  reg [7:0] reg_0;
  always @(posedge clock) begin
    if (reset)
      reg_0 <= 8'h0;
    else begin
      automatic logic [7:0][7:0] _GEN =
        '{8'h1, 8'h2, 8'h4, 8'h8, 8'h10, 8'h20, 8'h40, 8'h80};
      reg_0 <= {8{io_en}} & _GEN[io_vecIdx] ^ reg_0;
    end
  end // always @(posedge)
  assign io_out = reg_0;
endmodule

module SobolRNGDim1(
  input        clock,
               reset,
               io_en,
  output [7:0] io_sobolSeq
);

  wire [2:0] _lsz_io_lszIdx;
  reg  [7:0] cnt;
  always @(posedge clock) begin
    if (reset)
      cnt <= 8'h0;
    else if (io_en)
      cnt <= cnt + 8'h1;
  end // always @(posedge)
  LSZ lsz (
    .io_in     (cnt),
    .io_lszIdx (_lsz_io_lszIdx)
  );
  SobolRNG sobolRNG (
    .clock     (clock),
    .reset     (reset),
    .io_en     (io_en),
    .io_vecIdx (_lsz_io_lszIdx),
    .io_out    (io_sobolSeq)
  );
endmodule

module SobolRNGDim1_10(
  input        clock,
               reset,
               io_en,
  input  [7:0] io_threshold,
  output       io_value
);

  wire [7:0] _rng_io_sobolSeq;
  reg  [1:0] cnt;
  always @(posedge clock) begin
    if (reset)
      cnt <= 2'h0;
    else if (io_en)
      cnt <= cnt + 2'h1;
  end // always @(posedge)
  SobolRNGDim1 rng (
    .clock       (clock),
    .reset       (reset),
    .io_en       ((&cnt) & io_en),
    .io_sobolSeq (_rng_io_sobolSeq)
  );
  assign io_value = (&cnt) & _rng_io_sobolSeq > io_threshold;
endmodule

module uMUL_10(
  input  clock,
         reset,
         io_iA,
  output io_oC
);

  wire       _rnd_io_value;
  reg  [7:0] iBBuf;
  always @(posedge clock) begin
    if (reset)
      iBBuf <= 8'h0;
    else
      iBBuf <= 8'h9D;
  end // always @(posedge)
  SobolRNGDim1_10 rnd (
    .clock        (clock),
    .reset        (reset),
    .io_en        (io_iA),
    .io_threshold (iBBuf),
    .io_value     (_rnd_io_value)
  );
  assign io_oC = io_iA & _rnd_io_value;
endmodule

module uSADD(
  input        clock,
               reset,
  input  [1:0] io_in,
  output       io_out
);

  reg        acc;
  wire [1:0] _accNext_T = {1'h0, acc} + {1'h0, io_in[0]} + {1'h0, io_in[1]};
  always @(posedge clock) begin
    if (reset)
      acc <= 1'h0;
    else
      acc <= _accNext_T[0];
  end // always @(posedge)
  assign io_out = _accNext_T[1];
endmodule

module uMUL_1_256(
  input  clock,
         reset,
         io_iA,
  output io_oC
);

  reg [7:0] cnt;
  always @(posedge clock) begin
    if (reset)
      cnt <= 8'h0;
    else if (io_iA)
      cnt <= cnt + 8'h1;
  end // always @(posedge)
  assign io_oC = io_iA & (&cnt);
endmodule

module uTestCircuit(
  input  clock,
         reset,
         io_in,
  output io_out
);

  wire _add1_io_out;
  wire _rng_io_value;
  wire _mul1_io_oC;
  uMUL_10 mul1 (
    .clock (clock),
    .reset (reset),
    .io_iA (io_in),
    .io_oC (_mul1_io_oC)
  );
  SobolRNGDim1_10 rng (
    .clock        (clock),
    .reset        (reset),
    .io_en        (1'h1),
    .io_threshold (8'hFD),
    .io_value     (_rng_io_value)
  );
  uSADD add1 (
    .clock  (clock),
    .reset  (reset),
    .io_in  ({_rng_io_value, _mul1_io_oC}),
    .io_out (_add1_io_out)
  );
  uMUL_1_256 mul2 (
    .clock (clock),
    .reset (reset),
    .io_iA (_add1_io_out),
    .io_oC (io_out)
  );
endmodule

module uTestCircuitRepeat(
  input  clock,
         reset,
         io_in,
  output io_out
);

  uTestCircuit baseline (
    .clock  (clock),
    .reset  (reset),
    .io_in  (io_in),
    .io_out (io_out)
  );
endmodule

