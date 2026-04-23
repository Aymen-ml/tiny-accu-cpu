<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a compact 8-bit accumulator CPU for workshop use.

Architecture:
- 2-phase control FSM (fetch and execute)
- 8-bit accumulator (ACC)
- 4-bit program counter (PC)
- 8-bit instruction register (IR)
- 16x8 data RAM
- 8-bit add/sub ALU

Instruction format uses `ui_in[7:4]` as opcode and `ui_in[3:0]` as operand.

Supported opcodes:
- `0x0`: LDI (ACC = immediate)
- `0x1`: ADD (ACC = ACC + RAM[addr])
- `0x2`: SUB (ACC = ACC - RAM[addr])
- `0x3`: STO (RAM[addr] = ACC)
- `0x4`: LDM (ACC = RAM[addr])
- `0x5`: JMPZ (if ACC == 0 then PC = operand)
- `0xF`: NOP

Outputs:
- `uo_out[7:0]` = ACC value
- `uio_out[3:0]` = PC debug
- `uio_out[6:4]` = opcode debug
- `uio_out[7]` = fetch phase flag

All logic is synchronous to `clk` and gated by `ena`. Reset (`rst_n`) initializes ACC, PC, IR, control state, and RAM.

## How to test

Run top-level CPU tests:

```sh
cd test
pip install -r requirements.txt
make -B
```

Run per-module unit tests:

```sh
cd test/unit
make -B DUT=alu
make -B DUT=control_fsm
make -B DUT=registers
make -B DUT=memory
make -B DUT=control_unit
make -B DUT=datapath
```

For waveform inspection, open `tb.fst` with GTKWave or Surfer.

## External hardware

No external hardware is required. Instructions are applied through `ui_in`.
