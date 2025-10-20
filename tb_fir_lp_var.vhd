library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity tb_fir_lp_var is
end entity;

architecture sim of tb_fir_lp_var is
  constant DATA_WIDTH : integer := 16;
  constant COEF_WIDTH : integer := 16;
  constant ACC_WIDTH  : integer := 40;

  constant STIM_FILE  : string  := "stimulus.txt";
  constant OUT_FILE   : string  := "output.txt";
  constant SEG_LEN    : integer := 24000;
  constant MIN_Q15    : integer := -32768;
  constant MAX_Q15    : integer :=  32767;

  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';
  signal in_valid   : std_logic := '0';
  signal in_sample  : signed(DATA_WIDTH-1 downto 0) := (others => '0');
  signal sel        : std_logic_vector(1 downto 0) := "00";
  signal out_valid  : std_logic;
  signal out_sample : signed(DATA_WIDTH-1 downto 0);

  constant CLK_PERIOD : time := 20 ns;

  component fir_lp_var
    generic (
      DATA_WIDTH : integer := 16;
      COEF_WIDTH : integer := 16;
      ACC_WIDTH  : integer := 40
    );
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      in_valid   : in  std_logic;
      in_sample  : in  signed(DATA_WIDTH-1 downto 0);
      sel        : in  std_logic_vector(1 downto 0);
      out_valid  : out std_logic;
      out_sample : out signed(DATA_WIDTH-1 downto 0)
    );
  end component;
begin
  clk <= not clk after CLK_PERIOD/2;

  uut: fir_lp_var
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      COEF_WIDTH => COEF_WIDTH,
      ACC_WIDTH  => ACC_WIDTH
    )
    port map (
      clk        => clk,
      rst        => rst,
      in_valid   => in_valid,
      in_sample  => in_sample,
      sel        => sel,
      out_valid  => out_valid,
      out_sample => out_sample
    );

  stim_proc: process
    file fstim : text;
    file fout  : text;
    variable L     : line;
    variable Lout  : line;
    variable val   : integer;
    variable n     : integer := 0;
    variable wrote : boolean := false;
  begin
    file_open(fstim, STIM_FILE, read_mode);

    file_open(fout, OUT_FILE, write_mode);
    wrote := true;

    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;

    in_valid <= '1';

    while not endfile(fstim) loop
      readline(fstim, L);
      read(L, val);
      assert (val >= MIN_Q15 and val <= MAX_Q15)
        report "Muestra fuera de rango Q1.15: " & integer'image(val)
        severity warning;

      in_sample <= to_signed(val, DATA_WIDTH);

      if n < SEG_LEN then
        sel <= "00";
      elsif n < 2*SEG_LEN then
        sel <= "01";
      elsif n < 3*SEG_LEN then
        sel <= "10";
      else
        sel <= "11";
      end if;

      wait until rising_edge(clk);
      n := n + 1;

      if out_valid = '1' then
        write(Lout, integer'image(to_integer(out_sample)));
        writeline(fout, Lout);
      end if;
    end loop;

    in_valid <= '0';
    wait for 10 us;

    if wrote then
      file_close(fout);
    end if;
    file_close(fstim);

    report "Fin de simulacion. Muestras procesadas: " & integer'image(n) severity note;
    wait;
  end process;

end architecture;
