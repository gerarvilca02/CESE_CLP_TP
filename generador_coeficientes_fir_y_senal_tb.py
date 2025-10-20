import numpy as np
from scipy.signal import firwin

FS = 48_000
NUMTAPS = 64
CUTS_HZ = [500, 1_000, 5_000, 10_000]

def quantize_q15(h):
    q = np.round(h * (2**15 - 1)).astype(int)
    q = np.clip(q, -32768, 32767)
    return q

def make_lowpass(fc_hz, fs=FS, numtaps=NUMTAPS):
    h = firwin(numtaps=numtaps, cutoff=fc_hz, fs=fs, window="hamming", pass_zero="lowpass")
    s = np.sum(h)
    if s != 0:
        h = h / s
    return h

def vhdl_coeffs_pkg(coeff_banks_q15, numtaps=NUMTAPS, pkg_name="coeffs_pkg"):
    lines = []
    lines.append("library ieee;")
    lines.append("use ieee.std_logic_1164.all;")
    lines.append("use ieee.numeric_std.all;")
    lines.append("")
    lines.append(f"package {pkg_name} is")
    lines.append(f"  constant TAPS : integer := {numtaps};")
    lines.append("  subtype coeff_t is signed(15 downto 0);")
    lines.append("  type coeff_arr_t is array (0 to TAPS-1) of coeff_t;")
    lines.append("  type coeff_bank_t is array (0 to 3) of coeff_arr_t;")
    lines.append("  constant COEFFS : coeff_bank_t := (")
    for b, arr in enumerate(coeff_banks_q15):
        lines.append(f"    {b} => (")
        row = []
        for i, v in enumerate(arr):
            row.append(f"to_signed({int(v)}, 16)")
        lines.append("      " + ", ".join(row))
        if b < 3:
            lines.append("    ),")
        else:
            lines.append("    )")
    lines.append("  );")
    lines.append(f"end package {pkg_name};")
    return "\n".join(lines)

def gen_stimulus(fs=FS, seg_seconds=1.0):
    segs = [
        300,    # muy por debajo
        800,    # debajo de 1 kHz
        2000,   # entre 1 y 5 kHz
        8000,   # entre 5 y 10 kHz
        12000,  # por encima de 10 kHz
    ]
    t = np.arange(int(seg_seconds * fs)) / fs
    x = []
    for f in segs:
        s = 0.6 * np.sin(2 * np.pi * f * t)
        x.append(s)
    x = np.concatenate(x)
    x_q15 = np.round(x * 32767).astype(int)
    x_q15 = np.clip(x_q15, -32768, 32767)
    return x_q15, segs

if __name__ == "__main__":
    banks = []
    for fc in CUTS_HZ:
        h = make_lowpass(fc)
        q = quantize_q15(h)
        banks.append(q)

    pkg_text = vhdl_coeffs_pkg(banks, NUMTAPS, "coeffs_pkg")
    with open("coeffs_pkg.vhd", "w", encoding="utf-8") as f:
        f.write(pkg_text)

    x_q15, segs = gen_stimulus(seg_seconds=1.0)
    np.savetxt("stimulus.txt", x_q15, fmt="%d")

    meta = {
        "fs": FS,
        "numtaps": NUMTAPS,
        "cuts_hz": CUTS_HZ,
        "stim_segments_hz": segs,
        "samples": len(x_q15)
    }
    with open("stimulus_meta.txt", "w", encoding="utf-8") as f:
        for k, v in meta.items():
            f.write(f"{k}: {v}\n")

    print("Generado coeffs_pkg.vhd y stimulus.txt")