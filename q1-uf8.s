# =====================================================
# UF8 Implementation in RISC-V Assembly
# Version 1: Complete Implementation
# =====================================================

.data
    # Test messages
    msg_all_pass:     .string "All tests passed!\n"
    msg_fail:         .string "FAIL at 0x"
    msg_newline:      .string "\n"

.text
.globl main

# =====================================================
# Main Program
# =====================================================
main:
    # Run complete test
    call test

    # Check result
    beqz a0, exit_program

    # All tests passed
    la a0, msg_all_pass
    call print_string

exit_program:
    li a7, 10
    ecall

# =====================================================
# Function: test
# Complete round-trip test for all 256 UF8 values
# Output: a0 = 1 if passed, 0 if failed
# =====================================================
test:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)
    
    li s0, 0           # s0 = i (loop counter, 0-255)
    li s1, -1          # s1 = previous_value
    li s2, 1           # s2 = passed flag (1 = passed, 0 = failed)
    
test_loop:
    li t0, 256
    bge s0, t0, test_done
    
    # fl = i
    mv s3, s0          
    
    # value = uf8_decode(fl)
    mv a0, s3
    call uf8_decode
    mv s4, a0          
    
    # fl2 = uf8_encode(value)
    mv a0, s4
    call uf8_encode
    mv s5, a0          
    
    # Test 1: Round-trip test (fl == fl2)
    beq s3, s5, test_monotonic

    # Round-trip failed: print "FAIL at 0x[hex]\n"
    li s2, 0           # passed = false

    la a0, msg_fail
    call print_string

    mv a0, s3
    call print_hex

    la a0, msg_newline
    call print_string

test_monotonic:
    # Test 2: Monotonic test (value > previous_value)
    bgt s4, s1, test_next

    # Monotonic test failed: print "FAIL at 0x[hex]\n"
    li s2, 0           # passed = false

    la a0, msg_fail
    call print_string

    mv a0, s3
    call print_hex

    la a0, msg_newline
    call print_string
    
test_next:
    # previous_value = value
    mv s1, s4
    
    # i++
    addi s0, s0, 1
    
    j test_loop
    
test_done:
    # Return passed flag
    mv a0, s2
    
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    ret

# =====================================================
# Function: uf8_encode
# Encode uint32_t to uf8
# Input: a0 = 32-bit value
# Output: a0 = uf8 value (8-bit)
# Registers used: a0, t0-t3, s0-s2, ra (needs stack)
# =====================================================
uf8_encode:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    mv s0, a0          # s0 = value
    
    # Special case: value < 16, return directly
    li t0, 16
    blt s0, t0, encode_direct_return
    
    # Get initial exponent estimate using CLZ on (value >> 4)
    srli a0, s0, 4
    call clz
    li t1, 31
    sub s1, t1, a0     # s1 = exponent = 31 - clz(value >> 4)
    
    # Calculate offset = ((1 << exponent) - 1) << 4
    li t1, 1
    sll t1, t1, s1     
    addi t1, t1, -1    
    slli s2, t1, 4     
    
fine_tune_down:
    # Check if value < offset (exponent too high)
    bge s0, s2, fine_tune_up
    beqz s1, calc_mantissa     # Can't go lower than 0
    
    # Adjust down: e = e - 1, recalculate offset
    addi s1, s1, -1
    li t1, 1
    sll t1, t1, s1
    addi t1, t1, -1
    slli s2, t1, 4
    j fine_tune_down
    
fine_tune_up:
    # Check if value >= next_offset (should go higher)
    li t2, 15
    bge s1, t2, calc_mantissa  # Already at maximum
    
    slli t3, s2, 1             # next_offset = (offset << 1) + 16
    addi t3, t3, 16
    blt s0, t3, calc_mantissa  # Current exponent is correct
    
    # Adjust up: e = e + 1
    addi s1, s1, 1
    mv s2, t3
    j fine_tune_up

calc_mantissa:
    # mantissa = (value - offset) >> exponent
    sub t0, s0, s2
    srl t0, t0, s1
    andi t0, t0, 0x0F
    
    # Return (exponent << 4) | mantissa
    slli s1, s1, 4
    or a0, s1, t0
    j encode_exit

encode_direct_return:
    mv a0, s0

encode_exit:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret

# =====================================================
# Function: uf8_decode
# Decode uf8 to uint32_t
# Input: a0 = uf8 value (8-bit)
# Output: a0 = decoded 32-bit value
# Registers used: a0-a3, t0-t3
# =====================================================
uf8_decode:    
    mv t0, a0          # Save input fl
    
    # Extract mantissa (low 4 bits) & exponent (high 4 bits)
    andi t1, t0, 0x0F  # mantissa = fl & 0x0F 
    srli t2, t0, 4     # exponent = fl >> 4
    
    # Calculate offset = (0x7FFF >> (15 - exponent)) << 4
    li t3, 15          # t3 = 15
    sub t3, t3, t2     # t3 = 15 - exponent    
    li t4, 0x7FFF      # t4 = 0x7FFF
    srl t4, t4, t3     # t4 = 0x7FFF >> (15 - exponent)    
    slli t4, t4, 4     # offset = t4 << 4
    
    # Calculate (mantissa << exponent)
    sll t1, t1, t2     # t1 = mantissa << exponent
    
    # Return (mantissa << exponent) + offset
    add a0, t1, t4     # result = t1 + offset
    ret

# =====================================================
# Function: clz (Count Leading Zeros)
# Input: a0 = 32-bit value
# Output: a0 = number of leading zeros
# Registers used: a0-a3, t0-t2
# =====================================================
clz:
    li t0, 32          # n = 32
    li t1, 16          # c = 16
    mv t2, a0          # x = input value
    
clz_loop:
    srl a1, t2, t1     # a1 = y = x >> c
    beqz a1, clz_skip_update
    sub t0, t0, t1     # n = n - c
    mv t2, a1          # x = y
    
clz_skip_update:
    srli t1, t1, 1     # c = c >> 1
    bnez t1, clz_loop
    sub a0, t0, t2     # result = n - x
    ret

# =====================================================
# Helper Functions: I/O
# =====================================================

# Print string (null-terminated)
# Input: a0 = address of string
print_string:
    li a7, 4
    ecall
    ret

# Print hex value (2 digits)
# Input: a0 = value to print in hex
print_hex:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw s0, 0(sp)
    
    mv s0, a0
    
    # Print high nibble
    srli a0, s0, 4
    andi a0, a0, 0x0F
    call print_hex_digit
    
    # Print low nibble
    andi a0, s0, 0x0F
    call print_hex_digit
    
    lw ra, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 8
    ret

# Print single hex digit
# Input: a0 = value (0-15)
print_hex_digit:
    li t0, 10
    blt a0, t0, print_hex_num
    
    # Print A-F (ASCII 'A' = 65)
    addi a0, a0, -10
    addi a0, a0, 65
    li a7, 11
    ecall
    ret
    
print_hex_num:
    # Print 0-9 (ASCII '0' = 48)
    addi a0, a0, 48
    li a7, 11
    ecall
    ret