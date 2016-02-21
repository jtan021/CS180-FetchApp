----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:16:46 01/21/2016 
-- Design Name: 
-- Module Name:    my_alu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_alu is
			generic (NUMBITS: natural := 32);
    Port ( A : in  STD_LOGIC_VECTOR((NUMBITS-1) downto 0);
           B : in  STD_LOGIC_VECTOR((NUMBITS-1) downto 0);
           Opcode : in  STD_LOGIC_VECTOR(3 downto 0);
           Result : out  STD_LOGIC_VECTOR((NUMBITS+3) downto 0);
           Carry_out : out  STD_LOGIC := '0';
           Overflow : out  STD_LOGIC := '0';
           Zero : out  STD_LOGIC := '0');
end my_alu;

architecture Behavioral of my_alu is
-- Signals for..
-- Arithmetic temps
shared variable Res_temp: std_logic_vector(NUMBITS-5 downto 0) := (others => '0');
shared variable Sum_temp: std_logic_vector(NUMBITS-4 downto 0) := (others => '0');
-- BCD to Binary Decoder:
shared variable A_temp : STD_LOGIC_VECTOR(NUMBITS-5 downto 0) := (others => '0');
shared variable B_temp : STD_LOGIC_VECTOR(NUMBITS-5 downto 0) := (others => '0');
shared variable A1 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable A2 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable A3 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable A4 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable A5 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable A6 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable A7 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable A8 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

shared variable B1 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable B2 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable B3 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable B4 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable B5 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable B6 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable B7 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable B8 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
-- Binary to BCD Encoder:
shared variable R1 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable R2 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable R3 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable R4 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable R5 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable R6 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable R7 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable R8 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable R9 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
shared variable flag: integer := 0; -- Unsigned Arithmetic(1), Signed Arithmetic(2)


