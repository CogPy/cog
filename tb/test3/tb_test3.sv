class abSources;
  rand int Ain, Bin;
  int seed = $time;
  
  constraint common { Ain <= 10; Ain > 0; }
  
  task inc();
     begin
  	 Ain = ABS($random(seed) % 2**4);
  	 Bin = ABS($random(seed) % 2**4);
     end;
  endtask; // inc
  
  task print();
     begin
  	 $write("A: %2d; B: %2d\n", Ain, Bin);
     end;
  endtask; // print
  
  function int ABS (int num);
     ABS = (num <0) ? -num : num;
  endfunction // ABS
endclass; // abSources

interface dutif (input Clock);
   logic Clear = 0;
   logic [3:0] Ain = 0, Bin = 0;
   logic [4:0] ABout;

   wire [4:0] ABL;
   assign ABL = ABout;

   default clocking cb @(posedge Clock);
      default input #1ns output #1ns;
      output Ain, Bin, Clear;
      input ABout;
   endclocking // cb

   modport tb ( input Clock, clocking cb);
endinterface // dutif


module DUTSV(dutif iface);
   test1 i_DUT (.Clk(iface.Clock), .Clr(iface.Clear), .Test1_A(iface.Ain), .Test1_B(iface.Bin), .Test1_AB(iface.ABout));
endmodule // DUTSV

module tb_test3;
   timeunit 1ns;
   reg Clock;
      
   dutif iface(Clock);

   DUTSV DUT(iface);
   tb_mod TB(iface);
      
   always
     begin : std_clock
	#5 Clock = 1;
	#5 Clock = 0;
     end
endmodule // top
   

   
module tb_mod(dutif.tb iface);

program test_test1;
   default clocking cbl @(posedge(iface.Clock));
   endclocking // cbl
      
   abSources absrc;

   initial begin
      absrc = new;

      ##10 ;
      iface.cb.Clear <= 1;
      ##100;
      iface.cb.Clear <= 0;

      iface.cb.Ain <= 2;
      ##1;
      @(iface.cb) assert (iface.cb.ABout == 5'h2);

      // Wait three clock cycles
      ##3;

      $display("Start loop");

      for (int i = 0; i < 3; i++) begin
	 // Missing licence for randomize()
	 //absrc.randomize();
	 @(cbl) absrc.inc();
	 //absrc.print();
	 iface.cb.Ain <= absrc.Ain;
	 iface.cb.Bin <= absrc.Bin;
	 fork
	    assertABio(absrc.Ain, absrc.Bin);
	 join_none;
      end;

      #100;
   end // initial begin


   task automatic assertABio(input int a, b);
      int al, bl;
      begin
	 al = a;
	 bl = b;
	 ##1
	 @(iface.cb) assert (iface.cb.ABout == (al + bl)) begin
	    $display("Good A: %2d; B: %2d; ABout: %2d; (B: %2d)\n", al, bl, iface.cb.ABout, iface.cb.Bin);
	 end else begin
	    $error("Bad A: %2d; B: %2d; ABout: %2d; (B: %2d)\n", al, bl, iface.cb.ABout, iface.cb.Bin);
	 end
      end;
   endtask; // assertABio

endprogram // test_test1

endmodule // TB_test1
