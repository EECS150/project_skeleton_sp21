
set f_mhz [expr int(1000 / ${target_clock})]
set f_hz  [expr int(1000000000 / ${target_clock})]

create_bd_design "z1top_axi_bd"

# Create instance: z1top_axi_0, and set properties
set z1top_axi_0 [create_bd_cell -type module -reference z1top_axi z1top_axi_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0

apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ ${f_mhz} CONFIG.PCW_USE_M_AXI_GP0 {0} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}] [get_bd_cells processing_system7_0]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/z1top_axi_0/interface_aximm} Slave {/processing_system7_0/S_AXI_HP0} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]

apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0" }  [get_bd_pins z1top_axi_0/axi_clk]

set_property CONFIG.CLK_DOMAIN z1top_axi_bd_processing_system7_0_0_FCLK_CLK0 [get_bd_intf_pins /z1top_axi_0/interface_aximm]

set ps_clk [get_property CONFIG.FREQ_HZ [get_bd_pin processing_system7_0/FCLK_CLK0]]
set_property -dict [list CONFIG.FREQ_HZ ${ps_clk}] [get_bd_intf_pins z1top_axi_0/interface_aximm]

set_property CONFIG.ASSOCIATED_BUSIF z1top_axi_0_interface_aximm [get_bd_pins /z1top_axi_0/axi_clk]
set_property CONFIG.CLK_DOMAIN z1top_axi_bd_processing_system7_0_0_FCLK_CLK0 [get_bd_intf_pins /z1top_axi_0/interface_aximm]

set_property -dict [list CONFIG.CPU_CLOCK_FREQ ${f_hz}] [get_bd_cells z1top_axi_0]

# Create ports
set BUTTONS [ create_bd_port -dir I -from 3 -to 0 BUTTONS ]
set FPGA_SERIAL_RX [ create_bd_port -dir I FPGA_SERIAL_RX ]
set FPGA_SERIAL_TX [ create_bd_port -dir O FPGA_SERIAL_TX ]
set CLK_125MHZ_FPGA [ create_bd_port -dir I CLK_125MHZ_FPGA ]
set LEDS [ create_bd_port -dir O -from 5 -to 0 LEDS ]
set SWITCHES [ create_bd_port -dir I -from 1 -to 0 SWITCHES ]


# Create port connections
connect_bd_net -net BUTTONS [get_bd_ports BUTTONS] [get_bd_pins z1top_axi_0/BUTTONS]
connect_bd_net -net FPGA_SERIAL_RX [get_bd_ports FPGA_SERIAL_RX] [get_bd_pins z1top_axi_0/FPGA_SERIAL_RX]
connect_bd_net -net FPGA_SERIAL_TX [get_bd_ports FPGA_SERIAL_TX] [get_bd_pins z1top_axi_0/FPGA_SERIAL_TX]
connect_bd_net -net CLK_125MHZ_FPGA [get_bd_ports CLK_125MHZ_FPGA] [get_bd_pins z1top_axi_0/CLK_125MHZ_FPGA]
connect_bd_net -net SWITCHES [get_bd_ports SWITCHES] [get_bd_pins z1top_axi_0/SWITCHES]
connect_bd_net -net z1top_axi_0_LEDS [get_bd_ports LEDS] [get_bd_pins z1top_axi_0/LEDS]

validate_bd_design
save_bd_design

make_wrapper -files [get_files ${project_name}_proj/${project_name}_proj.srcs/sources_1/bd/z1top_axi_bd/z1top_axi_bd.bd] -top
add_files -norecurse           ${project_name}_proj/${project_name}_proj.srcs/sources_1/bd/z1top_axi_bd/hdl/z1top_axi_bd_wrapper.v
update_compile_order -fileset sources_1
set_property top z1top_axi_bd_wrapper [current_fileset]