----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2023 13:54:53
-- Design Name: 
-- Module Name: uart_pkg - Package
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

library std;
use std.textio.all ; -- File manipulation
library ieee;
use ieee.std_logic_textio.all ; -- read / write std_logic

library uart;
package uart_pkg is
    -- CONSTANTS
    constant NB_BYTES : integer := 10;
    
    -- TYPES
    type BYTES_ARRAY is array(0 to NB_BYTES - 1) of std_logic_vector(7 downto 0);

    -- FUNCTIONS
    function comp_clk_period(clk_freq : integer) return integer;                                --COMPUTE PERIOD IN NANOSECONDS FROM FREQ ON MHZ
    function comp_baudrate_count(clk_freq : integer; baudrate : integer) return integer;        --COMPUTE NB OF CLOCK CYCLES FOR 115200 BAUDRATE
    impure function uart_line_read(file fd : text) return BYTES_ARRAY;                          --Read a line from a file and convert it into a bytes array
    impure function uart_line_write(file fd : text; bytes_arr : BYTES_ARRAY) return boolean;    --Get a bytes array from the user and write it as a line to a file
    impure function diff_files(filename_1 : string; filename_2 : string) return boolean;

    -- PROCEDURE
    procedure uart_tx_byte(
        signal clk_i : in std_logic;
        signal tx_valid_o : out std_logic;
        signal tx_data_o : out std_logic_vector(7 downto 0);
        signal tx_busy_i : in std_logic;
        constant data_i : in std_logic_vector(7 downto 0)
    );
end uart_pkg;

package body uart_pkg is

    -- FUNCTIONS
    function comp_clk_period(clk_freq : integer) return integer is
    begin
        return 1000 / clk_freq;
    end comp_clk_period;
    
    function comp_baudrate_count(clk_freq : integer; baudrate : integer) return integer is
    begin
        return (clk_freq*1000000) / baudrate;
    end comp_baudrate_count;
    
    impure function uart_line_read(file fd : text) return BYTES_ARRAY is
        variable ligne : line;
        variable data_str : string (1 to NB_BYTES);
        variable array_out : BYTES_ARRAY;
    begin
        -- READ FILE LINE
        readline(fd, ligne);
        read(ligne, data_str(1 to NB_BYTES));
        
        -- GET INT OF EACH CHAR
        for i in data_str'range loop
            array_out(i-1) := std_logic_vector(to_unsigned(character'pos(data_str(i)), array_out(i-1)'length));
        end loop;
        
        return array_out;
    end uart_line_read;
    
    impure function uart_line_write(file fd : text; bytes_arr : BYTES_ARRAY) return boolean is
        variable ligne : line;
    begin
        for i in bytes_arr'range loop
            write(ligne, character'val(to_integer(unsigned(bytes_arr(i)))));
        end loop;
        
        writeline(fd, ligne);
        
        return true;
    end uart_line_write;
    
    impure function diff_files(filename_1 : string; filename_2 : string) return boolean is
    file fd_in : text;
    file fd_out : text;
    variable data_in : BYTES_ARRAY;
    variable data_out : BYTES_ARRAY;
    variable bout : boolean := true;
    begin
        file_open(fd_in, filename_1, READ_MODE);
        file_open(fd_out, filename_2, READ_MODE);
        
        report "TEST ------" severity note;
        
        while not endfile(fd_in) loop
            data_in := uart_line_read(fd_in);
            report "1" severity note;
            data_out := uart_line_read(fd_out);
            report "2" severity note;
            if data_in /= data_out then
                bout := false;
                exit;
            end if;
        end loop;
        
        file_close(fd_in);
        file_close(fd_out);
        return bout;
    end diff_files;

    
    -- PROCEDURE
    procedure uart_tx_byte(
        signal clk_i : in std_logic;
        signal tx_valid_o : out std_logic;
        signal tx_data_o : out std_logic_vector(7 downto 0);
        signal tx_busy_i : in std_logic;
        constant data_i : in std_logic_vector(7 downto 0)) is
    begin
        -- SIGNALING WE ARE NOT WRITING
        tx_valid_o <= '0';
    
        -- WAIT FOR UART_TX NOT BUSY
        if tx_busy_i = '1' then 
            wait until tx_busy_i = '0';
            wait until rising_edge(clk_i);
        end if;
        
        tx_valid_o <= '1';
        tx_data_o <= data_i;
        wait until rising_edge(clk_i);
        tx_valid_o <= '0';
        wait until tx_busy_i = '0';
    end procedure;
end uart_pkg;

