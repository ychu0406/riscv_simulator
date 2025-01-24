.text
    la a0, multiplier         # Load multiplier address
    lw a1, 0(a0)              # Load multiplier value
    la a2, multiplicand       # Load multiplicand address
    lw a3, 0(a2)              # Load multiplicand value
    li t0, 0                  # Initialize accumulator
    li t1, 32                 # Set bit counter 

    # Check for negative values
    bltz a1, handle_negative1 # If multiplier negative 
    j shift_and_add_loop      # Skip to main loop 
    bltz a3, handle_negative2 # If multiplicand negative 
    j shift_and_add_loop      # Continue to main loop 

handle_negative1:
    neg a1, a1                # Make multiplier positive

handle_negative2:
    neg a3, a3                # Make multiplicand positive

shift_and_add_loop:
    beqz t1, end_shift_and_add # Exit if bit count is zero
    andi t2, a1, 1            # Check least significant bit 
    beqz t2, skip_add         # Skip add if bit is 0
    add t0, t0, a3            # Add to accumulator

skip_add:
    srai a1, a1, 1            # Right shift multiplier
    slli a3, a3, 1            # Left shift multiplicand
    addi t1, t1, -1           # Decrease bit counter
    j shift_and_add_loop      # Repeat loop 

end_shift_and_add:
    la a4, result             # Load result address
    sw t0, 0(a4)              # Store final result
