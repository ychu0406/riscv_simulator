# Convert signed int to float
# float i2f(s32 num);
# INPUT:  A0 = integer number
# OUTPUT: A0 = float number (IEEE 754 single-precision)
i2f:
    # Prepare result sign in A1
    srli    a1, a0, 31          # A1 = (A0 >> 31), extract sign bit
    slli    a1, a1, 31          # A1 = A1 << 31, position sign bit at bit 31

    # Get absolute value of the number
    beq     a1, x0, positive    # If sign bit is zero, number is positive
    sub     a0, x0, a0          # A0 = -A0 (negate to get absolute value)

positive:
    # Check if number is zero
    beq     a0, x0, zero_result # If A0 == 0, result is zero

    # Store sign and absolute value
    add     a2, x0, a1          # A2 = A1 (store sign)
    add     a1, x0, a0          # A1 = A0 (store absolute value)

    # Count leading zeros in A0 (result stored in T0)
    # Initialize T0 (leading zero count) to 0
    add     t0, x0, x0          # T0 = 0

clz_loop:
    sll     t1, a1, 1           # Shift A1 left by 1 bit
    addi    t0, t0, 1           # T0 = T0 + 1 (increment count)
    mv      a1, t1              # Update A1 with shifted value
    bgez    a1, clz_loop        # Loop while A1 >= 0 (MSB is 0)

    # Adjust for possible overflow in shift
    li      t1, 32              # Load 32 into t1
    blt     t0, t1, clz_done    # If t0 < 32, proceed to clz_done
    li      a0, 32              # If t0 >= 32, leading zeros = 32
    j       normalize

clz_done:
    # A0 now contains the number of leading zeros (stored in T0)
    add     a0, x0, t0          # Move T0 to A0

normalize:
    # Normalize the number (shift left by leading zeros)
    sub     t1, x0, a0          # t1 = -A0
    sll     a1, a1, t1          # A1 = A1 << (32 - leading zeros)

    # Prepare result exponent
    # Exponent = 158 - leading_zeros
    li      t1, 158
    sub     a0, t1, a0          # A0 = 158 - leading zeros

    # Rounding: Add 0x80 to A1 (rounding bit at position 7)
    addi    a1, a1, 128         # A1 = A1 + 0x80

    # Check for overflow after rounding
    bgez    a1, rounding_ok     # If A1 >= 0, no overflow
    addi    a0, a0, 1           # Exponent increment due to rounding overflow
    j       adjust_mantissa

rounding_ok:
    # Check if lowest 8 bits are zero (for rounding to even)
    andi    a3, a1, 0xFF        # A3 = A1 & 0xFF (lowest 8 bits)
    beq     a3, x0, round_even  # If lowest 8 bits are zero, round to even

adjust_mantissa:
    # Remove leading hidden bit '1'
    slli    a1, a1, 1           # A1 = A1 << 1 (remove hidden '1')
    j       compose_result

round_even:
    # Ensure even mantissa (clear least significant bit)
    srli    a1, a1, 9           # A1 = A1 >> 9
    slli    a1, a1, 10          # A1 = A1 << 10 (remove hidden '1')
    j       compose_result

compose_result:
    # Align mantissa and exponent
    srli    a1, a1, 9           # A1 = A1 >> 9 (align mantissa to bits 0..22)
    slli    a0, a0, 23          # A0 = A0 << 23 (align exponent to bits 23..30), H10
    or      a0, a0, a1          # A0 = exponent | mantissa
    or      a0, a0, a2          # A0 = A0 | sign bit (bit 31)
    jalr    x0, ra, 0           # Return from function

zero_result:
    # Return zero (signed zero with correct sign)
    or      a0, x0, a2          # A0 = sign bit (A2)
    jalr    x0, ra, 0           # Return from function
       

