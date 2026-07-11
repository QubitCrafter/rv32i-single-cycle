# =============================================================
#  RISC-V Single-Cycle Processor — Master Makefile
# =============================================================
#
#  SIMULATION  (Vivado XSIM — no license needed)
#    make gui           — Compile, elaborate, launch XSIM GUI with waveforms
#    make batch         — Run in terminal, save log → sim/sim_results.txt
#    make compile       — Compile SystemVerilog sources only
#    make elaborate     — Compile + elaborate
#
#  SCHEMATIC & PROJECT  (Vivado — no license needed)
#    make schematic     — RTL elaboration + open schematic in Vivado GUI
#    make project       — Create full Vivado .xpr project (Flow Navigator)
#
#  SYNTHESIS
#    make synth_yosys   — Open-source: Yosys → ASAP7 gate-level netlist
#    make synth_dc      — Licensed:    Synopsys Design Compiler synthesis
#
#  STATIC TIMING ANALYSIS
#    make sta           — Open-source: OpenSTA timing (run synth_yosys first)
#
#  LINTING
#    make lint          — Open-source: Verilator → sim/lint_report.txt
#    make lint_vivado   — Vivado xvlog → sim/lint_vivado_report.txt
#    make lint_vc       — Licensed: Synopsys VC Static → sim/lint_vc_report.txt
#
#  RUN ALL
#    make run_all       — Clean → Sim → Lint → Synth → STA (schematic preserved)
#    make               — Same as make run_all
#
#  CLEANUP
#    make clean         — Remove XSIM artifacts (preserves logs & schematic)
#    make clean_synth   — Remove Vivado synthesis artifacts
#    make clean_yosys   — Remove Yosys / OpenSTA artifacts
#    make clean_dc      — Remove Synopsys DC artifacts
#    make clean_all     — Remove ALL generated artifacts (schematic preserved)
#
#  Tool paths (edit if needed):
#    Vivado   : xvlog / xelab / xsim / vivado — must be on PATH
#    Verilator: verilator — sudo dnf install verilator
#    Yosys    : ~/oss-cad-suite/bin/yosys
#    OpenSTA  : ~/.local/bin/sta
#    DC       : dc_shell — Synopsys license required
#    VC Lint  : vc_static — Synopsys license required
# =============================================================

# =============================================================
# VARIABLES
# =============================================================

# ---- Directories ----
RTL_DIR  = rtl
TB_DIR   = tb
SIM_DIR  = sim
DOCS_DIR = docs
LIB_DIR  = lib

# ---- RTL Sources ----
RTL_SRCS = \
    $(RTL_DIR)/RISCTop.sv \
    $(RTL_DIR)/InstructionMem.sv \
    $(RTL_DIR)/DataMem.sv \
    $(RTL_DIR)/ALU.sv \
    $(RTL_DIR)/ControlUnit.sv \
    $(RTL_DIR)/RegFile.sv \
    $(RTL_DIR)/ProgramCounter.sv \
    $(RTL_DIR)/ImmediateGenerator.sv

TB_SRCS   = $(TB_DIR)/RISCTop_tb.sv
SRC_FILES = $(RTL_SRCS) $(TB_SRCS)

# ---- ASAP7 PDK (required for Yosys and OpenSTA) ----
LIB_FILE  = $(LIB_DIR)/asap7_merged_RVT_TT.lib
RAM_LIB   = $(LIB_DIR)/asap7_fakeram.lib

# ---- Vivado XSIM Settings ----
XVLOG        = xvlog -sv
XELAB        = xelab
XSIM         = xsim
TOP_MODULE   = RISCTop_tb
SIM_SNAPSHOT = RISCTop_sim
WDB_FILE     = RISCTop_full.wdb
WCFG_FILE    = RISCTop_waves.wcfg
TCL_BATCH    = xsim_batch.tcl
TCL_GUI      = xsim_gui.tcl
LOG_FILE     = sim/sim_results.txt

# ---- Vivado Synthesis / Schematic Settings ----
VIVADO      = vivado
SYNTH_TOP   = RISCTop
SYNTH_PART  = xc7a35tcpg236-1
SYNTH_TCL   = synth_schematic.tcl
SCHEMATIC   = docs/RISCTop_schematic.pdf
PROJECT_TCL = create_project.tcl
PROJECT_DIR = vivado_project

# ---- Verilator Lint Settings ----
VERILATOR       = verilator
LINT_REPORT     = sim/lint_report.txt
LINT_VIV_REPORT = sim/lint_vivado_report.txt
LINT_VC_REPORT  = sim/lint_vc_report.txt
LINT_TOP        = RISCTop
VERILATOR_FLAGS = --lint-only --sv -Wall --timing --top-module $(LINT_TOP) \
                  -Wno-EOFNEWLINE

# ---- Synopsys VC Static Settings (licensed) ----
VC_STATIC = vc_static

