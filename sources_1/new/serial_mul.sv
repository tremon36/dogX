`timescale 1ns / 1ps

/*
    MULTIPLICADOR EN SERIE PARA NUMEROS DE N BITS CON SIGNO EN CA2 - Ricardo Carrero Bardon 27/11/2024

    CONSIDERACIONES

     - N_BITS_RESULT debe ser igual o mayor que N_BITS_A y N_BITS_B
     - La latencia máxima es tantos ciclos de reloj como bits tenga el resultado (por ejemplo, para 8 bits, contando la señal de start, se tardan 8 ciclos en producir el resultado)
     - Se puede leer un resultado a la vez que se asignan las entradas y start (maximo throughput)
     - Utilzar numeros con más 0s delante en el operando A para aumentar throughput
     - El multiplicador funciona siempre que no haya overflow en la salida (para 8 bits de resultado, resultados mayores que 128 o menores que -128 seran erróneos)

*/

module serial_mul #(
    parameter int N_BITS_A = 8,
    parameter int N_BITS_B = 8,
    parameter int N_BITS_RESULT = 8
) (
    input wire reset,
    input wire clk,
    input wire [N_BITS_A-1:0] a,
    input wire [N_BITS_B-1:0] b,
    input wire start,
    output wire data_ready,
    output wire [N_BITS_RESULT-1:0] result
);

  logic [N_BITS_RESULT-1:0] result_i;
  logic [N_BITS_RESULT-1:0] a_shifter;
  logic [N_BITS_B-1:0] b_shifter;

  logic [N_BITS_RESULT-1:0] a_extended; // These variables are sign-extended versions of the input, to match the result size


  assign a_extended = {{(N_BITS_RESULT - N_BITS_A) {a[N_BITS_A-1]}}, a[N_BITS_A-1:0]};


  logic running;
  logic data_ready_i;
  assign data_ready = data_ready_i;
  assign result = result_i;


  always_ff @(posedge clk or negedge reset) begin

    if (!reset) begin
      a_shifter <= 0;
      b_shifter <= 0;
      result_i  <= 0;
    end else begin

      if (running) begin

        a_shifter[N_BITS_RESULT-1:0] <= {a_shifter[N_BITS_RESULT-2:0], 1'b0};
        b_shifter[N_BITS_B-1:0] <= {b_shifter[N_BITS_B-1], b_shifter[N_BITS_B-1:1]};

        if (b_shifter[0]) result_i <= result_i + a_shifter[N_BITS_RESULT-1:0];

      end else begin

        if (start) begin

          a_shifter[N_BITS_RESULT-1:0] <= {a_extended[N_BITS_RESULT-2:0], 1'b0};
          b_shifter[N_BITS_B-1:0] <= {b[N_BITS_B-1], b[N_BITS_B-1:1]};

          if (b[0]) result_i <= a_extended;
          else result_i <= 0;
        end

      end
    end
  end


  always_comb begin
    // Algorithm ends when a was completely shifted or b is 0 (no more adding will be performed)
    running = a_shifter != 0 && b_shifter != 0;
    data_ready_i = !running;
  end

endmodule
