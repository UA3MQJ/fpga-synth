module adsr32( clk, GATE, A, D, S, R, sout/*, SEG */);

  output reg [31:0] sout; // This is the accumulator/integrator for attack, decay and release
  input wire clk;         // 50 MHz
  input wire GATE;        // GATE signal
  input wire [31:0] A;    // attack rate
  input wire [31:0] D;    // decay rate
  input wire [31:0] S;    // sustain level
  input wire [31:0] R;    // release rate

  reg [2:0] state;                 // state 0,1,2,3,4,5 - IDLE,ATTACK,DECAY,SUSTAIN,RELEASE
  
  //output [7:0] SEG;
   
  initial begin
	state = 3'b000;
	sout  = 0;
  end
  
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
// This is a state machine of 5 states, IDLE, ATTACK, DECAY, SUSTAIN and RELEASE.

  parameter IDLE    = 3'b000;
  parameter ATTACK  = 3'b001;
  parameter DECAY   = 3'b010;
  parameter SUSTAIN = 3'b011;
  parameter RELEASE = 3'b100;
  
  always @ ( posedge clk )
    begin
  
      case ( state )
  
      IDLE: //ждем
        begin
				// переходим из IDLE в 01 (attack)
				//смена стейта
				state <= ( GATE == 1'b1 ) ? ATTACK : IDLE;
        end

      ATTACK: //атака
        begin      		  
          if ( GATE == 1'b1 ) begin
            if ( (sout + A) <= {1'b0,{32{1'b1}}} ) begin //если не достигли максимума - прибавляем
              sout <= sout + A; // на значение A
            end else begin // иначе переполнение
              sout <= {32{1'b1}}; // ставим максимальное значение
            end
          end
			 
			 //смена стейта
          if ( GATE == 1'b0 ) begin
            state <= RELEASE; // если GATE в ноле, значит переходим в state 4 (release)
          end else begin
			// GATE в единице
            if ( (sout + A) > {1'b0,{32{1'b1}}} ) begin //если не достигли максимума - прибавляем
              state <= DECAY;     // переходим в state 2 (decay)
            end
          end			 
        end
          
      DECAY: //спад
        begin
		  
          if ( GATE == 1'b1 ) begin 
		    //GATE активно? спадаем
			   if ((sout-D) > S) begin
				  sout <= sout - D;
				end else begin
				  sout <= S;
				end  
			 end
			 
          if ( GATE == 1'b1 ) begin
			   if ( sout == S) begin
					state <= SUSTAIN;
				end
			 end else if ( GATE == 1'b0 ) begin
            state <= RELEASE;  
			 end
			 
        end

      SUSTAIN: //в удержании стоим, пока не спал GATE
        begin
          if ( GATE == 1'b0 ) state <= RELEASE;         // Go to state 4, RELEASE
        end
  
      RELEASE:
        begin
		  
          if ( GATE == 1'b0 ) begin //при RELEASE снова нажата GATE - переходим в ATTACK
				if ( sout > R ) begin // если значение больше, то вычитаем
              sout <= (sout - R);
            end else begin //иначе, утухли совсем и перешли в стейт IDLE
              sout <= 0;
            end
          end else if ( GATE == 1'b1 ) begin
				//если в режиме релиза пришел следующий гейт - ИГНОРИМ ХВОСТ
              sout <= 0;
			 end
			 
			 //
          if ( GATE == 1'b1 ) begin
            state <= ATTACK;
          end else begin  ///////
			   if ( sout == 0 ) begin 
              state <= IDLE;
            end
          end
			 
        end
		  
      endcase
	  
  end

  /*
  reg [6:0] SEG_buf;
  always @ (state)
  begin
    case(state)
      3'h0: SEG_buf <= 7'b0111111;
      3'h1: SEG_buf <= 7'b0000110;
      3'h2: SEG_buf <= 7'b1011011;
      3'h3: SEG_buf <= 7'b1001111;
      3'h4: SEG_buf <= 7'b1100110;
      3'h5: SEG_buf <= 7'b1101101;
      3'h6: SEG_buf <= 7'b1111101;
      3'h7: SEG_buf <= 7'b0000111;
      default: SEG_buf <= 7'b0111111;
    endcase
  end 
  
  assign SEG = {1'b0,SEG_buf}; */
  
endmodule
