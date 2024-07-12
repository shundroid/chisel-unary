// Generated by CIRCT firtool-1.62.0
module Counter(
  input        clock,
               reset,
  output [2:0] io_out
);

  reg [2:0] c;
  always @(posedge clock) begin
    if (reset)
      c <= 3'h3;
    else
      c <= c + 3'h1;
  end // always @(posedge)
  assign io_out = c;
endmodule

