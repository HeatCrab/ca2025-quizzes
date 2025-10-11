.data
    # Messages
    msg_header:       .string "\n=== bfloat16 Test Suite ===\n\n"
    msg_all_pass:     .string "\n=== ALL TESTS PASSED ===\n"
    msg_failed:       .string "\n=== TESTS FAILED ===\n"
    
    msg_test_basic:   .string "Testing basic conversions...\n"
    msg_basic_pass:   .string "  Basic conversions: PASS\n"
    msg_basic_fail:   .string "  FAIL at index "
    msg_sign_fail:    .string " (sign mismatch)\n"
    msg_stable_fail:  .string " (not stable)\n"
    
    msg_test_round:   .string "Testing rounding behavior...\n"
    msg_round_pass:   .string "  Rounding: PASS\n"
    msg_round_fail:   .string "  FAIL: case "
    msg_expected:     .string ", expected 0x"
    msg_got:          .string ", got 0x"
    msg_newline:      .string "\n"
    
    # Test data for basic conversions
    basic_test_values:
        .word 0x00000000    # 0.0f
        .word 0x3F800000    # 1.0f
        .word 0xBF800000    # -1.0f
        .word 0x40000000    # 2.0f
        .word 0xC0000000    # -2.0f
        .word 0x3F000000    # 0.5f
        .word 0xBF000000    # -0.5f
        .word 0x40490FDA    # 3.14159f
        .word 0xC0490FDA    # -3.14159f
        .word 0x501502F9    # 1e10f
        .word 0xD01502F9    # -1e10f
    basic_test_count: .word 11
    
    # Test data for rounding
    rounding_test_cases:
        .word 0x3F800000    # 1.0 - no rounding
        .half 0x3F80
        .half 0x0000        # padding
        
        .word 0x3F800001    # slightly above 1.0 - round down
        .half 0x3F80
        .half 0x0000
        
        .word 0x3F808000    # tie case, LSB=0 - stay even
        .half 0x3F80
        .half 0x0000
        
        .word 0x3F808001    # above tie - round up
        .half 0x3F81
        .half 0x0000
        
        .word 0x3F818000    # tie case, LSB=1 - round to even
        .half 0x3F82
        .half 0x0000
    rounding_test_count: .word 5

.text
.globl main

# =====================================================
# Main Program
# =====================================================
main:
    # Print header
    la a0, msg_header
    call print_string
    
    # Run test_basic_conversions
    call test_basic_conversions
    bnez a0, main_failed
    
    # Run test_rounding
    call test_rounding
    bnez a0, main_failed
    
    # All tests passed
    la a0, msg_all_pass
    call print_string
    li a0, 0
    j exit_program

main_failed:
    la a0, msg_failed
    call print_string
    li a0, 1

exit_program:
    li a7, 10
    ecall

# =====================================================
# Function: test_basic_conversions
# Test f32 → bf16 → f32 conversions
# Output: a0 = 0 if passed, 1 if failed
# =====================================================
test_basic_conversions:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    
    # Print test name
    la a0, msg_test_basic
    call print_string
    
    la s0, basic_test_values    # s0 = test array pointer
    lw s1, basic_test_count     # s1 = count
    li s2, 0                    # s2 = index
    
test_basic_loop:
    bge s2, s1, test_basic_done
    
    # Load original f32
    lw s3, 0(s0)                # s3 = orig
    
    # Convert: f32 → bf16 → f32
    mv a0, s3
    call f32_to_bf16
    mv s4, a0                   # s4 = bf16
    
    call bf16_to_f32
    mv t0, a0                   # t0 = conv
    
    # Test 1: Sign preservation (skip if orig == 0)
    beqz s3, test_basic_stable
    
    # Extract sign bits
    srli t1, s3, 31             # orig sign
    srli t2, t0, 31             # conv sign
    bne t1, t2, test_basic_sign_fail
    
test_basic_stable:
    # Test 2: bf16 → f32 → bf16 should be stable
    mv a0, s4
    call bf16_to_f32
    call f32_to_bf16
    bne a0, s4, test_basic_stable_fail
    
    # Test passed, continue
    addi s0, s0, 4
    addi s2, s2, 1
    j test_basic_loop

test_basic_sign_fail:
    la a0, msg_basic_fail
    call print_string
    mv a0, s2
    call print_decimal
    la a0, msg_sign_fail
    call print_string
    
    li a0, 1
    j test_basic_exit

test_basic_stable_fail:
    la a0, msg_basic_fail
    call print_string
    mv a0, s2
    call print_decimal
    la a0, msg_stable_fail
    call print_string
    
    li a0, 1
    j test_basic_exit

test_basic_done:
    la a0, msg_basic_pass
    call print_string
    li a0, 0