# ---- Yosys / OpenSTA Settings ----
#  Yosys  : part of OSS CAD Suite — ~/oss-cad-suite/bin/yosys
#  OpenSTA: installed locally     — ~/.local/bin/sta
YOSYS        = $(HOME)/oss-cad-suite/bin/yosys
STA_TOOL     = $(HOME)/.local/bin/sta
SYNTH_DIR    = synth
STA_DIR      = sta
NETLIST      = $(SYNTH_DIR)/RISCTop_netlist_asap7.v
AREA_REPORT  = $(SYNTH_DIR)/report_area.txt
STA_REPORT   = $(STA_DIR)/sta_report.txt
# Temp scripts — generated on the fly and deleted after use
YOSYS_SCRIPT = $(SYNTH_DIR)/synth_asap7.ys
STA_SCRIPT   = $(STA_DIR)/sta_timing.tcl

# ---- Synopsys Design Compiler Settings (licensed) ----
DC_SHELL    = dc_shell
SYNTH_DC_DIR = synth_dc
DC_NETLIST  = $(SYNTH_DC_DIR)/RISCTop_netlist_dc.v
DC_AREA_RPT = $(SYNTH_DC_DIR)/report_area_dc.txt
DC_TIME_RPT = $(SYNTH_DC_DIR)/report_timing_dc.txt
DC_POW_RPT  = $(SYNTH_DC_DIR)/report_power_dc.txt
DC_SCRIPT   = $(SYNTH_DC_DIR)/synth_dc.tcl

# =============================================================
# TARGETS
# =============================================================

.PHONY: all run_all gui batch compile elaborate wcfg \
        schematic project \
        synth_yosys synth_dc \
        sta \
        lint lint_vivado lint_vc \
        clean clean_synth clean_yosys clean_dc clean_all \
        help

all: run_all

# =============================================================
# HELP
# =============================================================
help:
	@echo "============================================================"
	@echo "  RISC-V Single-Cycle Processor — Master Makefile"
	@echo "============================================================"
	@echo ""
	@echo "  RUN ALL"
	@echo "    make / make run_all  - Clean → Sim → Lint → Synth → STA"
	@echo "                          (schematic is preserved)"
	@echo ""
	@echo "  SIMULATION  (Vivado XSIM)"
	@echo "    make gui           - Launch XSIM GUI waveform viewer"
	@echo "    make batch         - Run in terminal → $(LOG_FILE)"
	@echo "    make compile       - Compile SystemVerilog sources only"
	@echo "    make elaborate     - Compile + elaborate"
	@echo ""
	@echo "  SCHEMATIC & PROJECT  (Vivado)"
	@echo "    make schematic     - Open Vivado GUI with RTL schematic"
	@echo "    make project       - Create full Vivado .xpr project"
	@echo ""
	@echo "  SYNTHESIS"
	@echo "    make synth_yosys   - Yosys  → ASAP7 netlist [open-source]"
	@echo "    make synth_dc      - DC     → netlist        [licensed]"
	@echo ""
	@echo "  STATIC TIMING ANALYSIS"
	@echo "    make sta           - OpenSTA → $(STA_REPORT)"
	@echo "                        (run make synth_yosys first)"
	@echo ""
	@echo "  LINTING"
	@echo "    make lint          - Verilator → $(LINT_REPORT)"
	@echo "    make lint_vivado   - xvlog     → $(LINT_VIV_REPORT)"
	@echo "    make lint_vc       - VC Static → $(LINT_VC_REPORT) [licensed]"
	@echo ""
	@echo "  CLEANUP"
	@echo "    make clean         - Remove XSIM build artifacts"
	@echo "    make clean_synth   - Remove Vivado synthesis artifacts"
	@echo "    make clean_yosys   - Remove Yosys/STA artifacts"
	@echo "    make clean_dc      - Remove Synopsys DC artifacts"
	@echo "    make clean_all     - Remove ALL artifacts (schematic kept)"
	@echo ""
	@echo "============================================================"

# =============================================================
# RUN ALL
# =============================================================
#
#  Cleans all generated files (preserving the schematic PDF),
#  then runs the complete flow in order:
#    1. Batch simulation  → sim/sim_results.txt
#    2. Verilator lint    → sim/lint_report.txt
#    3. xvlog lint        → sim/lint_vivado_report.txt
#    4. Yosys synthesis   → synth/RISCTop_netlist_asap7.v + report_area.txt
#    5. OpenSTA timing    → sta/sta_report.txt
# -----------------------------------------------------------------------
run_all:
	@echo ""
	@echo "============================================================"
	@echo "  RISC-V — FULL FLOW (clean → sim → lint → synth → sta)"
	@echo "  Schematic preserved: $(SCHEMATIC)"
	@echo "============================================================"
	@echo ""
	@$(MAKE) clean_all
	@echo ""
	@echo "-------- [1/5] SIMULATION --------"
	@$(MAKE) batch
	@echo ""
	@echo "-------- [2/5] VERILATOR LINT --------"
	@$(MAKE) lint
	@echo ""
	@echo "-------- [3/5] XVLOG LINT --------"
	@$(MAKE) lint_vivado
	@echo ""
	@echo "-------- [4/5] YOSYS SYNTHESIS --------"
	@$(MAKE) synth_yosys
	@echo ""
	@echo "-------- [5/5] OPENSTA TIMING --------"
	@$(MAKE) sta
	@echo ""
	@echo "============================================================"
	@echo "  ALL DONE — Reports generated:"
	@echo "    Simulation : $(LOG_FILE)"
	@echo "    Lint (V)   : $(LINT_REPORT)"
	@echo "    Lint (xvl) : $(LINT_VIV_REPORT)"
	@echo "    Area       : $(AREA_REPORT)"
	@echo "    Timing     : $(STA_REPORT)"
	@echo "    Schematic  : $(SCHEMATIC)  [preserved]"
	@echo "============================================================"

