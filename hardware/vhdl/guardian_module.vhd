-- guardian_module.vhd
-- VHDL skeleton equivalent of Guardian Module

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity guardian_module is
  generic(
    BLOCK_ID      : integer := 0;
    FEATURE_WIDTH : integer := 16;
    SCORE_WIDTH   : integer := 16
  );
  port(
    clk            : in  std_logic;
    rst_n          : in  std_logic;
    temp_code      : in  std_logic_vector(11 downto 0);
    volt_code      : in  std_logic_vector(11 downto 0);
    timing_margin  : in  std_logic_vector(15 downto 0);
    enable         : in  std_logic;
    alert_valid    : out std_logic;
    anomaly_score  : out std_logic_vector(15 downto 0);
    block_id       : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of guardian_module is
  signal temp_prev, volt_prev : unsigned(11 downto 0) := (others=>'0');
  signal temp_now  : unsigned(11 downto 0);
  signal volt_now  : unsigned(11 downto 0);
  signal temp_delta, volt_delta : signed(12 downto 0);
  signal score_raw : unsigned(15 downto 0);
  constant THRESHOLD : unsigned(15 downto 0) := to_unsigned(80,16);
begin
  temp_now <= unsigned(temp_code);
  volt_now <= unsigned(volt_code);
  temp_delta <= signed(('0' & temp_now) - ('0' & temp_prev));
  volt_delta <= signed(('0' & volt_now) - ('0' & volt_prev));

  process(temp_delta, volt_delta, timing_margin)
    variable abs_temp : unsigned(11 downto 0);
    variable abs_volt : unsigned(11 downto 0);
  begin
    if temp_delta(12) = '1' then
      abs_temp := unsigned(-temp_delta(11 downto 0));
    else
      abs_temp := unsigned(temp_delta(11 downto 0));
    end if;
    if volt_delta(12) = '1' then
      abs_volt := unsigned(-volt_delta(11 downto 0));
    else
      abs_volt := unsigned(volt_delta(11 downto 0));
    end if;
    score_raw <= resize(abs_temp,16) + resize(abs_volt,16) + unsigned(timing_margin(15 downto 8));
  end process;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      temp_prev     <= (others=>'0');
      volt_prev     <= (others=>'0');
      anomaly_score <= (others=>'0');
      alert_valid   <= '0';
      block_id      <= std_logic_vector(to_unsigned(BLOCK_ID,16));
    elsif rising_edge(clk) then
      if enable = '1' then
        temp_prev     <= temp_now;
        volt_prev     <= volt_now;
        anomaly_score <= std_logic_vector(score_raw);
        if score_raw > THRESHOLD then
          alert_valid <= '1';
        else
          alert_valid <= '0';
        end if;
      else
        alert_valid <= '0';
      end if;
    end if;
  end process;

end architecture;
