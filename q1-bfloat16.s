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
    
    msg_test_special: .string "Testing special values...\n"
    msg_special_pass: .string "  Special values: PASS\n"
    msg_special_fail: .string "  FAIL: "
    msg_pos_inf_fail: .string "Positive infinity not detected\n"
    msg_inf_as_nan_fail: .string "Infinity detected as NaN\n"
    msg_neg_inf_fail: .string "Negative infinity not detected\n"
    msg_nan_fail:     .string "NaN not detected\n"
    msg_nan_as_inf_fail: .string "NaN detected as infinity\n"
    msg_zero_fail:    .string "Zero not detected\n"
    msg_neg_zero_fail: .string "Negative zero not detected\n"

    msg_test_compare: .string "Testing comparison operations...\n"
    msg_compare_pass: .string "  Comparisons: PASS\n"
    msg_compare_fail: .string "  FAIL: "
    msg_eq_fail:      .string "Equality test failed\n"
    msg_ineq_fail:    .string "Inequality test failed\n"
    msg_lt_fail:      .string "Less than test failed\n"
    msg_not_lt_fail:  .string "Not less than test failed\n"
    msg_eq_not_lt_fail: .string "Equal not less than test failed\n"
    msg_gt_fail:      .string "Greater than test failed\n"
    msg_not_gt_fail:  .string "Not greater than test failed\n"
    msg_nan_eq_fail:  .string "NaN equality test failed\n"
    msg_nan_lt_fail:  .string "NaN less than test failed\n"
    msg_nan_gt_fail:  .string "NaN greater than test failed\n"

    msg_test_arith:   .string "Testing arithmetic operations...\n"
    msg_add_pass:     .string "  Arithmetic (add): PASS\n"
    msg_add_fail:     .string "  Arithmetic (add) FAIL: case "
    msg_sub_pass:     .string "  Arithmetic (sub): PASS\n"
    msg_sub_fail:     .string "  Arithmetic (sub) FAIL: case "
    
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

    # Test data for arithmetic operations
    add_test_cases:
        # Test case 0: 1.0 + 2.0 = 3.0
        .word 0x3F800000    # a = 1.0f
        .word 0x40000000    # b = 2.0f
        .half 0x4040        # expected result = 3.0 (bf16)
        .half 0x0000        # padding
        
        # Test case 1: -1.0 + 1.0 = 0.0
        .word 0xBF800000    # a = -1.0f
        .word 0x3F800000    # b = 1.0f
        .half 0x0000        # expected result = 0.0
        .half 0x0000        # padding
        
        # Test case 2: 0.5 + 0.5 = 1.0
        .word 0x3F000000    # a = 0.5f
        .word 0x3F000000    # b = 0.5f
        .half 0x3F80        # expected result = 1.0
        .half 0x0000        # padding
        
        # Test case 3: 1.5 + 2.5 = 4.0
        .word 0x3FC00000    # a = 1.5f
        .word 0x40200000    # b = 2.5f
        .half 0x4080        # expected result = 4.0
        .half 0x0000        # padding
        
        # Test case 4: -2.0 + -3.0 = -5.0
        .word 0xC0000000    # a = -2.0f
        .word 0xC0400000    # b = -3.0f
        .half 0xC0A0        # expected result = -5.0
        .half 0x0000        # padding
    
    add_test_count: .word 5

