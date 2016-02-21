--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:49:12 02/02/2016
-- Design Name:   
-- Module Name:   /home/csmajs/msaxe001/Desktop/my_alu/my_alu_tb.vhd
-- Project Name:  my_alu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: my_alu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY my_alu_tb IS
END my_alu_tb;
 
ARCHITECTURE behavior OF my_alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_alu
		generic (NUMBITS: natural := 32);
    PORT(
         A : IN  std_logic_vector(NUMBITS-1 downto 0);
         B : IN  std_logic_vector(NUMBITS-1 downto 0);
         Opcode : IN  std_logic_vector(3 downto 0);
         Result : OUT  std_logic_vector(NUMBITS+3 downto 0);
         Carry_out : OUT  std_logic;
         Overflow : OUT  std_logic;
         Zero : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(0 to 31) := (others => '0');
   signal B : std_logic_vector(0 to 31) := (others => '0');
   signal Opcode : std_logic_vector(0 to 3) := (others => '0');

 	--Outputs
   signal Result : std_logic_vector(0 to 35) := (others => '0');
   signal Carry_out : std_logic := '0';
   signal Overflow : std_logic := '0';
   signal Zero : std_logic := '0';

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_alu generic map(
						NUMBITS => 32
		)
		PORT MAP (
          A => A, 
          B => B,
          Opcode => Opcode,
          Result => Result,
          Carry_out => Carry_out,
          Overflow => Overflow,
          Zero => Zero
        );

   -- Stimulus process
	stim_proc: process
   begin		
      -- hold reset state for 100ms.
		wait for 10 ns;
		
		--------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing Unsigned Add
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		report "Testing Unsigned Add";
		opcode <= "1000";
		
			-- Test 1
			A <= x"00000042";
			B <= x"00000042";
			
			wait for 10 ns;
			assert result = x"000000084"					 	report "Test_1: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_1: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_1: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_1: zero incorrect"		severity Warning;
			
			-- Test 2
			A <= x"00000000";
			B <= x"00000000";

			wait for 10 ns;
			assert result = x"000000000"    				 	report "Test_2: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_2: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_2: overflow incorrect"	severity Warning;
			assert zero = '1'										report "Test_2: zero incorrect"		severity Warning;
					
			-- Test 5
			A <= x"99999999";
			B <= x"99999999";
			wait for 10 ns;
			assert result = x"199999998" 						report "Test_5: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_5: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_5: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_5: zero incorrect"		severity Warning;
			
--		-- --------------------------------------------------------------------------------
--		-- --------------------------------------------------------------------------------
--		-- Testing Signed add
--		-- --------------------------------------------------------------------------------
--		-- --------------------------------------------------------------------------------
		opcode <= "1100";
		report "Testing Signed Add";
			-- Test 1
			A <= x"10000001";
			B <= x"00000003";

			wait for 10 ns;
			assert result = x"000000002"					 	report "Test_1: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_1: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_1: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_1: zero incorrect"		severity Warning;
			
			-- Test 2
			A <= x"10000004";
			B <= x"00000004";

			wait for 10 ns;
			assert result = x"000000000"					 	report "Test_2: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_2: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_2: overflow incorrect"	severity Warning;
			assert zero = '1'										report "Test_2: zero incorrect"		severity Warning;
			
			-- Test 5
			A <= x"10000127";
			B <= x"10000127";

			wait for 10 ns;
			assert result = x"100000254"					 	report "Test_5: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_5: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_5: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_5: zero incorrect"		severity Warning;
		
--		-- --------------------------------------------------------------------------------
--		-- --------------------------------------------------------------------------------
--		-- Testing Unsigned Subtract
--		-- --------------------------------------------------------------------------------
--		-- --------------------------------------------------------------------------------
		report "Testing Unsigned Subtract";
		opcode <= "1001";
		
			-- Test 1
			A <= x"00000002";
			B <= x"00000002";
			
			wait for 10 ns;
			assert result = x"000000000"					 	report "Test_1: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_1: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_1: overflow incorrect"	severity Warning;
			assert zero = '1'										report "Test_1: zero incorrect"		severity Warning;
			
			-- Test 3
			A <= x"00000064";
			B <= x"00000128";

			wait for 10 ns;
			--assert result = x"00000064"						report "Test_3: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_3: Carry_out incorrect"	severity Warning;
			assert overflow = '1' 								report "Test_3: overflow incorrect"	severity Warning;
			if(overflow = '1') then
				report "Test_3: Result is corrupted because of overflow";
			end if;
			assert zero = '0'										report "Test_3: zero incorrect"		severity Warning;
		
			-- Test 5
			A <= x"00000192";
			B <= x"00000128";

			wait for 10 ns;
			assert result = x"00000064"					 	report "Test_5: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_5: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_5: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_5: zero incorrect"		severity Warning;
		
--		-- --------------------------------------------------------------------------------
--		-- --------------------------------------------------------------------------------
--		-- Testing Signed Subtract
--		-- --------------------------------------------------------------------------------
--		-- --------------------------------------------------------------------------------
		opcode <= "1101";
		report "Testing Signed Subtract";
			-- Test 1
			A <= x"10000036";
			B <= x"00000063";

			wait for 10 ns;
			assert result = x"100000099"						report "Test_1: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_1: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_1: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_1: zero incorrect"		severity Warning;
			
			-- Test 4
			A <= x"10000127";
			B <= x"00000127";

			wait for 10 ns;
			assert result = x"100000254"						report "Test_4: result incorrect" 	severity Warning;
			assert Carry_out = '0' 								report "Test_4: Carry_out incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_4: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_4: zero incorrect"		severity Warning;
      wait;
   end process;

END;