# =============================================================
# SIMULATION  (Vivado XSIM)
# =============================================================

# ---- Step 1: Compile ----
compile:
	@echo ""
	@echo "====== COMPILING SystemVerilog SOURCES ======"
	$(XVLOG) $(SRC_FILES)

# ---- Step 2: Elaborate ----
#  Copies program.hex to cwd so $readmemh("program.hex",...) resolves
#  regardless of how deep xelab/xsim run their working directory.
elaborate: compile
	@echo ""
	@echo "====== ELABORATING DESIGN ======"
	cp sim/program.hex ./program.hex
	$(XELAB) $(TOP_MODULE) -snapshot $(SIM_SNAPSHOT) -debug all -timescale 1ns/1ps

# ---- Generate TCL batch script ----
$(TCL_BATCH):
	@echo "log_wave -recursive *"  > $(TCL_BATCH)
	@echo "run all"               >> $(TCL_BATCH)
	@echo "quit"                  >> $(TCL_BATCH)

# ---- Generate TCL GUI script ----
$(TCL_GUI):
	@echo "log_wave -recursive *"  > $(TCL_GUI)
	@echo "run all"               >> $(TCL_GUI)

# ---- Generate waveform config ----
wcfg: $(WCFG_FILE)

$(WCFG_FILE):
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n' > $(WCFG_FILE)
	@printf '<wave_config>\n' >> $(WCFG_FILE)
	@printf '  <wave_state>\n' >> $(WCFG_FILE)
	@printf '  </wave_state>\n' >> $(WCFG_FILE)
	@printf '  <db_ref_list>\n' >> $(WCFG_FILE)
	@printf '    <db_ref path="%s" id="1"/>\n' "$(WDB_FILE)" >> $(WCFG_FILE)
	@printf '  </db_ref_list>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="divider" fp_name="clk_rst">\n' >> $(WCFG_FILE)
	@printf '    <obj_property name="label">Clock and Reset</obj_property>\n' >> $(WCFG_FILE)
	@printf '    <obj_property name="DisplayName">label</obj_property>\n' >> $(WCFG_FILE)
	@printf '  </wvobject>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="logic" fp_name="/RISCTop_tb/clk"></wvobject>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="logic" fp_name="/RISCTop_tb/rst_n"></wvobject>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="divider" fp_name="pc">\n' >> $(WCFG_FILE)
	@printf '    <obj_property name="label">Program Counter</obj_property>\n' >> $(WCFG_FILE)
	@printf '    <obj_property name="DisplayName">label</obj_property>\n' >> $(WCFG_FILE)
	@printf '  </wvobject>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="array" fp_name="/RISCTop_tb/dut/pc"></wvobject>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="array" fp_name="/RISCTop_tb/dut/instruction"></wvobject>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="divider" fp_name="alu">\n' >> $(WCFG_FILE)
	@printf '    <obj_property name="label">ALU</obj_property>\n' >> $(WCFG_FILE)
	@printf '    <obj_property name="DisplayName">label</obj_property>\n' >> $(WCFG_FILE)
	@printf '  </wvobject>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="array" fp_name="/RISCTop_tb/dut/alu_result"></wvobject>\n' >> $(WCFG_FILE)
	@printf '  <wvobject type="logic" fp_name="/RISCTop_tb/dut/zero"></wvobject>\n' >> $(WCFG_FILE)
	@printf '</wave_config>\n' >> $(WCFG_FILE)

# ---- GUI Mode ----
gui: elaborate $(TCL_GUI) $(WCFG_FILE)
	@echo ""
	@echo "====== LAUNCHING XSIM GUI ======"
	$(XSIM) $(SIM_SNAPSHOT) -gui -tclbatch $(TCL_GUI) -wdb $(WDB_FILE) -view $(WCFG_FILE)

# ---- Batch Mode ----
batch: elaborate $(TCL_BATCH)
	@echo ""
	@echo "====== RUNNING SIMULATION (BATCH) ======"
	$(XSIM) $(SIM_SNAPSHOT) -runall -wdb $(WDB_FILE) -tclbatch $(TCL_BATCH) 2>&1 | tee $(LOG_FILE)
	@echo ""
	@echo "====== SIMULATION COMPLETE ======"
	@echo "  Log file : $(LOG_FILE)"
	@echo "  WDB file : $(WDB_FILE)"
	@echo ""
	@echo "To view waveforms later:"
	@echo "  xsim --gui $(SIM_SNAPSHOT) -view $(WCFG_FILE)"

