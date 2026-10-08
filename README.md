# Synchronous FIFO in Verilog

This project implements a **Synchronous FIFO (First In First Out)** buffer in Verilog. In a synchronous FIFO, the read and write operations use the **same clock**. The design is divided into small modules to keep it easy to understand, and it is verified with a testbench in Icarus Verilog.

## What is a FIFO?

A FIFO is a memory buffer where the data written first is read out first, like a queue. FIFOs are commonly used to pass data between two blocks that work at different speeds, or to temporarily store data.

## Features

- Parameterized data width and depth (default: 8-bit wide, 16 locations deep)
- `full` and `empty` flags
- Writes are ignored when the FIFO is full
- Reads are ignored when the FIFO is empty
- Read and write can happen in the same clock cycle
- Synchronous, active-high reset

## Folder Structure

```
sync_fifo/
├── rtl/
│   ├── sync_fifo.v       # top module
│   ├── write_pointer.v   # write pointer logic
│   ├── read_pointer.v    # read pointer logic
│   ├── fifo_status.v     # full and empty flag logic
│   └── fifo_memory.v     # memory array
├── tb/
│   └── tb_sync_fifo.v    # testbench
├── run.sh                # script to compile and simulate
└── README.md
```

## Design Hierarchy

```
sync_fifo (top)
 ├── write_pointer   (u_wr_ptr)
 ├── read_pointer    (u_rd_ptr)
 ├── fifo_status     (u_status)
 └── fifo_memory     (u_mem)
```

## Block Diagram

```
             +---------------+       wr_ptr
 wr_en ----->| write_pointer |----------+-------------------+
             +---------------+          |                   |
                    ^                   v                   v
                    | full     +-----------------+   +-------------+
                    +----------|   fifo_status   |   |             |
                    | empty    +-----------------+   | fifo_memory |---> data_out
                    v                   ^            |             |
             +---------------+          |            |             |<--- data_in
 rd_en ----->| read_pointer  |----------+----------->|             |
             +---------------+       rd_ptr          +-------------+
```

## Ports

| Port       | Direction | Width      | Description                     |
|------------|-----------|------------|---------------------------------|
| `clk`      | input     | 1          | Clock                           |
| `rst`      | input     | 1          | Reset (active high)             |
| `wr_en`    | input     | 1          | Write enable                    |
| `rd_en`    | input     | 1          | Read enable                     |
| `data_in`  | input     | DATA_WIDTH | Data to write                   |
| `data_out` | output    | DATA_WIDTH | Data read from FIFO             |
| `full`     | output    | 1          | High when FIFO is full          |
| `empty`    | output    | 1          | High when FIFO is empty         |

## Parameters

| Parameter    | Default | Description                     |
|--------------|---------|---------------------------------|
| `DATA_WIDTH` | 8       | Number of bits in each word     |
| `DEPTH`      | 16      | Number of locations (power of 2)|
| `ADDR_WIDTH` | 4       | log2(DEPTH)                     |

## How It Works

1. **Write:** When `wr_en = 1` and the FIFO is not full, `data_in` is stored at the location pointed to by the write pointer, and the write pointer increases by 1.
2. **Read:** When `rd_en = 1` and the FIFO is not empty, the data at the read pointer appears on `data_out` at the next clock edge, and the read pointer increases by 1.
3. **Full and Empty detection:** Both pointers are one bit wider than needed to address the memory. The extra MSB changes every time a pointer wraps around.
   - **Empty:** the read and write pointers are exactly equal.
   - **Full:** the lower bits are equal but the MSBs are different. This means the write pointer has gone around the memory one more time than the read pointer.

Example with DEPTH = 4 (pointers are 3 bits):

| wr_ptr | rd_ptr | State |
|--------|--------|-------|
| 000    | 000    | Empty |
| 010    | 000    | 2 items stored |
| 100    | 000    | Full  |
| 101    | 101    | Empty |

## Testbench

The testbench keeps its own copy of the expected data and checks the FIFO output and the flags. The following tests are run:

1. Reset check
2. Write until the FIFO is full
3. Write when full (data should be ignored)
4. Read until empty and check that data comes out in the same order
5. Read when empty (should be ignored)
6. Read and write in the same clock cycle
7. 500 random read/write operations

## How to Run

Install [Icarus Verilog](https://steveicarus.github.io/iverilog/) and (optionally) GTKWave.

```bash
./run.sh
```

Or run the commands manually:

```bash
iverilog -o fifo_sim rtl/*.v tb/tb_sync_fifo.v
vvp fifo_sim
```

Expected output:

```
Test 1: Reset
Test 2: Write until full
Test 3: Write when full
Test 4: Read until empty
Test 5: Read when empty
Test 6: Simultaneous read and write
Test 7: Random read/write (500 operations)
----------------------------------
ALL TESTS PASSED
----------------------------------
```

To view the waveform:

```bash
gtkwave sim/sync_fifo.vcd
```

## Tools Used

- Icarus Verilog (simulation)
- GTKWave (waveform viewing)

## Future Scope

- Add `almost_full` and `almost_empty` flags
- Add a counter output to show how many words are stored
- Design an **Asynchronous FIFO** (different read and write clocks) using Gray code pointers
