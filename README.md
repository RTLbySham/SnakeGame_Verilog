# Snake Game on FPGA using Verilog HDL

A complete RTL design of the classic Snake game built with Verilog HDL on Intel Cyclone IV E FPGA (DE2-115). Integrates custom VGA DAC drivers, double-dabble BCD score rendering, and hardware collision detection.

<!-- TODO: Replace with a photo or GIF of the game running on the board -->
<p align="center">
  <img src="images/banner_gameplay.gif" alt="Snake game running on DE2-115 (add banner image or GIF here)" width="70%">
</p>

---

## Table of Contents

1. [Project Information](#project-information)
2. [Features](#features)
3. [Hardware and Software Requirements](#hardware-and-software-requirements)
4. [System Architecture](#system-architecture)
5. [Module Overview](#module-overview)
6. [Controls and Game Rules](#controls-and-game-rules)
7. [Pin Assignments](#pin-assignments)
8. [Repository Structure](#repository-structure)
9. [How to Build and Run](#how-to-build-and-run)
10. [Results](#results)
11. [Future Work](#future-work)
12. [Team](#team)

---

## Project Information

| | |
|---|---|
| **Course** | Digital System Design with FPGA (MAVLD503) |
| **Slot** | L25 + L26 |
| **Programme** | M.Tech VLSI Design, Fall Semester 2026-27 |
| **School** | School of Electronics Engineering (SENSE), Vellore Institute of Technology |
| **Faculty** | Dr. Jagannadha Naidu K |

---

## Features

- 25.175 MHz pixel clock generated from the 50 MHz board oscillator using an `ALTPLL`
- VGA 640×480 @ 60 Hz timing generator with real-time rendering of walls, snake and apple
- Four push buttons for direction control, with 180° reversal lock-out
- Wall and self-collision detection with a red **GAME OVER** screen
- Apple placement using a 20-bit LFSR (maximal length)
- On-screen decimal score (binary-to-BCD "double dabble" converter plus bitmap font ROM)
- Snake growth up to 64 segments, 10 points per apple

---

## Hardware and Software Requirements

**Hardware**
- Terasic DE2-115 FPGA board (Cyclone IV E `EP4CE115F29C7`)
- VGA monitor and VGA cable
- USB-Blaster cable (on board) for programming

**Software**
- Intel Quartus Prime (Lite or Standard edition with Cyclone IV E support)
- *(Optional)* ModelSim / Questa for simulation

---

## System Architecture

<!-- TODO: Add the block diagram exported from the report or draw.io -->
<p align="center">
  <img width="816" height="876" alt="snake_top_architecture_colour" src="https://github.com/user-attachments/assets/11b760b8-5aa5-4c47-979f-17d21b1b1741" />
</p>

Data flow in brief: `CLOCK_50` goes into `vga_pll`, producing the 25.175 MHz pixel clock. A counter divides it down to a roughly 6 Hz game tick. The position controller moves the snake and detects collisions, the random generator supplies apple positions, and `vga_controller` (with the score and game-over text generators) draws everything and drives the ADV7123 VGA DAC.

### Key design parameters

| Parameter | Value |
|---|---|
| System clock | 50 MHz (`CLOCK_50`) |
| Pixel clock | 25.175 MHz (ALTPLL, 50 × 1007 / 2000) |
| Game tick | `clk_divider[21]`, about 6 Hz |
| Movement step | 4 pixels per tick |
| Border wall | 8 pixels |
| Start / max length | 1 / 64 segments |
| Score per apple | 10 |
| Colour depth | 4 bits per channel (upper bits of the 8-bit DAC inputs) |

---

## Module Overview

| File | Module | Description |
|---|---|---|
| `snake_top.v` | `snake_top` | Top level. Clock divider, button inversion, colour expansion, apple-hit detection, score and growth logic |
| `vga_pll.v` | `vga_pll` | `altpll` wrapper generating the 25.175 MHz pixel clock |
| `Snake_Position_Controller.v` | `Snake_Position_Controller` | Direction decoding, head movement, body shift register, wall and self-collision detection |
| `Random_Generator.v` | `Random_Generator` | 20-bit LFSR producing pseudo-random apple coordinates |
| `vga_controller.v` | `vga_controller` | VGA sync and counters, pixel priority mux (game over > wall > head > body > apple > score > background) |
| `text_generator.v` | `text_generator` | Binary-to-BCD conversion and font ROM for the score display |
| `go_generator.v` | `go_generator` | "GAME OVER" text bitmap renderer |

---

## Controls and Game Rules

| Input | Action |
|---|---|
| `KEY[0]` | Move left |
| `KEY[1]` | Move down |
| `KEY[2]` | Move right |
| `KEY[3]` | Move up |
| `SW[0]` | Reset (active high: raise to reset, lower to play) |

- The snake starts at the centre of the screen moving right.
- Reversing direction directly (e.g. left while moving right) is ignored.
- Eating the apple adds 10 points and one segment.
- Hitting the border or your own body ends the game and shows **GAME OVER**; the game state then resets.

---

## Pin Assignments

Target device: **Cyclone IV E EP4CE115F29C7**.

| Signal | Board resource | FPGA pin |
|---|---|---|
| `CLOCK_50` | 50 MHz oscillator | `PIN_Y2` |
| `reset` | `SW[0]` | `PIN_AB28` |
| `buttons[0]` | `KEY[0]` | `PIN_M23` |
| `buttons[1]` | `KEY[1]` | `PIN_M21` |
| `buttons[2]` | `KEY[2]` | `PIN_N21` |
| `buttons[3]` | `KEY[3]` | `PIN_R24` |
| `VGA_HS` | VGA H-sync | `PIN_G13` |
| `VGA_VS` | VGA V-sync | `PIN_C13` |
| `VGA_CLK` | ADV7123 clock | `PIN_A12` |
| `VGA_BLANK_N` | ADV7123 blank | `PIN_F11` |
| `VGA_SYNC_N` | ADV7123 sync | `PIN_C10` |
| `VGA_R[7:0]` | VGA red | *TODO: copy from your `.qsf`* |
| `VGA_G[7:0]` | VGA green | *TODO: copy from your `.qsf`* |
| `VGA_B[7:0]` | VGA blue | *TODO: copy from your `.qsf`* |

<!-- TODO: Add a Pin Planner screenshot -->
<p align="center">
  <img width="1437" height="836" alt="pin planner" src="https://github.com/user-attachments/assets/1c330243-1412-413c-855e-b9cf18fd66fc" />
</p>

> Only `VGA_x[7:4]` carry data; the lower four bits of each channel are tied to zero in `snake_top`.

---

## Repository Structure

```
.
├── rtl/
│   ├── snake_top.v
│   ├── vga_pll.v
│   ├── Snake_Position_Controller.v
│   ├── Random_Generator.v
│   ├── vga_controller.v
│   ├── text_generator.v
│   └── go_generator.v
├── fpga/            # Quartus project files (.qpf, .qsf)
├── images/             # Screenshots and photos used in this README
├── docs/
│   └── report.pdf      # Project report
└── README.md
```

> Adjust this tree to match your actual repository layout.

---

## How to Build and Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
   cd YOUR-REPO
   ```
2. **Open Quartus Prime** and create (or open) the project targeting device `EP4CE115F29C7`.
3. **Add all files** from `src/` and set `snake_top` as the top-level entity.
4. **Pin assignments:** import the provided `.qsf` or assign the pins from the [table above](#pin-assignments) in the Pin Planner.
5. **Compile** the design (Processing → Start Compilation).
6. **Connect** the DE2-115 to the PC with the USB-Blaster cable and to a monitor with the VGA cable.
7. **Program** the FPGA using the Programmer (`.sof` file).
8. Lower `SW[0]` and play using `KEY[3:0]`.

---

## Results

<!-- TODO: Replace each image below with your own screenshot or photo -->

### Gameplay on hardware

<p align="center">
  <img width="1200" height="675" alt="game over" src="https://github.com/user-attachments/assets/ba54d7df-26f2-452f-a04c-4cffe6e977a7" />
</p>

<p align="center">
  <img width="1200" height="675" alt="game over" src="https://github.com/user-attachments/assets/ba54d7df-26f2-452f-a04c-4cffe6e977a7" />
</p>

### Score display

<p align="center">
  <img width="1200" height="675" alt="game over" src="https://github.com/user-attachments/assets/ba54d7df-26f2-452f-a04c-4cffe6e977a7" />
</p>

<p align="center">
  <img width="1200" height="675" alt="game over" src="https://github.com/user-attachments/assets/ba54d7df-26f2-452f-a04c-4cffe6e977a7" />
</p>

### Game over screen

<p align="center">
  <img width="1200" height="675" alt="game over" src="https://github.com/user-attachments/assets/ba54d7df-26f2-452f-a04c-4cffe6e977a7" />
</p>

### Compilation summary

<p align="center">
  <img src="images/compilation_report.png" alt="Quartus compilation flow summary (add screenshot here)" width="70%">
</p>

| Resource | Used / Available |
|---|---|
| Total logic elements | *xxxx* / 114,480 |
| Total registers | *xxxx* |
| Total pins | *xx* / 529 |
| PLLs | 1 / 4 |

| Clock | Required | Fmax achieved |
|---|---|---|
| `vga_clk` | 25.175 MHz | *xx.xx* MHz |

### Demo video


https://github.com/user-attachments/assets/092dc8e3-2eca-484a-a154-2a10f3aae699


## Future Work

- Variable speed levels as the score increases
- Obstacles and multiple levels
- High-score storage and 7-segment score display
- PS/2 keyboard or game-controller input
- Sound output through the on-board audio codec

---

## Team

| Name | Reg. No. |
|---|---|
| Kavya Byju | 26MVD0079 |
| Feby Elza Kurian | 26MVD0067 |
| Shamsundhar K | 26MVD0066 |

**Submitted to:** Dr. Jagannadha Naidu K, School of Electronics Engineering (SENSE), Vellore Institute of Technology

---

## License

<!-- TODO: Choose a license (e.g. MIT) or remove this section -->
This project was developed for academic purposes as part of the M.Tech VLSI Design curriculum at VIT.