test_basic_exit:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    addi sp, sp, 32
    ret

# =====================================================
# Function: test_rounding
# Test round-to-nearest-even behavior
# Output: a0 = 0 if passed, 1 if failed
# =====================================================
test_rounding:
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)
    sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
    sw s4, 4(sp)
    
    # Print test name
    la a0, msg_test_round
    call print_string
    
    la s0, rounding_test_cases  # s0 = test data pointer
    lw s1, rounding_test_count  # s1 = count
    li s2, 0                    # s2 = index
    
test_rounding_loop:
    bge s2, s1, test_rounding_done
    
    # Load test case: f32 value and expected bf16
    lw s3, 0(s0)                # s3 = input f32
    lhu s4, 4(s0)               # s4 = expected bf16
    
    # Convert f32 → bf16
    mv a0, s3
    call f32_to_bf16
    mv t0, a0                   # t0 = actual bf16
    
    # Compare with expected
    bne t0, s4, test_rounding_fail
    
    # Test passed, continue
    addi s0, s0, 8              # next test case (4 bytes + 2 bytes + 2 padding)
    addi s2, s2, 1
    j test_rounding_loop

test_rounding_fail:
    la a0, msg_round_fail
    call print_string
    
    mv a0, s2
    call print_decimal
    
    la a0, msg_expected
    call print_string
    
    mv a0, s4
    call print_hex16
    
    la a0, msg_got
    call print_string
    
    mv a0, t0
    call print_hex16
    
    la a0, msg_newline
    call print_string
    
    li a0, 1
    j test_rounding_exit

test_rounding_done:
    la a0, msg_round_pass
    call print_string
    li a0, 0

test_rounding_exit:
    lw ra, 24(sp)
    lw s0, 20(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    lw s4, 4(sp)
    addi sp, sp, 28
    ret

# =====================================================
# Function: bf16_to_f32
# Convert bfloat16 to float32
# Input:  a0 = bf16 value (16-bit)
# Output: a0 = f32 value (32-bit)
# Registers used: a0 (no stack needed)
# =====================================================
bf16_to_f32:
    slli a0, a0, 16
    ret

# =====================================================
# Function: f32_to_bf16
# Convert float32 to bfloat16 with round-to-nearest-even
# Input:  a0 = f32 value (32-bit)
# Output: a0 = bf16 value (16-bit)
# Registers used: a0, t0-t1 (uses stack for saving t0)
# =====================================================
f32_to_bf16:
    addi sp, sp, -4
    sw t0, 0(sp)
    
    # Check if NaN/Inf
    srli t0, a0, 23       
    andi t0, t0, 0xFF
    li t1, 0xFF
    beq t0, t1, f32_shift
    
    # f32bits += ((f32bits >> 16) & 1) + 0x7FFF
    srli t0, a0, 16         
    andi t0, t0, 1          
    lui t1, 0x8             
    addi t1, t1, -1         
    add t0, t0, t1
    add a0, a0, t0          # f32bits += rounding_offset

f32_shift:
    srli a0, a0, 16
    bne t0, t1, finish_f32_to_bf16  # if not NaN/Inf, finish
    
    # If NaN/Inf, just mask to 16 bits
    lui t0, 0x10
    addi t0, t0, -1         
    and a0, a0, t0
    
finish_f32_to_bf16:
    lw t0, 0(sp)
    addi sp, sp, 4
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

# Print decimal number
# Input: a0 = value to print
print_decimal:
    li a7, 1
    ecall
    ret

# Print 16-bit hex value (4 digits)
# Input: a0 = value to print in hex
print_hex16:
    addi sp, sp, -12
    sw ra, 8(sp)
    sw s0, 4(sp)
    sw s1, 0(sp)
    
    mv s0, a0
    li s1, 4                    # 4 hex digits
    
print_hex16_loop:
    beqz s1, print_hex16_done
    
    # Calculate shift amount: (s1 - 1) * 4
    addi t0, s1, -1
    slli t0, t0, 2              # multiply by 4
    
    srl a0, s0, t0
    andi a0, a0, 0x0F
    call print_hex_digit
    
    addi s1, s1, -1
    j print_hex16_loop
    
print_hex16_done:
    lw ra, 8(sp)
    lw s0, 4(sp)
    lw s1, 0(sp)
    addi sp, sp, 12
    ret

# Print single hex digit
# Input: a0 = value (0-15)
print_hex_digit:
    li t0, 10
    blt a0, t0, print_hex_num
    
    # Print A-F
    addi a0, a0, -10
    addi a0, a0, 65             # ASCII 'A'
    li a7, 11
    ecall
    ret
    
print_hex_num:
    # Print 0-9
    addi a0, a0, 48             # ASCII '0'
    li a7, 11
    ecall
    ret