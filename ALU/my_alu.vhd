----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:09:33 01/14/2016 
-- Design Name: 	 my_alu RM
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
-- use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_alu is
	 Generic ( NUMBITS : natural := 8 );
    Port ( A : in  STD_LOGIC_VECTOR (NUMBITS-1 downto 0);
           B : in  STD_LOGIC_VECTOR (NUMBITS-1 downto 0);
           opcode : in  STD_LOGIC_VECTOR(2 downto 0);
           result : out  STD_LOGIC_VECTOR (NUMBITS-1 downto 0);
           carryout : out  STD_LOGIC;
           overflow : out  STD_LOGIC;
           zero : out  STD_LOGIC);
end my_alu;

architecture Behavioral of my_alu is

--signal temp: STD_LOGIC_VECTOR (NUMBITS downto 0);

begin
	process (A, B, opcode) 
			variable temp : STD_LOGIC_vector (NUMBITS downto 0);
		begin
		case opcode is
			when "000" => -- unsigned add (X)
				temp := STD_LOGIC_VECTOR(unsigned('0'&A) + unsigned('0'&B));
				result <= STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
				carryout <= temp(NUMBITS);
				if (temp(NUMBITS) = '1') then
					overflow <= '1';
				else
					overflow <= '0';
				end if;
				if (unsigned(temp) = 0) then
					zero <= '1';
				else 
					zero <= '0';
				end if;
				
			when "001" => -- signed add (X)
				temp := STD_LOGIC_VECTOR(signed('0'&A) + signed('0'&B));
				result <= STD_LOGIC_VECTOR(signed(A) + signed(B));
				carryout <= temp(NUMBITS);
				if ((signed(A) >= 0) AND (signed(B) >= 0) AND (signed(signed(A) + signed(B)) < 0)) then
					overflow <= '1';
				elsif ((signed(A) < 0) AND (signed(B) < 0) AND (signed(signed(A) + signed(B)) >= 0)) then
					overflow <= '1';
				else
					overflow <= '0';
				end if;
				if ((signed(A) + signed(B)) = 0) then
					zero <= '1';
				else 
					zero <= '0';
				end if;
				
			when "010" => -- unsigned sub (-)
				temp := STD_LOGIC_vector(unsigned('0'&A) + (unsigned('0'&NOT(B)) + 1));
				result <= temp(NUMBITS-1 downto 0);
				carryout <= temp(NUMBITS);
				if (signed(temp) > 0) then
					overflow <= '1';
				else
					overflow <= '0';
				end if;
				
				if (signed(temp(NUMBITS-1 downto 0)) = 0) then
					zero <= '1';
				else 
					zero <= '0';
				end if;
				
			when "011" => -- signed sub (X)
				temp := STD_LOGIC_VECTOR(signed('0'&A) + signed('0'&(not(B))));
				result <= STD_LOGIC_VECTOR(signed(A) - signed(B));
				carryout <= temp(NUMBITS);
				if ((signed(A) >= 0) AND (signed(B) < 0) AND ((signed(A) - signed(B)) < 0)) then
					overflow <= '1';
				elsif ((signed(A) < 0) AND (signed(B) >= 0) AND ((signed(A) - signed(B)) >= 0)) then
					overflow <= '1';
				else
					overflow <= '0';
				end if;
				if (signed(temp) = 0) then
					zero <= '1';
				else 
					zero <= '0';
				end if;
				
			when "100" => -- bit-wise AND (X)
				result <= A AND B;
				
			when "101" => -- bit-wise OR (X)
				result <= A OR B;
				
			when "110" => -- bit-wise XOR (X)
				result <= A XOR B;
				
			when "111" => -- Divide A by 2 (X)
				result <= '0' & A(A'left downto 1);
				
			when others =>
				temp := (others => '0'); 
				overflow <= '0';
				carryout <= '0';
		end case;
	end process;

end Behavioral;

