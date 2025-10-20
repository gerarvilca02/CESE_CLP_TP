library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.coeffs_pkg.all;

entity fir_lp_var is
  generic (
    DATA_WIDTH : integer := 16; -- Q1.15
    COEF_WIDTH : integer := 16; -- Q1.15
    ACC_WIDTH  : integer := 40  -- acumulador ensanchado
  );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    in_valid   : in  std_logic;                                     -- CE de datos
    in_sample  : in  signed(DATA_WIDTH-1 downto 0);                 -- Q1.15
    sel        : in  std_logic_vector(1 downto 0);                  -- selección de bancada
    out_valid  : out std_logic;
    out_sample : out signed(DATA_WIDTH-1 downto 0)                  -- Q1.15
  );
end entity;

architecture rtl of fir_lp_var is
  -- Tipos y constantes
  subtype acc_t is signed(ACC_WIDTH-1 downto 0);
  type tap_array_t is array (0 to TAPS-1) of signed(DATA_WIDTH-1 downto 0);

  constant MAX_Q15 : integer :=  32767;
  constant MIN_Q15 : integer := -32768;
  constant SHIFT   : integer := ACC_WIDTH - DATA_WIDTH; -- bits a desplazar para volver a 16b

  -- Registros
  signal xreg   : tap_array_t := (others => (others => '0'));       -- delay line
  signal acc    : acc_t := (others => '0');                         -- acumulador
  signal vld    : std_logic := '0';                                 -- pipeline de valid
  signal vld_d  : std_logic := '0';
  signal sel_r  : std_logic_vector(1 downto 0) := "00";             -- sel registrado

  -- Redondeo + saturación a Q1.15
  function sat_round_q15(a : acc_t) return signed is
    variable tmp   : signed(a'length-1 downto 0) := a;
    variable res_w : signed(ACC_WIDTH-1 downto 0);
    variable out16 : signed(DATA_WIDTH-1 downto 0);
  begin
    if SHIFT > 0 then
      -- redondeo al más cercano sumando 2^(SHIFT-1) antes del shift
      tmp   := tmp + to_signed(2**(SHIFT-1), tmp'length);
      res_w := shift_right(tmp, SHIFT);
    else
      res_w := tmp; -- nada que desplazar si ACC_WIDTH <= DATA_WIDTH
    end if;

    -- saturación
    if res_w > to_signed(MAX_Q15, res_w'length) then
      out16 := to_signed(MAX_Q15, DATA_WIDTH);
    elsif res_w < to_signed(MIN_Q15, res_w'length) then
      out16 := to_signed(MIN_Q15, DATA_WIDTH);
    else
      out16 := resize(res_w, DATA_WIDTH);
    end if;

    return out16;
  end function;

  -- mapeo de sel a índice 0..3
  function sel_to_idx(s: std_logic_vector(1 downto 0)) return integer is
  begin
    case s is
      when "00" => return 0;
      when "01" => return 1;
      when "10" => return 2;
      when others => return 3;
    end case;
  end function;

begin
  process(clk)
    variable sum  : acc_t;
    variable mult : signed(31 downto 0);                            -- 16x16 = 32b
    variable i    : integer;
    variable k    : integer;
    variable ce   : std_logic;                                       -- clock enable explícito
  begin
    if rising_edge(clk) then
      if rst = '1' then
        xreg       <= (others => (others => '0'));
        acc        <= (others => '0');
        vld        <= '0';
        vld_d      <= '0';
        sel_r      <= "00";
        out_sample <= (others => '0');

      else
        -- pipeline de validez (latencia explícita de 1 ciclo)
        vld_d <= vld;
        vld   <= in_valid;

        ce := in_valid; -- alias semántico

        if ce = '1' then
          -- fijar bancada de coeficientes estable para este ciclo
          sel_r <= sel;

          -- delay line: x[n] entra en xreg(0)
          for i in TAPS-1 downto 1 loop
            xreg(i) <= xreg(i-1);
          end loop;
          xreg(0) <= in_sample;

          -- MAC: sumatoria de 64 productos 16x16 acumulados en ACC_WIDTH
          k := sel_to_idx(sel_r);
          sum := (others => '0');
          for i in 0 to TAPS-1 loop
            mult := xreg(i) * COEFFS(k)(i);
            sum  := sum + resize(mult, ACC_WIDTH);
          end loop;

          acc        <= sum;
          out_sample <= sat_round_q15(sum);
        end if;
      end if;
    end if;
  end process;

  -- out_valid alineado con la salida (1 ciclo después del CE)
  out_valid <= vld_d;

end architecture;
