-- bist_stub.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bist_stub is
  generic(
    BLOCK_ID : integer := 0
  );
  port(
    clk   : in  std_logic;
    rst_n : in  std_logic;
    start : in  std_logic;
    done  : out std_logic;
    pass  : out std_logic
  );
end entity;

architecture rtl of bist_stub is
  type state_t is (IDLE, RUN, CHECK, DONE_S);
  signal state : state_t := IDLE;
  signal done_i, pass_i : std_logic := '0';
begin
  done <= done_i;
  pass <= pass_i;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      state <= IDLE;
      done_i <= '0';
      pass_i <= '0';
    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          done_i <= '0';
          pass_i <= '0';
          if start = '1' then
            state <= RUN;
          end if;
        when RUN =>
          state <= CHECK;
        when CHECK =>
          pass_i <= '1';
          state <= DONE_S;
        when DONE_S =>
          done_i <= '1';
          if start = '0' then
            state <= IDLE;
          end if;
      end case;
    end if;
  end process;
end architecture;
