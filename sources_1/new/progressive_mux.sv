
/*
    COMBINADOR DE SECUENCIAS EN TIEMPO DISCRETO - Ricardo Carrero Bardon 28/11/2024

    Se utiliza para combinar dos señales a(n) y b(n), de forma que la transición en el tiempo entre ambas sea suave

    CONSIDERACIONES

     - Datos de entrada:

        data_a => fixdt(1,11,0);
        data_b => fixdt(1,11,0);
        alpha_sequence => fixdt(0,5,4);

    - Datos de salida

        output_data => fixdt(1,15,4);

    - Alpha sequence establece el canal.0.0000 es a, 1.0000 es b. En el medio, se realiza una combinacion de los dos de forma proporcional

    - Los cuatro últimos dígitos de output_data son decimales


*/


module progressive_mux (
    input  wire         reset,
    input  wire         clk,
    input  wire         enable_3M,
    input  wire  [10:0] data_a,
    input  wire  [10:0] data_b,
    input  wire  [ 4:0] alpha_sequence,  // 00000 is a, 10000 is b. Linear combination in the middle
    output logic [14:0] output_data
);

  // Alpha sequence is expected to go from 0 to 1 or from 1 to 0. Last three digits are decimals, so 1 is 01.000 and 0 is 00.000

  logic enable_progression;
  logic enable_progression_delayed;
  logic start_mul;
  logic [10:0] difference;
  logic [10:0] k;
  logic [10:0] t;
  logic [14:0] mult_output;

  always_ff @(posedge clk or negedge reset) begin
    if(!reset) enable_progression_delayed <= 0;
    else begin
        if(enable_3M) begin
            enable_progression_delayed <= enable_progression;
        end
    end

  end

  always_comb begin

    t = data_a;
    k = data_b;

    enable_progression = !alpha_sequence[4] && alpha_sequence != 0; // Sequence is not finished (neither up or down)

    if (enable_progression) begin
      start_mul = enable_3M;
    end else begin
      start_mul = 0;
    end

    difference  = k - t;

    if(enable_progression) begin
        output_data = mult_output + {t, 4'b0000};
    end else begin
        if(alpha_sequence[4]) begin
            output_data = {k, 4'b0000};
        end else begin
            output_data = {t, 4'b0000};
        end
    end

  end

  logic data_ready;

  serial_mul #(
      .N_BITS_A(11),
      .N_BITS_B(6),
      .N_BITS_RESULT(15)
  ) multiplier (
      .reset(reset),
      .clk(clk),
      .a(difference),
      .b({1'b0, alpha_sequence}),  // Add 0 for sign extension
      .start(start_mul),
      .data_ready(data_ready),
      .result(mult_output)
  );





endmodule