begin
	process(Opcode,A,B)
	begin
		-- first, Convert BCD to Binary:
		A1 := A(3 downto 0);
		A2 := A(7 downto 4);
		A3 := A(11 downto 8);
		A4 := A(15 downto 12);
		A5 := A(19 downto 16);
		A6 := A(23 downto 20);
		A7 := A(27 downto 24);
		A8 := A(31 downto 28);
		
		B1 := B(3 downto 0);
		B2 := B(7 downto 4);
		B3 := B(11 downto 8);
		B4 := B(15 downto 12);
		B5 := B(19 downto 16);
		B6 := B(23 downto 20);
		B7 := B(27 downto 24);
		B8 := B(31 downto 28);
		
		-- second, handle cases:
		case Opcode is
			when "1000" => -- BCD unsigned add
				-- Original binaries are unsigned
				A_temp := STD_LOGIC_VECTOR( ((unsigned(A8))* "100110001001011010000000") +
											 ((unsigned(A7))* "11110100001001000000") +
											 ((unsigned(A6))* "11000011010100000") +
											 ((unsigned(A5))* "10011100010000") +
											 ((unsigned(A4))* "1111101000") +
											 ((unsigned(A3))* "1100100") + 
											 ((unsigned(A2))* "1010") +
											 ((unsigned(A1))* "01" ));
											 
				B_temp := STD_LOGIC_VECTOR( ((unsigned(B8))* "100110001001011010000000") +
											 ((unsigned(B7))* "11110100001001000000") +
											 ((unsigned(B6))* "11000011010100000") +
											 ((unsigned(B5))* "10011100010000") +
											 ((unsigned(B4))* "1111101000") +
											 ((unsigned(B3))* "1100100") + 
											 ((unsigned(B2))* "1010") +
											 ((unsigned(B1))* "01" ));
											 
				Sum_temp := STD_LOGIC_VECTOR(unsigned('0' & A_temp) + unsigned('0' & B_temp));
				Res_temp := Sum_temp(NUMBITS-5 downto 0);
				Overflow <= '0';
				Carry_out <= '0';
				
				if (unsigned(Res_temp) = 0) then
					zero <= '1';
				else
					zero <= '0';
				end if;
				
				flag := 1;
				
			when "1001" => -- BCD unsigned sub
				-- Original binaries are unsigned
				A_temp := STD_LOGIC_VECTOR( ((unsigned(A8))* "100110001001011010000000") +
											 ((unsigned(A7))* "11110100001001000000") +
											 ((unsigned(A6))* "11000011010100000") +
											 ((unsigned(A5))* "10011100010000") +
											 ((unsigned(A4))* "1111101000") +
											 ((unsigned(A3))* "1100100") + 
											 ((unsigned(A2))* "1010") +
											 ((unsigned(A1))* "01" ));
											 
				B_temp := STD_LOGIC_VECTOR( ((unsigned(B8))* "100110001001011010000000") +
											 ((unsigned(B7))* "11110100001001000000") +
											 ((unsigned(B6))* "11000011010100000") +
											 ((unsigned(B5))* "10011100010000") +
											 ((unsigned(B4))* "1111101000") +
											 ((unsigned(B3))* "1100100") + 
											 ((unsigned(B2))* "1010") +
											 ((unsigned(B1))* "01" ));
											 
				Sum_temp := STD_LOGIC_vector(unsigned('0' & A_temp) + (unsigned('0' & NOT(B_temp)) + 1));
				Res_temp := Sum_temp(NUMBITS-5 downto 0);
				Carry_out <= '0';
				Overflow <= NOT(Sum_temp(NUMBITS-4));
				
				if (unsigned(Res_temp) = 0) then
					zero <= '1';
				else 
					zero <= '0';
				end if;
				
				flag := 1;

			-- For signed arithmetic, must convert current unsigned binary to signed
			when "1100" => -- BCD signed add
				-- Original binaries are unsigned
				A_temp := STD_LOGIC_VECTOR( "0000" &
											 ((unsigned(A7))* "11110100001001000000") +
											 ((unsigned(A6))* "11000011010100000") +
											 ((unsigned(A5))* "10011100010000") +
											 ((unsigned(A4))* "1111101000") +
											 ((unsigned(A3))* "1100100") + 
											 ((unsigned(A2))* "1010") +
											 ((unsigned(A1))* "01" ));
											 
				B_temp := STD_LOGIC_VECTOR( "0000" &
											 ((unsigned(B7))* "11110100001001000000") +
											 ((unsigned(B6))* "11000011010100000") +
											 ((unsigned(B5))* "10011100010000") +
											 ((unsigned(B4))* "1111101000") +
											 ((unsigned(B3))* "1100100") + 
											 ((unsigned(B2))* "1010") +
											 ((unsigned(B1))* "01" ));
											 
				-- Convert to signed (AKA account for negatives):
				if (unsigned(A8) = 1) then
					A_temp := STD_LOGIC_VECTOR(unsigned(NOT A_temp) + 1);
				end if;
				
				if (unsigned(B8) = 1) then
					B_temp := STD_LOGIC_VECTOR(unsigned(NOT B_temp) + 1);
				end if; 
				-- End convert
				
				Sum_temp := STD_LOGIC_VECTOR(signed('0' & A_temp) + signed('0' & B_temp));
				Res_temp := Sum_temp(NUMBITS-5 downto 0);
				Carry_out <= '0';
				Overflow <= '0';
				
				if (signed(Res_temp) = 0) then
					zero <= '1';
				else
					zero <= '0';
				end if;
				
				flag := 2;
				
			when "1101" => -- BCD signed sub
				A_temp := STD_LOGIC_VECTOR( "0000" &
											 ((unsigned(A7))* "11110100001001000000") +
											 ((unsigned(A6))* "11000011010100000") +
											 ((unsigned(A5))* "10011100010000") +
											 ((unsigned(A4))* "1111101000") +
											 ((unsigned(A3))* "1100100") + 
											 ((unsigned(A2))* "1010") +
											 ((unsigned(A1))* "01" ));
											 
				B_temp := STD_LOGIC_VECTOR( "0000" &
											 ((unsigned(B7))* "11110100001001000000") +
											 ((unsigned(B6))* "11000011010100000") +
											 ((unsigned(B5))* "10011100010000") +
											 ((unsigned(B4))* "1111101000") +
											 ((unsigned(B3))* "1100100") + 
											 ((unsigned(B2))* "1010") +
											 ((unsigned(B1))* "01" ));
											 
				-- Convert to signed (AKA account for negatives):
				if (unsigned(A8) = 1) then
					A_temp := STD_LOGIC_VECTOR(unsigned(NOT A_temp) + 1);
				end if;
				
				if (unsigned(B8) = 1) then
					B_temp := STD_LOGIC_VECTOR(unsigned(NOT B_temp) + 1);
				end if;
				-- End convert
				Sum_temp := STD_LOGIC_vector(signed('0' & A_temp) + (signed('0' & NOT(B_temp)) + 1));
				Res_temp := Sum_temp(NUMBITS-5 downto 0);
				Carry_out <= '0';
				Overflow <= '0';
				
				if (signed(Res_temp) = 0) then
					zero <= '1';
				else 
					zero <= '0';
				end if;
				
				flag := 2;
				
			when others =>
				
		end case;
		
		-- Last, convert Binary back to BCD
		-- if unsigned (flag = 1)
		if ( flag = 1 ) then
			A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 100000000) mod 10);
			R9 := A_temp(3 downto 0);
		-- else if signed (flag = 2)
		elsif ( flag = 2 ) then
			if (Res_temp(NUMBITS-5) = '1') then
				R9 := "0001";
				Res_temp := STD_LOGIC_VECTOR(unsigned(NOT Res_temp) + 1);
			else
				R9 := "0000";
			end if;
		end if;
		
		A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 1) mod 10);
		R1 := A_temp(3 downto 0);
		A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 10) mod 10);
		R2 := A_temp(3 downto 0);
		A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 100) mod 10);
		R3 := A_temp(3 downto 0);
		A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 1000) mod 10);
		R4 := A_temp(3 downto 0);
		A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 10000) mod 10);
		R5 := A_temp(3 downto 0);
		A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 100000) mod 10);
		R6 := A_temp(3 downto 0);
		A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 1000000) mod 10);
		R7 := A_temp(3 downto 0);
		A_temp := STD_LOGIC_VECTOR((unsigned(Res_temp)/ 10000000) mod 10);
		R8 := A_temp(3 downto 0);
		
		Result <= (R9 & R8 & R7 & R6 & R5 & R4 & R3 & R2 & R1);
		
	end process;

end Behavioral;