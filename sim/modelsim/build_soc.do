file delete -force work
vlib work
vmap work work

set common "../../submodules/PulseRain_MCU/common";list
set config "../../submodules/PulseRain_MCU/common/efinix";list
set hw_loader "../../submodules/HW_Loader/source";list

set source_core { \
    {../../submodules/PulseRain_MCU/memory/efinix/trion/dual_port_ram.v} \
    {../../submodules/PulseRain_MCU/memory/efinix/trion/single_port_ram.v} \
    {../../submodules/PulseRain_MCU/memory/efinix/trion/single_port_ram_8bit.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/PulseRain_Reindeer_core.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_controller.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_CSR.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_data_access.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_execution_unit.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_instruction_decode.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_fetch_instruction.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_memory.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_reg_file.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_machine_timer.v} \
    {../../submodules/PulseRain_MCU/submodules/PulseRain_processor_core/source/Reindeer_mm_reg.v} \
};list

set source_mcu { \
    {../../submodules/PulseRain_MCU/source/PulseRain_Reindeer_MCU.v} \
    {../../submodules/PulseRain_MCU/peripherals/UART/UART_TX.v} \
    {../../submodules/PulseRain_MCU/peripherals/peripherals.v} \
    {../../submodules/PulseRain_MCU/memory/mem_controller.v} \
}

set source_testbench { \
    {../../submodules/PulseRain_MCU/memory/sim/single_port_ram_sim.v} \
    {../../testbench/file_compare_pkg.sv} \
    {../../testbench/file_compare.sv} \
    {../../testbench/single_file_compare.sv} \
    {../../testbench/tb_RV.sv} \
}



proc build {src_list} {
   global common
   global config
   global hw_loader
   
   foreach src_name $src_list {
        if [file exists $src_name] {
            puts "============================================================================================================================================"
            puts "vlog -work work -sv +incdir+$common +incdir+$config +incdir+../../testbench $src_name"
            puts "============================================================================================================================================"
            
            vlog -work work -sv +incdir+$common +incdir+$config +incdir+../../testbench $src_name
        } else {
            puts "$src_name does not exist !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            break;
        }
   }
}


build $source_core
build $source_mcu
build $source_testbench