# =============================================================
# SCHEMATIC & PROJECT  (Vivado)
# =============================================================

# ---- Auto-generate synthesis TCL then launch Vivado GUI ----
#  The schematic TCL is generated on the fly and persisted so that
#  Vivado can be re-opened manually without re-running make.
$(SYNTH_TCL):
	@echo "# Auto-generated by Makefile — do not edit" > $(SYNTH_TCL)
	@echo "read_verilog -sv $(RTL_DIR)/RISCTop.sv" >> $(SYNTH_TCL)
	@echo "read_verilog -sv $(RTL_DIR)/ALU.sv" >> $(SYNTH_TCL)
	@echo "read_verilog -sv $(RTL_DIR)/ControlUnit.sv" >> $(SYNTH_TCL)
	@echo "read_verilog -sv $(RTL_DIR)/DataMem.sv" >> $(SYNTH_TCL)
	@echo "read_verilog -sv $(RTL_DIR)/ImmediateGenerator.sv" >> $(SYNTH_TCL)
	@echo "read_verilog -sv $(RTL_DIR)/InstructionMem.sv" >> $(SYNTH_TCL)
	@echo "read_verilog -sv $(RTL_DIR)/ProgramCounter.sv" >> $(SYNTH_TCL)
	@echo "read_verilog -sv $(RTL_DIR)/RegFile.sv" >> $(SYNTH_TCL)
	@echo "synth_design -top $(SYNTH_TOP) -part $(SYNTH_PART) -mode out_of_context -rtl" >> $(SYNTH_TCL)
	@echo "show_schematic [get_cells]" >> $(SYNTH_TCL)
	@echo "puts \"\"" >> $(SYNTH_TCL)
	@echo "puts \"=======================================================\"" >> $(SYNTH_TCL)
	@echo "puts \"Schematic open. To export PDF, run in TCL console:\"" >> $(SYNTH_TCL)
	@echo "puts \"  write_schematic -force -format pdf docs/RISCTop_schematic.pdf\"" >> $(SYNTH_TCL)
	@echo "puts \"=======================================================\"" >> $(SYNTH_TCL)

schematic: $(SYNTH_TCL)
	@echo ""
	@echo "====== GENERATING SCHEMATIC (Vivado GUI) ======"
	@echo "  Top  : $(SYNTH_TOP)"
	@echo "  Part : $(SYNTH_PART)"
	@echo ""
	$(VIVADO) -mode gui -source $(SYNTH_TCL) -nojournal -nolog

# ---- Full Vivado .xpr Project (Flow Navigator) ----
$(PROJECT_TCL):
	@echo "# Auto-generated by Makefile — do not edit" > $(PROJECT_TCL)
	@echo "create_project -force RISC_V $(PROJECT_DIR) -part $(SYNTH_PART)" >> $(PROJECT_TCL)
	@echo "add_files $(RTL_DIR)" >> $(PROJECT_TCL)
	@echo "add_files -fileset sim_1 $(TB_DIR)" >> $(PROJECT_TCL)
	@echo "add_files -fileset sim_1 sim/program.hex" >> $(PROJECT_TCL)
	@echo "set_property file_type {Memory File} [get_files sim/program.hex]" >> $(PROJECT_TCL)
	@echo "set_property top $(SYNTH_TOP) [current_fileset]" >> $(PROJECT_TCL)
	@echo "set_property top RISCTop_tb [get_filesets sim_1]" >> $(PROJECT_TCL)
	@echo "update_compile_order -fileset sources_1" >> $(PROJECT_TCL)
	@echo "update_compile_order -fileset sim_1" >> $(PROJECT_TCL)
	@echo "puts \"Project created! Flow Navigator is now available.\"" >> $(PROJECT_TCL)

project: $(PROJECT_TCL)
	@echo ""
	@echo "====== CREATING VIVADO PROJECT ======"
	@echo "  This will open the full Vivado GUI with the Flow Navigator."
	@echo ""
	$(VIVADO) -mode gui -source $(PROJECT_TCL) -nojournal -nolog

# =============================================================
# SYNTHESIS
# =============================================================

