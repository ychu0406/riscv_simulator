# Takes input N (a0), returns its log base 2 in a0
logint:
    addi sp, sp, -4
    sw t0, 0(sp)

    add t0, a0, zero# k = N
    add a0, zero, zero# i = 0

logloop:
    beq t0, zero, logloop_end # Exit if k == 0
    srai t0, t0, 1 # k >>= 1
    addi a0, a0, 1 # i++
    j logloop

logloop_end:
    addi a0, a0, -1 # Return i - 1
    lw t0, 0(sp)
    addi sp, sp, 4
    jr ra

# Takes inputs N(a0) and n(a1), reverses the number in binary
reverse:
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    call logint# Now a0 has log2(N)
    addi s0, zero, 1 # j = 1
    add s1, zero, zero # p = 0

forloop_reverse:
    bgt s0, a0, forloop_reverse_end

    sub s2, a0, s0# s2 = a0 - s0
    add is3, zero, 1
    sll s3, s3, s2
    and s3, a1, s3
    beq s3, zero, elses3 # If not, skip

ifs3:
    addi s4, s0, -1 # s4 = j - 1
    addi s5, zero, 1
    sll s5, s5, s4
    or s1, s1, s5

elses3:
    addi s0, s0, 1
    j forloop_reverse

forloop_reverse_end:
    add a0, s1, zero # Return p

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    jr ra
