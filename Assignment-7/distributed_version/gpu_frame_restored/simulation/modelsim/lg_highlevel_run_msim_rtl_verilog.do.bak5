transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/pixel_gen.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/multi_sram.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/seven_segment.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/sign_extension.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/gpu.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/vga_controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/writeback.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/execute.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/decode.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/lg_highlevel.v}
vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/fetch.v}

vlog -vlog01compat -work work +incdir+C:/Users/beer/Downloads/distributed_version/gpu_frame_restored {C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/lg_highlevel.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver -L rtl_work -L work -voptargs="+acc"  lg_highlevel

do C:/Users/beer/Downloads/distributed_version/gpu_frame_restored/simulation/modelsim/my_custom_view.do
