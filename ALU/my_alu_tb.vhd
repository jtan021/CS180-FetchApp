LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.all;
 
ENTITY my_alu_8bit_tb IS
END my_alu_8bit_tb;
 
ARCHITECTURE behavior OF my_alu_8bit_tb IS 
 
    COMPONENT my_alu
	 generic(
		numbits	: natural	:= 32
	 );
    PORT(
         A : IN  std_logic_vector;
         B : IN  std_logic_vector;
         opcode : IN  std_logic_vector(0 to 2);
         result : OUT  std_logic_vector;
         carryout : OUT  std_logic;
         overflow : OUT  std_logic;
         zero : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(0 to 7) := (others => '0');
   signal B : std_logic_vector(0 to 7) := (others => '0');
   signal opcode : std_logic_vector(0 to 2) := (others => '0');

 	--Outputs
   signal result : std_logic_vector(0 to 7);
   signal carryout : std_logic;
   signal overflow : std_logic;
   signal zero : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_alu generic map(
		numbits => 8
	)
	PORT MAP (
          A => A,
          B => B,
          opcode => opcode,
          result => result,
          carryout => carryout,
          overflow => overflow,
          zero => zero
        );


   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		wait for 10 ns;
		
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing Unsigned Add
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		report "Testing Unsigned Add";
		opcode <= "000";
		
			-- Test 1
			A <= conv_std_logic_vector(2, 8);
			B <= conv_std_logic_vector(2, 8);
			
			wait for 10 ns;
			assert result = conv_std_logic_vector(4, 8) 	report "Test_1: result incorrect" 	severity Warning;
			assert carryout = '0' 								report "Test_1: carryout incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_1: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_1: zero incorrect"		severity Warning;
			
			-- Test 2
			A <= conv_std_logic_vector(0, 8);
			B <= conv_std_logic_vector(0, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(0, 8) 	report "Test_2: result incorrect" 	severity Warning;
			assert carryout = '0' 								report "Test_2: carryout incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_2: overflow incorrect"	severity Warning;
			assert zero = '1'										report "Test_2: zero incorrect"		severity Warning;
					
			-- Test 5
			A <= conv_std_logic_vector(128, 8);
			B <= conv_std_logic_vector(132, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(4, 8) 	report "Test_5: result incorrect" 	severity Warning;
			assert carryout = '1' 								report "Test_5: carryout incorrect"	severity Warning;
			assert overflow = '1' 								report "Test_5: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_5: zero incorrect"		severity Warning;
			
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing Signed add
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		opcode <= "001";
		report "Testing Signed Add";
			-- Test 1
			A <= conv_std_logic_vector(-1, 8);
			B <= conv_std_logic_vector(3, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(2, 8) 	report "Test_1: result incorrect" 	severity Warning;
			assert carryout = '1' 								report "Test_1: carryout incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_1: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_1: zero incorrect"		severity Warning;
			
			-- Test 2
			A <= conv_std_logic_vector(-4, 8);
			B <= conv_std_logic_vector(4, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(0, 8) 	report "Test_2: result incorrect" 	severity Warning;
			assert carryout = '1' 								report "Test_2: carryout incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_2: overflow incorrect"	severity Warning;
			assert zero = '1'										report "Test_2: zero incorrect"		severity Warning;
			
			-- Test 5
			A <= conv_std_logic_vector(-127, 8);
			B <= conv_std_logic_vector(-127, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(2, 8) 	report "Test_5: result incorrect" 	severity Warning;
			assert carryout = '1' 								report "Test_5: carryout incorrect"	severity Warning;
			assert overflow = '1' 								report "Test_5: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_5: zero incorrect"		severity Warning;
		
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing Unsigned Subtract
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		report "Testing Unsigned Subtract";
		opcode <= "010";
		
			-- Test 1
			A <= conv_std_logic_vector(2, 8);
			B <= conv_std_logic_vector(2, 8);
			
			wait for 10 ns;
			assert result = conv_std_logic_vector(0, 8) 	report "Test_1: result incorrect" 	severity Warning;
			assert carryout = '1' 								report "Test_1: carryout incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_1: overflow incorrect"	severity Warning;
			assert zero = '1'										report "Test_1: zero incorrect"		severity Warning;
			
			-- Test 3
			A <= conv_std_logic_vector(64, 8);
			B <= conv_std_logic_vector(128, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(192, 8) report "Test_3: result incorrect" 	severity Warning;
			assert carryout = '0' 								report "Test_3: carryout incorrect"	severity Warning;
			assert overflow = '1' 								report "Test_3: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_3: zero incorrect"		severity Warning;
		
			-- Test 5
			A <= conv_std_logic_vector(128, 8);
			B <= conv_std_logic_vector(192, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(-64, 8) 	report "Test_5: result incorrect" 	severity Warning;
			assert carryout = '0' 								report "Test_5: carryout incorrect"	severity Warning;
			assert overflow = '1' 								report "Test_5: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_5: zero incorrect"		severity Warning;
		
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing Signed Subtract
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		opcode <= "011";
		report "Testing Signed Subtract";
			-- Test 1
			A <= conv_std_logic_vector(-1, 8);
			B <= conv_std_logic_vector(63, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(-64, 8)	report "Test_1: result incorrect" 	severity Warning;
			assert carryout = '1' 								report "Test_1: carryout incorrect"	severity Warning;
			assert overflow = '0' 								report "Test_1: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_1: zero incorrect"		severity Warning;
			
			-- Test 4
			A <= conv_std_logic_vector(-127, 8);
			B <= conv_std_logic_vector(127, 8);

			wait for 10 ns;
			assert result = conv_std_logic_vector(2, 8)	report "Test_4: result incorrect" 	severity Warning;
			assert carryout = '1' 								report "Test_4: carryout incorrect"	severity Warning;
			assert overflow = '1' 								report "Test_4: overflow incorrect"	severity Warning;
			assert zero = '0'										report "Test_4: zero incorrect"		severity Warning;
      
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing And
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		opcode <= "100";
		report "Testing And";	
			-- Test 4
			A <= "10101010";
			B <= "10101010";
			
			wait for 10 ns;
			assert result = "10101010"	report "Test_4: result incorrect"	severity Warning;
			
			-- Test 5
			A <= "11111111";
			B <= "11111111";
			
			wait for 10 ns;
			assert result = "11111111"	report "Test_5: result incorrect"	severity Warning;
		
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing OR
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		opcode <= "101";
		report "Testing OR";
			-- Test 1
			A <= "00000000";
			B <= "11111111";
			
			wait for 10 ns;
			assert result = "11111111"	report "Test_1: result incorrect"	severity Warning;
			
			-- Test 2
			A <= "00000000";
			B <= "00000000";
			
			wait for 10 ns;
			assert result = "00000000"	report "Test_2: result incorrect"	severity Warning;
			
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing XOR
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		opcode <= "110";
		report "Testing XOR";
			
			-- Test 3
			A <= "01010101";
			B <= "10101010";
			
			wait for 10 ns;
			assert result = "11111111"	report "Test_3: result incorrect"	severity Warning;
			
			-- Test 4
			A <= "10101010";
			B <= "10101010";
			
			wait for 10 ns;
			assert result = "00000000"	report "Test_4: result incorrect"	severity Warning;
			
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		-- Testing Divide by 2
		-- --------------------------------------------------------------------------------
		-- --------------------------------------------------------------------------------
		opcode <= "111";
		report "Testing Divide by 2";
			
			-- Test 2
			A <= conv_std_logic_vector(4, 8);
			
			wait for 10 ns;
			assert result = conv_std_logic_vector(2, 8)	report "Test_2: result incorrect"	severity Warning;
			
			-- Test 3
			A <= conv_std_logic_vector(5, 8);
			
			wait for 10 ns;
			assert result = conv_std_logic_vector(2, 8)	report "Test_3: result incorrect"	severity Warning;
			
		wait;
   end process;

END;
