#/usr/bin/tclsh

proc write {address value} {
	set address [string range $address 2 [expr {[string length $address]-1}]]
	create_hw_axi_txn -force wr_tx [get_hw_axis hw_axi_1] -address $address -data $value -type write
	run_hw_axi -quiet wr_tx
}

proc read {address} {
	set address [string range $address 2 [expr {[string length $address]-1}]]
	create_hw_axi_txn -quiet -force rd_tx [get_hw_axis hw_axi_1] -address $address -type read
	run_hw_axi -quiet rd_tx
	return 0x[get_property DATA [get_hw_axi_txn rd_tx]]
}

proc create_gpio_data {a_data b_data data_ready_in} {
	
	# Create the data to be sent from the AXI JTAG to the AXI GPIO
	# The first 10 bits corresponds to the a_data
	# The next 10 bits corresponds to the q_symbol
	# The 20th bit corresponds to the reset
	# The 21th bit corresponds to the data_ready_in
	
	set data [expr ($data_ready_in << 21) | ($b_data << 10) | $a_data]
	# Convert the value to hexadecimal
	set gpio_data [format 0x%08x $data]	
	return $gpio_data
}

proc create_gpio_reset {} {
	set data [expr (1 << 20)]
	set data [format 0x%08x $data]
	return $data
}

proc main {} {
	set GPIO_ADDR_WR 0x41200000
	set FIFO_ADDR_RD 0x43c00020
	set file1 [open "mult_in.txt" r]
	set file2 [open "mult_out_expc.txt" w+]
	set reset_first_time 0
	set data_ready_in 0
	set counter 0
	while {[gets $file1 line] >= 0} {
		set numbers [split $line ","]
		set a_value [lindex $numbers 0]
		set b_value [lindex $numbers 1]
		
		set data_ready_in [expr $data_ready_in == 0 ? 1:0]
		set gpio_data [create_gpio_data $a_value $b_value $data_ready_in]

		if {$reset_first_time == 0} {
			set reset [create_gpio_reset]
			write $GPIO_ADDR_WR $reset
			puts "Reset: $reset"
			set reset_first_time 1
		}
		puts "Data: $gpio_data"
		write $GPIO_ADDR_WR $gpio_data
		set counter [expr $counter+1]
	}

	while {$counter > 0} {
		set data_read [read $FIFO_ADDR_RD]
		puts $file2 $data_read
		set counter [expr $counter-1]
	}

	close $file1
	close $file2
}

main
