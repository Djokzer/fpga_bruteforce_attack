----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.02.2024 10:56:20
-- Design Name: 
-- Module Name: top - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;


entity top is
    Port ( 
        clk     : in std_logic;
        rst     : in std_logic;
        start   : out std_logic;
        found   : out std_logic;
        done    : out std_logic
    );
end top;

architecture Behavioral of top is
    -- --------------------------------------------------------------------- --
    --                               Signals
    -- --------------------------------------------------------------------- --
    signal salt     : std_logic_vector (SALT_LENGTH-1 downto 0);
    signal hash     : std_logic_vector (HASH_LENGTH-1 downto 0);
    signal done_s   : std_logic;
    signal success  : std_logic;
    signal dout_we  : std_logic;
    signal dout     : std_logic_vector (31 downto 0);

    attribute dont_touch : string;
    attribute dont_touch of salt : signal is "true";
    attribute dont_touch of hash : signal is "true";
begin
   
    -- --------------------------------------------------------------------- --
    -- Instantiation    BCRYPT CRACKER
    -- --------------------------------------------------------------------- --
    bcrypt_cracker : entity work.bcrypt_cracker
    port map (
        clk     => clk, 
        rst     => rst,         
        t_salt  => salt,
        t_hash  => hash,
        done    => done_s,
        success => success,
        dout_we => dout_we,
        dout    => dout
    );
    salt <= x"7e949a07e88186c649bbeb0a9740c5e0";
    --hash <= x"d86d48abc6671334fd1fba805ee98b4841ce9ec37096d0";    -- aaaab cost 4
    --hash <= x"1982ade712f9ec3d3a57ce85adf7fc3e2b43d7d89f90d3";    -- a cost 4
    hash <= x"852a66560b37e5c18990d3f2c92d7ee70605f2f0254f6f";      -- aaz cost 4
    found <= success;
    done <= done_s;

    output : process(clk)
    begin
        if rising_edge(clk) then
            start <= not rst;
        end if;
    end process output;
end Behavioral;
