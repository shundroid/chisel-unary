// Generated by CIRCT firtool-1.62.0
module uBaseline(
  input        clock,
               reset,
  input  [9:0] io_in,
  output [9:0] io_out
);

  assign io_out = {io_in[8:0] * 9'hC6, 1'h0};
endmodule
