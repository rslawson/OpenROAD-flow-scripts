source $::env(SCRIPTS_DIR)/load.tcl
load_design 1_synth.v 1_synth.sdc

if {[info exist env(GUI_SOURCE)]} {
  source $::env(GUI_SOURCE)
}
