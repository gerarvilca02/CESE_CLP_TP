## ARTY Z7-10 Rev.B

## Clock Signal
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=SYSCLK
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

## Switches -> sel[1:0]
set_property -dict { PACKAGE_PIN M19  IOSTANDARD LVCMOS33 } [get_ports { sel[0] }]; #IO_L7P_T1_AD2P_35 Sch=SW1
set_property -dict { PACKAGE_PIN M20  IOSTANDARD LVCMOS33 } [get_ports { sel[1] }]; #IO_L7N_T1_AD2N_35 Sch=SW0

## LEDs -> out_valid
set_property -dict { PACKAGE_PIN R14    IOSTANDARD LVCMOS33 } [get_ports { out_valid }]; #IO_L6N_T0_VREF_34 Sch=LED0

## Buttons -> rst, in_valid
set_property -dict { PACKAGE_PIN D19    IOSTANDARD LVCMOS33 } [get_ports { rst }];       #IO_L4P_T0_35 Sch=BTN0
set_property -dict { PACKAGE_PIN D20    IOSTANDARD LVCMOS33 } [get_ports { in_valid }];  #IO_L4N_T0_35 Sch=BTN1

## Pmod Header JA -> in_sample[7:0]
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { in_sample[0] }]; #JA1_P (Pin 1)
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { in_sample[1] }]; #JA1_N (Pin 2)
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { in_sample[2] }]; #JA2_P (Pin 3)
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { in_sample[3] }]; #JA2_N (Pin 4)
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { in_sample[4] }]; #JA3_P (Pin 7)
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { in_sample[5] }]; #JA3_N (Pin 8)
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { in_sample[6] }]; #JA4_P (Pin 9)
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { in_sample[7] }]; #JA4_N (Pin 10)

## Pmod Header JB -> in_sample[15:8]
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { in_sample[8]  }]; #JB1_P (Pin 1)
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { in_sample[9]  }]; #JB1_N (Pin 2)
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { in_sample[10] }]; #JB2_P (Pin 3)
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { in_sample[11] }]; #JB2_N (Pin 4)
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { in_sample[12] }]; #JB3_P (Pin 7)
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { in_sample[13] }]; #JB3_N (Pin 8)
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { in_sample[14] }]; #JB4_P (Pin 9)
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { in_sample[15] }]; #JB4_N (Pin 10)

## ChipKit Outer Digital Header -> out_sample[13:0]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { out_sample[0]  }]; #CK_IO0
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { out_sample[1]  }]; #CK_IO1
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { out_sample[2]  }]; #CK_IO2
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { out_sample[3]  }]; #CK_IO3
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { out_sample[4]  }]; #CK_IO4
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { out_sample[5]  }]; #CK_IO5
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { out_sample[6]  }]; #CK_IO6
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { out_sample[7]  }]; #CK_IO7
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { out_sample[8]  }]; #CK_IO8
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { out_sample[9]  }]; #CK_IO9
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { out_sample[10] }]; #CK_IO10
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { out_sample[11] }]; #CK_IO11
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { out_sample[12] }]; #CK_IO12
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { out_sample[13] }]; #CK_IO13

## Completar out_sample[15:14] con pines de SPI como GPIO
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { out_sample[14] }]; #CK_MISO
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { out_sample[15] }]; #CK_MOSI