# ---- Yosys Synthesis (open-source, ASAP7 7nm PDK) ----
#
#  Generates the synthesis script inline, runs Yosys, then
#  deletes the temporary .ys script — no external files needed.
#
#  Outputs (in synth/):
#    RISCTop_netlist_asap7.v  — gate-level netlist (input for STA)
#    report_area.txt          — cell area breakdown
# -----------------------------------------------------------------------
synth_yosys:
	@echo ""
	@echo "====== YOSYS SYNTHESIS (ASAP7 7nm) ======"
	@echo "  Netlist : $(NETLIST)"
	@echo "  Area    : $(AREA_REPORT)"
	@echo ""
	@if [ ! -f "$(LIB_FILE)" ]; then \
	    echo "ERROR: Liberty file not found: $(LIB_FILE)"; \
	    echo "  Place asap7_merged_RVT_TT.lib in the lib/ directory."; \
	    exit 1; \
	fi
	@mkdir -p $(SYNTH_DIR)
	@cp sim/program.hex $(SYNTH_DIR)/program.hex
	@echo "# Auto-generated by Makefile — do not edit" > $(YOSYS_SCRIPT)
	@echo "read_verilog -sv ../$(RTL_DIR)/RISCTop.sv" >> $(YOSYS_SCRIPT)
	@echo "read_verilog -sv ../$(RTL_DIR)/ALU.sv" >> $(YOSYS_SCRIPT)
	@echo "read_verilog -sv ../$(RTL_DIR)/ControlUnit.sv" >> $(YOSYS_SCRIPT)
	@echo "read_verilog -sv ../$(RTL_DIR)/DataMem.sv" >> $(YOSYS_SCRIPT)
	@echo "read_verilog -sv ../$(RTL_DIR)/ImmediateGenerator.sv" >> $(YOSYS_SCRIPT)
	@echo "read_verilog -sv ../$(RTL_DIR)/InstructionMem.sv" >> $(YOSYS_SCRIPT)
	@echo "read_verilog -sv ../$(RTL_DIR)/ProgramCounter.sv" >> $(YOSYS_SCRIPT)
	@echo "read_verilog -sv ../$(RTL_DIR)/RegFile.sv" >> $(YOSYS_SCRIPT)
	@echo "hierarchy -check -top $(SYNTH_TOP)" >> $(YOSYS_SCRIPT)
	@echo "proc" >> $(YOSYS_SCRIPT)
	@echo "opt" >> $(YOSYS_SCRIPT)
	@echo "fsm" >> $(YOSYS_SCRIPT)
	@echo "opt" >> $(YOSYS_SCRIPT)
	@echo "memory" >> $(YOSYS_SCRIPT)
	@echo "opt" >> $(YOSYS_SCRIPT)
	@echo "techmap" >> $(YOSYS_SCRIPT)
	@echo "opt" >> $(YOSYS_SCRIPT)
	@echo "dfflegalize -cell \$$_DFF_P_ 0 -cell \$$_DFF_N_ 0 -cell \$$_DFFSR_PNN_ 0 -cell \$$_DFFSR_NNN_ 0" >> $(YOSYS_SCRIPT)
	@echo "dfflibmap -liberty ../$(LIB_FILE)" >> $(YOSYS_SCRIPT)
	@echo "abc -liberty ../$(LIB_FILE)" >> $(YOSYS_SCRIPT)
	@echo "opt_clean -purge" >> $(YOSYS_SCRIPT)
	@echo "tee -o report_area.txt stat -liberty ../$(LIB_FILE) -liberty ../$(RAM_LIB)" >> $(YOSYS_SCRIPT)
	@echo "write_verilog -noattr $(SYNTH_TOP)_netlist_asap7.v" >> $(YOSYS_SCRIPT)
	cd $(SYNTH_DIR) && $(YOSYS) synth_asap7.ys
	@rm -f $(YOSYS_SCRIPT)
	@echo ""
	@if [ -f "$(NETLIST)" ]; then \
	    echo "====== SYNTHESIS COMPLETE ======"; \
	    echo "  Netlist : $(NETLIST)"; \
	    echo "  Area    : $(AREA_REPORT)"; \
	    echo "  Run  make sta  for timing analysis."; \
	else \
	    echo "ERROR: Netlist not generated. Check Yosys output above."; \
	    exit 1; \
	fi

