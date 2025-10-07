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
# Registers used: a0-a1, t0-t6, s0-s3 (needs stack)
# =====================================================
uf8_encode:
    # Save registers
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)
    
    mv s0, a0          # s0 = value (input)
    
    # Special case: value < 16, return value directly
    li t0, 16
    bge s0, t0, encode_normal
    mv a0, s0
    j encode_done
    
encode_normal:
    mv a0, s0
    call clz
    mv t0, a0          # t0 = lz (leading zeros)
    li t1, 31
    sub t1, t1, t0     # t1 = msb
    
    # Initialize exponent = 0, overflow = 0
    li s1, 0           # s1 = exponent
    li s2, 0           # s2 = overflow
    
    # if (msb >= 5)
    li t2, 5
    blt t1, t2, find_exp_loop    
    addi s1, t1, -4    # exponent = msb - 4
    
    # if (exponent > 15) exponent = 15
    li t3, 15
    ble s1, t3, encode_calc_overflow
    li s1, 15
   
encode_calc_overflow:
    li t4, 0           # t4 = e (loop counter)
    
calc_overflow_loop:
    bge t4, s1, adjust_loop
    slli s2, s2, 1     # overflow <<= 1
    addi s2, s2, 16    # overflow += 16 
    addi t4, t4, 1     # e++
    j calc_overflow_loop

adjust_loop:
    beqz s1, find_exp_loop       # if exponent == 0, exit
    bge s0, s2, find_exp_loop    # if value >= overflow, exit
    
    # overflow = (overflow - 16) >> 1
    addi s2, s2, -16
    srli s2, s2, 1
    
    addi s1, s1, -1
    j adjust_loop
    
find_exp_loop:
    li t5, 15
    bge s1, t5, find_exp_done
    
    # next_overflow = (overflow << 1) + 16
    slli t6, s2, 1     
    addi t6, t6, 16
    
    # if (value < next_overflow) break
    blt s0, t6, find_exp_done
    
    # overflow = next_overflow
    mv s2, t6
    
    addi s1, s1, 1    
    j find_exp_loop
    
find_exp_done:
    # Calculate mantissa = (value - overflow) >> exponent
    sub t0, s0, s2     
    srl t0, t0, s1     
    andi s3, t0, 0x0F
    
    # Return (exponent << 4) | mantissa
    slli s1, s1, 4     
    or a0, s1, s3  
    
encode_done:
    # Restore registers
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
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