# DE2-115 Pin Assignments for Snake Top Module

# 50 MHz Clock & Reset Button (KEY0)
set_location_assignment PIN_Y2 -to CLOCK_50
set_location_assignment PIN_AB28 -to reset

# Pushbuttons (KEY1, KEY2, KEY3)
set_location_assignment PIN_M21 -to buttons[0]
set_location_assignment PIN_N21 -to buttons[1]
set_location_assignment PIN_M23 -to buttons[2]
set_location_assignment PIN_R24 -to buttons[3]


# VGA Sync and Clock Signals=

set_location_assignment PIN_G13 -to VGA_HS
set_location_assignment PIN_C13 -to VGA_VS
set_location_assignment PIN_A12 -to VGA_CLK
set_location_assignment PIN_F11 -to VGA_BLANK_N
set_location_assignment PIN_C10 -to VGA_SYNC_N

# VGA Red Channel (VGA_R[7:0])
set_location_assignment PIN_E12 -to VGA_R[0]
set_location_assignment PIN_E11 -to VGA_R[1]
set_location_assignment PIN_D10 -to VGA_R[2]
set_location_assignment PIN_F12 -to VGA_R[3]
set_location_assignment PIN_G10 -to VGA_R[4]
set_location_assignment PIN_J12 -to VGA_R[5]
set_location_assignment PIN_H8  -to VGA_R[6]
set_location_assignment PIN_H10 -to VGA_R[7]

# VGA Green Channel (VGA_G[7:0])
set_location_assignment PIN_G8  -to VGA_G[0]
set_location_assignment PIN_G11 -to VGA_G[1]
set_location_assignment PIN_F8  -to VGA_G[2]
set_location_assignment PIN_H12 -to VGA_G[3]
set_location_assignment PIN_C8  -to VGA_G[4]
set_location_assignment PIN_B8  -to VGA_G[5]
set_location_assignment PIN_F10 -to VGA_G[6]
set_location_assignment PIN_C9  -to VGA_G[7]

# VGA Blue Channel (VGA_B[7:0])
set_location_assignment PIN_B10 -to VGA_B[0]
set_location_assignment PIN_A10 -to VGA_B[1]
set_location_assignment PIN_C11 -to VGA_B[2]
set_location_assignment PIN_B11 -to VGA_B[3]
set_location_assignment PIN_A11 -to VGA_B[4]
set_location_assignment PIN_C12 -to VGA_B[5]
set_location_assignment PIN_D11 -to VGA_B[6]
set_location_assignment PIN_D12 -to VGA_B[7]