# ---- Synopsys Design Compiler Synthesis (licensed) ----
#
#  Generates the DC synthesis TCL inline, runs dc_shell, then
#  deletes the temporary script — no external files needed.
#
#  Requires: dc_shell on PATH + valid Synopsys license
#
#  Outputs (in synth_dc/):
#    RISCTop_netlist_dc.v    — gate-level netlist
#    report_area_dc.txt      — area report
#    report_timing_dc.txt    — timing report
#    report_power_dc.txt     — power report
# -----------------------------------------------------------------------
synth_dc:
	@echo ""
	@echo "====== SYNOPSYS DESIGN COMPILER SYNTHESIS ======"
	@echo "  Netlist : $(DC_NETLIST)"
	@echo ""
	@if ! command -v $(DC_SHELL) >/dev/null 2>&1; then \
	    echo "ERROR: dc_shell not found on PATH. A Synopsys DC license is required."; \
	    exit 1; \
	fi
	@if [ ! -f "$(LIB_FILE)" ]; then \
	    echo "ERROR: Liberty file not found: $(LIB_FILE)"; \
	    exit 1; \
	fi
	@mkdir -p $(SYNTH_DC_DIR)
	@cp sim/program.hex $(SYNTH_DC_DIR)/program.hex
	@echo "# Auto-generated by Makefile — do not edit" > $(DC_SCRIPT)
	@echo "set_app_var search_path [list ../$(LIB_DIR)]" >> $(DC_SCRIPT)
	@echo "set_app_var target_library {asap7_merged_RVT_TT.lib}" >> $(DC_SCRIPT)
	@echo "set_app_var link_library [list * asap7_merged_RVT_TT.lib]" >> $(DC_SCRIPT)
	@echo "analyze -format sverilog ../$(RTL_DIR)/ALU.sv" >> $(DC_SCRIPT)
	@echo "analyze -format sverilog ../$(RTL_DIR)/ControlUnit.sv" >> $(DC_SCRIPT)
	@echo "analyze -format sverilog ../$(RTL_DIR)/DataMem.sv" >> $(DC_SCRIPT)
	@echo "analyze -format sverilog ../$(RTL_DIR)/ImmediateGenerator.sv" >> $(DC_SCRIPT)
	@echo "analyze -format sverilog ../$(RTL_DIR)/InstructionMem.sv" >> $(DC_SCRIPT)
	@echo "analyze -format sverilog ../$(RTL_DIR)/ProgramCounter.sv" >> $(DC_SCRIPT)
	@echo "analyze -format sverilog ../$(RTL_DIR)/RegFile.sv" >> $(DC_SCRIPT)
	@echo "analyze -format sverilog ../$(RTL_DIR)/RISCTop.sv" >> $(DC_SCRIPT)
	@echo "elaborate $(SYNTH_TOP)" >> $(DC_SCRIPT)
	@echo "link" >> $(DC_SCRIPT)
	@echo "check_design" >> $(DC_SCRIPT)
	@echo "current_design $(SYNTH_TOP)" >> $(DC_SCRIPT)
	@echo "create_clock -name clk -period 20 [get_ports clk]" >> $(DC_SCRIPT)
	@echo "set_clock_uncertainty 0.5 [get_clocks clk]" >> $(DC_SCRIPT)
	@echo "set_clock_transition  0.1 [get_clocks clk]" >> $(DC_SCRIPT)
	@echo "set_input_delay  -max 4 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]" >> $(DC_SCRIPT)
	@echo "set_output_delay -max 4 -clock clk [all_outputs]" >> $(DC_SCRIPT)
	@echo "set_max_area 0" >> $(DC_SCRIPT)
	@echo "set_load 0.1 [all_outputs]" >> $(DC_SCRIPT)
	@echo "compile_ultra -no_autoungroup" >> $(DC_SCRIPT)
	@echo "write_file -f verilog -hier -output RISCTop_netlist_dc.v" >> $(DC_SCRIPT)
	@echo "report_area    > report_area_dc.txt" >> $(DC_SCRIPT)
	@echo "report_timing  > report_timing_dc.txt" >> $(DC_SCRIPT)
	@echo "report_power   > report_power_dc.txt" >> $(DC_SCRIPT)
	cd $(SYNTH_DC_DIR) && $(DC_SHELL) -f synth_dc.tcl | tee dc_synth.log
	@rm -f $(DC_SCRIPT)
	@echo ""
	@echo "====== DC SYNTHESIS COMPLETE ======"
	@echo "  Reports: $(DC_AREA_RPT), $(DC_TIME_RPT), $(DC_POW_RPT)"