# Test data for subtraction
    sub_test_cases:
        # Test case 0: 3.0 - 1.0 = 2.0
        .word 0x40400000    # a = 3.0f
        .word 0x3F800000    # b = 1.0f
        .half 0x4000        # expected result = 2.0 (bf16)
        .half 0x0000        # padding
        
        # Test case 1: 1.0 - 1.0 = 0.0
        .word 0x3F800000    # a = 1.0f
        .word 0x3F800000    # b = 1.0f
        .half 0x0000        # expected result = 0.0
        .half 0x0000        # padding
        
        # Test case 2: 0.5 - 1.5 = -1.0
        .word 0x3F000000    # a = 0.5f
        .word 0x3FC00000    # b = 1.5f
        .half 0xBF80        # expected result = -1.0
        .half 0x0000        # padding
        
        # Test case 3: -2.0 - 3.0 = -5.0
        .word 0xC0000000    # a = -2.0f
        .word 0x40400000    # b = 3.0f
        .half 0xC0A0        # expected result = -5.0
        .half 0x0000        # padding
        
        # Test case 4: 5.0 - (-2.0) = 7.0
        .word 0x40A00000    # a = 5.0f
        .word 0xC0000000    # b = -2.0f
        .half 0x40E0        # expected result = 7.0
        .half 0x0000        # padding
    
    sub_test_count: .word 5
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
    
    # Run test_special_values
    call test_special_values
    bnez a0, main_failed
    
    # Run test_comparisons
    call test_comparisons
    bnez a0, main_failed

    # Run test_arithmetic
    call test_arithmetic
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
# Function: test_comparisons
# Test comparison operations (from q1-bfloat16.c)
# Output: a0 = 0 if passed, 1 if failed
# =====================================================
test_comparisons:
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)
    sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
    
    # Print test name
    la a0, msg_test_compare
    call print_string
    
    # bf16_t a = f32_to_bf16(1.0f);
    li a0, 0x3F800000
    call f32_to_bf16
    mv s0, a0               # s0 = a (1.0)
    
    # bf16_t b = f32_to_bf16(2.0f);
    li a0, 0x40000000
    call f32_to_bf16
    mv s1, a0               # s1 = b (2.0)
    
    # bf16_t c = f32_to_bf16(1.0f);
    li a0, 0x3F800000
    call f32_to_bf16
    mv s2, a0               # s2 = c (1.0)
    
    # Test 1: bf16_eq(a, c) should be true
    mv a0, s0
    mv a1, s2
    call bf16_eq
    beqz a0, test_compare_fail_eq
    
    # Test 2: bf16_eq(a, b) should be false
    mv a0, s0
    mv a1, s1
    call bf16_eq
    bnez a0, test_compare_fail_ineq
    
    # Test 3: bf16_lt(a, b) should be true
    mv a0, s0
    mv a1, s1
    call bf16_lt
    beqz a0, test_compare_fail_lt
    
    # Test 4: bf16_lt(b, a) should be false
    mv a0, s1
    mv a1, s0
    call bf16_lt
    bnez a0, test_compare_fail_not_lt
    
    # Test 5: bf16_lt(a, c) should be false
    mv a0, s0
    mv a1, s2
    call bf16_lt
    bnez a0, test_compare_fail_eq_not_lt
    
    # Test 6: bf16_gt(b, a) should be true
    mv a0, s1
    mv a1, s0
    call bf16_gt
    beqz a0, test_compare_fail_gt
    
    # Test 7: bf16_gt(a, b) should be false
    mv a0, s0
    mv a1, s1
    call bf16_gt
    bnez a0, test_compare_fail_not_gt
    
    # Test 8-10: NaN tests
    # bf16_t nan_val = BF16_NAN();
    li s3, 0x7FC0           # s3 = NaN
    
    # Test 8: bf16_eq(nan_val, nan_val) should be false
    mv a0, s3
    mv a1, s3
    call bf16_eq
    bnez a0, test_compare_fail_nan_eq
    
    # Test 9: bf16_lt(nan_val, a) should be false
    mv a0, s3
    mv a1, s0
    call bf16_lt
    bnez a0, test_compare_fail_nan_lt
    
    # Test 10: bf16_gt(nan_val, a) should be false
    mv a0, s3
    mv a1, s0
    call bf16_gt
    bnez a0, test_compare_fail_nan_gt
    
    # All tests passed
    la a0, msg_compare_pass
    call print_string
    li a0, 0
    j test_comparisons_exit