# =============================================================
# STATIC TIMING ANALYSIS  (OpenSTA)
# =============================================================
#
#  Generates the STA TCL script inline, runs OpenSTA, then
#  deletes the temporary script — no external files needed.
#
#  Run  make synth_yosys  first to generate the gate-level netlist.
#
#  Output:
#    sta/sta_report.txt  — setup/hold/WNS/TNS/power report
# -----------------------------------------------------------------------
sta:
	@echo ""
	@echo "====== OPENSTA TIMING ANALYSIS ======"
	@echo "  Netlist : $(NETLIST)"
	@echo "  Report  : $(STA_REPORT)"
	@echo ""
	@if [ ! -f "$(NETLIST)" ]; then \
	    echo "ERROR: Gate-level netlist not found: $(NETLIST)"; \
	    echo "  Run  make synth_yosys  first."; \
	    exit 1; \
	fi
	@if [ ! -f "$(LIB_FILE)" ]; then \
	    echo "ERROR: Liberty file not found: $(LIB_FILE)"; \
	    exit 1; \
	fi
	@mkdir -p $(STA_DIR)
	@echo "# Auto-generated by Makefile — do not edit" > $(STA_SCRIPT)
	@echo "read_liberty ../$(LIB_FILE)" >> $(STA_SCRIPT)
	@echo "read_liberty ../$(RAM_LIB)" >> $(STA_SCRIPT)
	@echo "read_verilog  ../$(NETLIST)" >> $(STA_SCRIPT)
	@echo "link_design   $(SYNTH_TOP)" >> $(STA_SCRIPT)
	@echo "create_clock -name clk -period 20000 [get_ports clk]" >> $(STA_SCRIPT)
	@echo "set_clock_uncertainty -setup  50 [get_clocks clk]" >> $(STA_SCRIPT)
	@echo "set_clock_uncertainty -hold   20 [get_clocks clk]" >> $(STA_SCRIPT)
	@echo "set_clock_transition          30 [get_clocks clk]" >> $(STA_SCRIPT)
	@echo "foreach port [all_inputs] {" >> $(STA_SCRIPT)
	@echo "    if {[get_property \$$port name] ne \"clk\"} {" >> $(STA_SCRIPT)
	@echo "        set_input_delay -max 4000 -clock clk \$$port" >> $(STA_SCRIPT)
	@echo "        set_input_delay -min  500 -clock clk \$$port" >> $(STA_SCRIPT)
	@echo "    }" >> $(STA_SCRIPT)
	@echo "}" >> $(STA_SCRIPT)
	@echo "set_output_delay -max 4000 -clock clk [all_outputs]" >> $(STA_SCRIPT)
	@echo "set_output_delay -min  500 -clock clk [all_outputs]" >> $(STA_SCRIPT)
	@echo "set_load 0.1 [all_outputs]" >> $(STA_SCRIPT)
	@echo "puts \"\n==== SETUP TIMING (MAX) ====\"" >> $(STA_SCRIPT)
	@echo "report_checks -path_delay max -format full_clock_expanded -fields {slew cap input net} -digits 4" >> $(STA_SCRIPT)
	@echo "puts \"\n==== HOLD TIMING (MIN) ====\"" >> $(STA_SCRIPT)
	@echo "report_checks -path_delay min -fields {slew cap input net} -digits 4" >> $(STA_SCRIPT)
	@echo "puts \"\n==== WORST NEGATIVE SLACK (WNS) ====\"" >> $(STA_SCRIPT)
	@echo "report_wns" >> $(STA_SCRIPT)
	@echo "puts \"\n==== TOTAL NEGATIVE SLACK (TNS) ====\"" >> $(STA_SCRIPT)
	@echo "report_tns" >> $(STA_SCRIPT)
	@echo "puts \"\n==== POWER ====\"" >> $(STA_SCRIPT)
	@echo "report_power" >> $(STA_SCRIPT)
	@echo "puts \"\nDone.\"" >> $(STA_SCRIPT)
	@echo "exit" >> $(STA_SCRIPT)
	cd $(STA_DIR) && $(STA_TOOL) sta_timing.tcl 2>&1 | tee sta_report.txt
	@rm -f $(STA_SCRIPT)
	@echo ""
	@echo "====== STA COMPLETE ======"
	@echo "  Report saved to: $(STA_REPORT)"

# =============================================================
# LINTING
# =============================================================

# ---- Verilator Lint (open-source, richest warnings) ----
#
#  Checks: undeclared nets, width mismatches, unused signals,
#          undriven outputs, blocking in always_ff, combo loops
# -----------------------------------------------------------------------
lint:
	@echo ""
	@echo "====== LINTING RTL WITH VERILATOR ======"
	@echo "  Top    : $(LINT_TOP)"
	@echo "  Report : $(LINT_REPORT)"
	@echo ""
	$(VERILATOR) $(VERILATOR_FLAGS) \
	    $(RTL_DIR)/RISCTop.sv \
	    $(RTL_DIR)/ALU.sv \
	    $(RTL_DIR)/ControlUnit.sv \
	    $(RTL_DIR)/DataMem.sv \
	    $(RTL_DIR)/ImmediateGenerator.sv \
	    $(RTL_DIR)/InstructionMem.sv \
	    $(RTL_DIR)/ProgramCounter.sv \
	    $(RTL_DIR)/RegFile.sv \
	    2>&1 | tee $(LINT_REPORT); \
	ISSUES=$$(grep -c "%Warning\|%Error" $(LINT_REPORT) 2>/dev/null || true); \
	echo ""; \
	echo "====== LINT SUMMARY ======"; \
	echo "  Issues found : $$ISSUES"; \
	echo "  Report saved : $(LINT_REPORT)"; \
	if [ "$$ISSUES" -eq 0 ]; then \
	    echo "  >>> CLEAN — no warnings or errors <<<"; \
	else \
	    echo "  >>> See $(LINT_REPORT) for details <<<"; \
	fi

# ---- xvlog Lint (Vivado, no extra install needed) ----
lint_vivado:
	@echo ""
	@echo "====== LINTING RTL WITH XVLOG (Vivado) ======"
	@echo "  Output: $(LINT_VIV_REPORT)"
	@echo ""
	$(XVLOG) \
	    $(RTL_DIR)/RISCTop.sv \
	    $(RTL_DIR)/ALU.sv \
	    $(RTL_DIR)/ControlUnit.sv \
	    $(RTL_DIR)/DataMem.sv \
	    $(RTL_DIR)/ImmediateGenerator.sv \
	    $(RTL_DIR)/InstructionMem.sv \
	    $(RTL_DIR)/ProgramCounter.sv \
	    $(RTL_DIR)/RegFile.sv \
	    2>&1 | tee $(LINT_VIV_REPORT); \
	ERRORS=$$(grep -c "^ERROR\|^WARNING" $(LINT_VIV_REPORT) 2>/dev/null || true); \
	echo ""; \
	echo "====== XVLOG LINT SUMMARY ======"; \
	echo "  Issues found : $$ERRORS"; \
	echo "  Report saved : $(LINT_VIV_REPORT)"; \
	if [ "$$ERRORS" -eq 0 ]; then \
	    echo "  >>> CLEAN — no errors or warnings <<<"; \
	else \
	    echo "  >>> See $(LINT_VIV_REPORT) for details <<<"; \
	fi

# ---- Synopsys VC Static Lint (licensed) ----
#
#  Generates the VC lint TCL inline, runs vc_static, then
#  deletes the temporary script — no external files needed.
#
#  Requires: vc_static on PATH + valid Synopsys license
#  Output  : sim/lint_vc_report.txt
# -----------------------------------------------------------------------
lint_vc:
	@echo ""
	@echo "====== SYNOPSYS VC STATIC LINT ======"
	@echo "  Report : $(LINT_VC_REPORT)"
	@echo ""
	@if ! command -v $(VC_STATIC) >/dev/null 2>&1; then \
	    echo "ERROR: vc_static not found on PATH. A Synopsys license is required."; \
	    exit 1; \
	fi
	$(eval VC_TCL := /tmp/vc_lint_$$$$.tcl)
	@echo "set_app_var enable_lint true" > $(VC_TCL)
	@echo "configure_lint_setup -goal lint_rtl" >> $(VC_TCL)
	@echo "analyze -verbose -format sverilog ../$(RTL_DIR)/ALU.sv" >> $(VC_TCL)
	@echo "analyze -verbose -format sverilog ../$(RTL_DIR)/ControlUnit.sv" >> $(VC_TCL)
	@echo "analyze -verbose -format sverilog ../$(RTL_DIR)/DataMem.sv" >> $(VC_TCL)
	@echo "analyze -verbose -format sverilog ../$(RTL_DIR)/ImmediateGenerator.sv" >> $(VC_TCL)
	@echo "analyze -verbose -format sverilog ../$(RTL_DIR)/InstructionMem.sv" >> $(VC_TCL)
	@echo "analyze -verbose -format sverilog ../$(RTL_DIR)/ProgramCounter.sv" >> $(VC_TCL)
	@echo "analyze -verbose -format sverilog ../$(RTL_DIR)/RegFile.sv" >> $(VC_TCL)
	@echo "analyze -verbose -format sverilog ../$(RTL_DIR)/RISCTop.sv" >> $(VC_TCL)
	@echo "elaborate $(SYNTH_TOP)" >> $(VC_TCL)
	@echo "configure_lint_tag -disable -tag \"W240\" -goal lint_rtl" >> $(VC_TCL)
	@echo "check_lint" >> $(VC_TCL)
	@echo "report_violations -verbose -file ../$(LINT_VC_REPORT)" >> $(VC_TCL)
	$(VC_STATIC) -f $(VC_TCL) 2>&1 | tee -a $(LINT_VC_REPORT)
	@rm -f $(VC_TCL)
	@echo ""
	@echo "====== VC LINT COMPLETE ======"
	@echo "  Report saved to: $(LINT_VC_REPORT)"

# =============================================================
# CLEANUP
# =============================================================

# ---- Remove XSIM simulation artifacts ----
#  NOTE: sim/sim_results.txt, sim/lint_report.txt and docs/ are preserved.
clean:
	@echo "====== CLEANING XSIM BUILD ARTIFACTS ======"
	rm -rf xsim.dir .Xil
	rm -f *.jou *.log *.pb *.wdb *.vcd *.str *.bit
	rm -f $(TCL_BATCH) $(TCL_GUI) $(WCFG_FILE) program.hex
	rm -f webtalk*.* xvlog*.* xelab*.* xsim*.*
	rm -f $(LINT_VIV_REPORT)
	@echo "NOTE: $(LOG_FILE), $(LINT_REPORT) and $(SCHEMATIC) are preserved."
	@echo "Done."

# ---- Remove Vivado synthesis artifacts ----
clean_synth:
	@echo "====== CLEANING VIVADO SYNTHESIS & PROJECT ARTIFACTS ======"
	rm -f $(SYNTH_TCL) $(PROJECT_TCL)
	rm -rf .Xil vivado_pid*.str $(PROJECT_DIR)
	@echo "Done."

# ---- Remove Yosys & OpenSTA artifacts ----
clean_yosys:
	@echo "====== CLEANING YOSYS & STA ARTIFACTS ======"
	rm -rf $(SYNTH_DIR) $(STA_DIR)
	@echo "Done."

# ---- Remove Synopsys DC artifacts ----
clean_dc:
	@echo "====== CLEANING SYNOPSYS DC ARTIFACTS ======"
	rm -rf $(SYNTH_DC_DIR)
	@echo "Done."

# ---- Remove ALL generated artifacts (schematic is preserved) ----
clean_all: clean clean_synth clean_yosys clean_dc
	@echo "====== ALL ARTIFACTS CLEANED (schematic preserved) ======"
	@echo "  Kept: $(SCHEMATIC)"