test_compare_fail_eq:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_eq_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_ineq:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_ineq_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_lt:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_lt_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_not_lt:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_not_lt_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_eq_not_lt:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_eq_not_lt_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_gt:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_gt_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_not_gt:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_not_gt_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_nan_eq:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_nan_eq_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_nan_lt:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_nan_lt_fail
    call print_string
    li a0, 1
    j test_comparisons_exit

test_compare_fail_nan_gt:
    la a0, msg_compare_fail
    call print_string
    la a0, msg_nan_gt_fail
    call print_string
    li a0, 1

test_comparisons_exit:
    lw ra, 24(sp)
    lw s0, 20(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    addi sp, sp, 28
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
    addi s0, s0, 8              # next test case
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
# Function: test_special_values
# Test special value detection (from q1-bfloat16.c)
# Output: a0 = 0 if passed, 1 if failed
# =====================================================
test_special_values:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    
    # Print test name
    la a0, msg_test_special
    call print_string
    
    # Test 1: Positive infinity (0x7F80)
    li s0, 0x7F80
    mv a0, s0
    call bf16_isinf
    beqz a0, test_special_fail_pos_inf
    
    # Test 1b: Should not be NaN
    mv a0, s0
    call bf16_isnan
    bnez a0, test_special_fail_inf_as_nan
    
    # Test 2: Negative infinity (0xFF80)
    li s0, 0xFF80
    mv a0, s0
    call bf16_isinf
    beqz a0, test_special_fail_neg_inf
    
    # Test 3: NaN (0x7FC0)
    li s0, 0x7FC0
    mv a0, s0
    call bf16_isnan
    beqz a0, test_special_fail_nan
    
    # Test 3b: Should not be Inf
    mv a0, s0
    call bf16_isinf
    bnez a0, test_special_fail_nan_as_inf
    
    # Test 4: Zero (convert 0.0f)
    li a0, 0x00000000
    call f32_to_bf16
    call bf16_iszero
    beqz a0, test_special_fail_zero
    
    # Test 5: Negative zero (convert -0.0f)
    li a0, 0x80000000
    call f32_to_bf16
    call bf16_iszero
    beqz a0, test_special_fail_neg_zero
    
    # All tests passed
    la a0, msg_special_pass
    call print_string
    li a0, 0
    j test_special_exit

test_special_fail_pos_inf:
    la a0, msg_special_fail
    call print_string
    la a0, msg_pos_inf_fail
    call print_string
    li a0, 1
    j test_special_exit

test_special_fail_inf_as_nan:
    la a0, msg_special_fail
    call print_string
    la a0, msg_inf_as_nan_fail
    call print_string
    li a0, 1
    j test_special_exit

test_special_fail_neg_inf:
    la a0, msg_special_fail
    call print_string
    la a0, msg_neg_inf_fail
    call print_string
    li a0, 1
    j test_special_exit

test_special_fail_nan:
    la a0, msg_special_fail
    call print_string
    la a0, msg_nan_fail
    call print_string
    li a0, 1
    j test_special_exit

test_special_fail_nan_as_inf:
    la a0, msg_special_fail
    call print_string
    la a0, msg_nan_as_inf_fail
    call print_string
    li a0, 1
    j test_special_exit

test_special_fail_zero:
    la a0, msg_special_fail
    call print_string
    la a0, msg_zero_fail
    call print_string
    li a0, 1
    j test_special_exit

test_special_fail_neg_zero:
    la a0, msg_special_fail
    call print_string
    la a0, msg_neg_zero_fail
    call print_string
    li a0, 1

test_special_exit:
    lw ra, 12(sp)
    lw s0, 8(sp)
    addi sp, sp, 16
    ret

# =====================================================
# Function: test_arithmetic
# Test all arithmetic operations (add, sub, mul, div, sqrt)
# Output: a0 = 0 if all passed, 1 if any failed
# =====================================================
test_arithmetic:
    addi sp, sp, -36
    sw ra, 32(sp)
    sw s0, 28(sp)
    sw s1, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    sw s4, 12(sp)
    sw s5, 8(sp)
    sw s6, 4(sp)       # s6 = total failures
    
    # Print test header
    la a0, msg_test_arith
    call print_string
    
    li s6, 0            # s6 = 0 (no failures yet)
    
    # ===== Test ADD =====
    la s0, add_test_cases
    lw s1, add_test_count
    li s2, 0
    
test_arith_add_loop:
    bge s2, s1, test_arith_add_done
    
    lw s3, 0(s0)
    lw s4, 4(s0)
    lhu s5, 8(s0)
    
    mv a0, s3
    call f32_to_bf16
    mv t0, a0
    
    mv a0, s4
    call f32_to_bf16
    mv t1, a0
    
    mv a0, t0
    mv a1, t1
    call bf16_add
    mv t2, a0
    
    bne t2, s5, test_arith_add_fail
    
    addi s0, s0, 12
    addi s2, s2, 1
    j test_arith_add_loop

test_arith_add_fail:
    la a0, msg_add_fail
    call print_string
    mv a0, s2
    call print_decimal
    la a0, msg_expected
    call print_string
    mv a0, s5
    call print_hex16
    la a0, msg_got
    call print_string
    mv a0, t2
    call print_hex16
    la a0, msg_newline
    call print_string
    addi s6, s6, 1      # increment failure count
    j test_arith_sub_start

test_arith_add_done:
    la a0, msg_add_pass
    call print_string
    
    # ===== Test SUB =====
test_arith_sub_start:
    la s0, sub_test_cases
    lw s1, sub_test_count
    li s2, 0
    
test_arith_sub_loop:
    bge s2, s1, test_arith_sub_done
    
    lw s3, 0(s0)
    lw s4, 4(s0)
    lhu s5, 8(s0)
    
    mv a0, s3
    call f32_to_bf16
    mv t0, a0
    
    mv a0, s4
    call f32_to_bf16
    mv t1, a0
    
    mv a0, t0
    mv a1, t1
    call bf16_sub
    mv t2, a0
    
    bne t2, s5, test_arith_sub_fail
    
    addi s0, s0, 12
    addi s2, s2, 1
    j test_arith_sub_loop

test_arith_sub_fail:
    la a0, msg_sub_fail
    call print_string
    mv a0, s2
    call print_decimal
    la a0, msg_expected
    call print_string
    mv a0, s5
    call print_hex16
    la a0, msg_got
    call print_string
    mv a0, t2
    call print_hex16
    la a0, msg_newline
    call print_string
    addi s6, s6, 1
    j test_arith_done 

test_arith_sub_done:
    la a0, msg_sub_pass
    call print_string
    
    # TODO: test_arith_mul_start
    # TODO: test_arith_div_start
    # TODO: test_arith_sqrt_start
    
test_arith_done:
    # Return failure count (0 = all pass, >0 = some failed)
    mv a0, s6
    
    lw ra, 32(sp)
    lw s0, 28(sp)
    lw s1, 24(sp)
    lw s2, 20(sp)
    lw s3, 16(sp)
    lw s4, 12(sp)
    lw s5, 8(sp)
    lw s6, 4(sp)
    addi sp, sp, 36
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
    
    # Check if NaN/Inf (exponent == 0xFF)
    srli t0, a0, 23
    andi t0, t0, 0xFF
    li t1, 0xFF
    beq t0, t1, f32_shift
    
    # Normal value: apply rounding
    # f32bits += ((f32bits >> 16) & 1) + 0x7FFF
    srli t0, a0, 16
    andi t0, t0, 1
    lui t1, 0x8
    addi t1, t1, -1
    add t0, t0, t1
    add a0, a0, t0

f32_shift:
    srli a0, a0, 16
    bne t0, t1, finish_f32_to_bf16
    
    # If NaN/Inf, mask to 16 bits
    lui t0, 0x10
    addi t0, t0, -1
    and a0, a0, t0
    
finish_f32_to_bf16:
    lw t0, 0(sp)
    addi sp, sp, 4
    ret

# =====================================================
# Function: bf16_isnan
# Check if bfloat16 is NaN
# Input:  a0 = bf16 value (16-bit)
# Output: a0 = 1 if NaN, 0 otherwise
# Registers used: a0, t0-t1 (no stack needed)
# =====================================================
bf16_isnan:
    # Check: (a & BF16_EXP_MASK) == BF16_EXP_MASK
    li t0, 0x7F80
    and t1, a0, t0              # t1 = a & 0x7F80
    bne t1, t0, bf16_isnan_false
    
    # Check: (a & BF16_MANT_MASK) != 0
    andi t1, a0, 0x007F         # t1 = a & 0x007F
    snez a0, t1                 # a0 = (t1 != 0) ? 1 : 0
    ret

bf16_isnan_false:
    li a0, 0
    ret

# =====================================================
# Function: bf16_isinf
# Check if bfloat16 is Infinity
# Input:  a0 = bf16 value (16-bit)
# Output: a0 = 1 if Inf, 0 otherwise
# Registers used: a0, t0-t1 (no stack needed)
# =====================================================
bf16_isinf:
    # Check: (a & BF16_EXP_MASK) == BF16_EXP_MASK
    li t0, 0x7F80
    and t1, a0, t0              # t1 = a & 0x7F80
    bne t1, t0, bf16_isinf_false
    
    # Check: !(a & BF16_MANT_MASK)
    andi t1, a0, 0x007F         # t1 = a & 0x007F
    seqz a0, t1                 # a0 = (t1 == 0) ? 1 : 0
    ret

bf16_isinf_false:
    li a0, 0
    ret

# =====================================================
# Function: bf16_iszero
# Check if bfloat16 is zero (±0)
# Input:  a0 = bf16 value (16-bit)
# Output: a0 = 1 if zero, 0 otherwise
# Registers used: a0, t0-t1 (no stack needed)
# =====================================================
bf16_iszero:
    lui t0, 0x8
    addi t0, t0, -1             # t0 = 0x7FFF
    and t1, a0, t0              # t1 = a & 0x7FFF
    seqz a0, t1                 # a0 = (t1 == 0) ? 1 : 0
    ret

# =====================================================
# Function: bf16_add
# Add two bfloat16 values (strictly follows q1-bfloat16.c)
# Input:  a0 = bf16 value a, a1 = bf16 value b
# Output: a0 = bf16 result (a + b)
# Registers used: s0-s7, t0-t4 (uses stack for saving s0-s7)
# =====================================================
bf16_add:
    addi sp, sp, -36
    sw ra, 32(sp)
    sw s0, 28(sp)
    sw s1, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    sw s4, 12(sp)
    sw s5, 8(sp)
    sw s6, 4(sp)
    sw s7, 0(sp)

    mv s0, a0               # s0 = a
    mv s1, a1               # s1 = b

    srli s2, s0, 15         # s2 = sign_a
    andi s2, s2, 1
    srli s3, s0, 7          # s3 = exp_a
    andi s3, s3, 0xFF
    andi s4, s0, 0x7F       # s4 = mant_a

    srli s5, s1, 15         # s5 = sign_b
    andi s5, s5, 1
    srli s6, s1, 7          # s6 = exp_b
    andi s6, s6, 0xFF
    andi s7, s1, 0x7F       # s7 = mant_b
    
    li t0, 0xFF
    bne s3, t0, bf16_add_check_exp_b    # if (exp_a != 0xFF) check exp_b
    bnez s4, bf16_add_return_a          # a is NaN, return a
    bne s6, t0, bf16_add_return_a       # if (exp_b != 0xFF) return a
    bne s2, s5, bf16_add_return_nan 
    bnez s7, bf16_add_return_b          # b is NaN, return b

bf16_add_return_nan:
    li a0, 0x7FC0
    j bf16_add_exit

bf16_add_check_exp_b:
    li t0, 0xFF
    bne s6, t0, bf16_add_implicit
    j bf16_add_return_b          

bf16_add_return_a:
    mv a0, s0
    j bf16_add_exit

bf16_add_return_b:
    mv a0, s1
    j bf16_add_exit

bf16_add_check_inf:
    or t0, s3, s6          # if (exp_a == 0 && exp_b == 0)
    bnez t0, bf16_add_return_b
    or t0, s4, s7
    bnez t0, bf16_add_return_a
    
bf16_add_implicit:
    beqz s3, bf16_add_align_exponents
    ori s4, s4, 0x80       # if (exp_a != 0) mant_a |= 0x80
    beqz s6, bf16_add_align_exponents
    ori s7, s7, 0x80       # if (exp_b != 0) mant_b |= 0x80

# t1 = result_sign
# t2 = result_exp
# t3 = result_mant    
bf16_add_align_exponents:
    beq s3, s6, bf16_add_get_result_exp
    blt s3, s6, bf16_add_exp_b_larger       # exp_b > exp_a
    
    # exp_a >= exp_b
    mv t2, s3               # s8 = result_exp = exp_a
    sub t0, s3, s6          # t0 = exp_diff
    
    # Shift mant_b right by exp_diff
    li t1, 8
    bge t0, t1, bf16_add_return_a
    srl s7, s7, t0
    j bf16_add_perform_op
    
bf16_add_exp_b_larger:
    # exp_b > exp_a
    mv t2, s6               # s8 = result_exp = exp_b
    sub t0, s6, s3          # t0 = exp_diff
    
    # Shift mant_a right by exp_diff
    li t1, 8
    bge t0, t1, bf16_add_return_b
    srl s4, s4, t0
    j bf16_add_perform_op

bf16_add_get_result_exp:
    mv t2, s3               # s8 = result_exp = exp_a (== exp_b)

bf16_add_perform_op:
    # Step 5: Perform addition or subtraction based on signs
    bne s2, s5, bf16_add_different_signs
    
    mv t1, s2               # t1 = sign_a
    add t3, s4, s7          # s9 = result_mant

    andi t0, t3, 0x100
    beqz t0, bf16_add_assemble
    srli t3, t3, 1
    addi t2, t2, 1
    li t4, 0xFF
    bltu t2, t4, bf16_add_assemble
    slli t1, t1, 15
    li t4 , 0x7F80
    or a0, t1, t4
    j bf16_add_exit
    
bf16_add_different_signs:
    bge s4, s7, bf16_add_a_larger
    mv t1, s5               # result_sign = sign_b
    sub t3, s7, s4          # result_mant = mant_b - mant_a
    j bf16_add_normalize
    
bf16_add_a_larger:
    mv t1, s2               # result_sign = sign_a
    sub t3, s4, s7          # result_mant = mant_a - mant_b
    
bf16_add_normalize:
    bnez t3, bf16_add_normalize_underflow
    li a0, 0
    j bf16_add_exit
    
bf16_add_normalize_underflow:
    andi t4, t3, 0x80
    bnez t4, bf16_add_assemble

    slli t3, t3, 1
    addi t2, t2, -1
    bgtz t2, bf16_add_normalize_underflow
    
    li a0, 0
    j bf16_add_exit

bf16_add_assemble:
    slli t1, t1, 15
    andi t2, t2, 0xFF
    slli t2, t2, 7
    or a0, t1, t2
    andi t3, t3, 0x7F
    or a0, a0, t3
    j bf16_add_exit
    
bf16_add_exit:
    lw ra, 32(sp)
    lw s0, 28(sp)
    lw s1, 24(sp)
    lw s2, 20(sp)
    lw s3, 16(sp)
    lw s4, 12(sp)
    lw s5, 8(sp)
    lw s6, 4(sp)
    lw s7, 0(sp)
    addi sp, sp, 36
    ret

# =====================================================
# Function: bf16_sub
# Subtract two bfloat16 values (a - b)
# Input:  a0 = bf16 value a, a1 = bf16 value b
# Output: a0 = bf16 result (a - b)
# =====================================================
bf16_sub:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # b.bits ^= 0x8000 (flip sign bit)
    lui t0, 0x8         # t0 = 0x8000
    xor a1, a1, t0      # a1 ^= 0x8000
    
    # return bf16_add(a, b)
    call bf16_add
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# =====================================================
# Function: bf16_eq
# Check if two bfloat16 values are equal
# Input:  a0 = bf16 value a, a1 = bf16 value b
# Output: a0 = 1 if equal, 0 otherwise
# Registers used: a0-a1, t0-t2, s0-s1, ra (uses stack)
# =====================================================
bf16_eq:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0               
    mv s1, a1              
    
    # Check if a is NaN
    mv a0, s0
    call bf16_isnan
    bnez a0, bf16_eq_false
    
    # Check if b is NaN
    mv a0, s1
    call bf16_isnan
    bnez a0, bf16_eq_false
    
    # Check if both are zero
    mv a0, s0
    call bf16_iszero
    beqz a0, bf16_eq_compare_bits
    
    mv a0, s1
    call bf16_iszero
    bnez a0, bf16_eq_true   # both zero
    
bf16_eq_compare_bits:
    # Compare bits directly
    beq s0, s1, bf16_eq_true
    
bf16_eq_false:
    li a0, 0
    j bf16_eq_exit

bf16_eq_true:
    li a0, 1

bf16_eq_exit:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret

# =====================================================
# Function: bf16_lt
# Check if a < b
# Input:  a0 = bf16 value a, a1 = bf16 value b
# Output: a0 = 1 if a < b, 0 otherwise
# Registers used: a0-a1, t0-t2, s0-s1, ra (uses stack)
# =====================================================
bf16_lt:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0               # save a
    mv s1, a1               # save b
    
    # Check if a is NaN
    mv a0, s0
    call bf16_isnan
    bnez a0, bf16_lt_false
    
    # Check if b is NaN
    mv a0, s1
    call bf16_isnan
    bnez a0, bf16_lt_false
    
    # Check if both are zero
    mv a0, s0
    call bf16_iszero
    beqz a0, bf16_lt_check_signs
    
    mv a0, s1
    call bf16_iszero
    bnez a0, bf16_lt_false  # both zero
    
bf16_lt_check_signs:
    # Extract signs
    srli t0, s0, 15         
    andi t0, t0, 1
    srli t1, s1, 15         
    andi t1, t1, 1
    
    # If signs differ: a < b iff sign_a > sign_b (negative < positive)
    bne t0, t1, bf16_lt_diff_signs
    
    # Same sign: compare bits
    # If positive (sign=0): a < b iff a.bits < b.bits
    # If negative (sign=1): a < b iff a.bits > b.bits
    beqz t0, bf16_lt_positive
    
bf16_lt_negative:
    bgt s0, s1, bf16_lt_true
    j bf16_lt_false

bf16_lt_positive:
    blt s0, s1, bf16_lt_true
    j bf16_lt_false

bf16_lt_diff_signs:
    bgt t0, t1, bf16_lt_true
    j bf16_lt_false

bf16_lt_false:
    li a0, 0
    j bf16_lt_exit

bf16_lt_true:
    li a0, 1

bf16_lt_exit:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret

# =====================================================
# Function: bf16_gt
# Check if a > b
# Input:  a0 = bf16 value a, a1 = bf16 value b
# Output: a0 = 1 if a > b, 0 otherwise
# Registers used: a0-a1, ra (uses stack)
# =====================================================
bf16_gt:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Swap arguments and call bf16_lt
    mv t0, a0
    mv a0, a1
    mv a1, t0
    call bf16_lt
    
    lw ra, 0(sp)
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