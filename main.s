  .section .data
array:
    .word 7, 3, 9, 1, 5, 2, 8, 4   # vetor de 8 elementos

n:
    .word 8                        # tamanho do vetor

    .section .bss
    .align 2
temp_buf:
    .skip 32                       # buffer para n*4 bytes (8 elementos)

    .section .text
    .globl main
main:
    # carregar endereço de array em a0
    la    a0, array               # ponteiro para primeiro elemento :contentReference[oaicite:0]{index=0}
    # calcular last_ptr = &array[n]
    la    t0, n                   # t0 = endereço de 'n'
    lw    t1, 0(t0)               # t1 = valor de n           :contentReference[oaicite:1]{index=1}
    slli  t1, t1, 2               # t1 = n * 4 (bytes)        :contentReference[oaicite:2]{index=2}
    add   a1, a0, t1              # a1 = first_ptr + n*4

    # chamar mergesort(first_ptr, last_ptr)
    jal   ra, mergesort           # salvar ra e saltar         :contentReference[oaicite:3]{index=3}

    # saída do programa
    li    a7, 10                  # syscall exit
    ecall

# ------------------------------------------------------------
# mergesort(first_ptr=a0, last_ptr=a1)
# ------------------------------------------------------------
mergesort:
    addi  sp, sp, -16             # criar stack frame
    sw    ra, 12(sp)              # salvar return address
    sw    s0, 8(sp)               # salvar primeiro ponteiro
    sw    s1, 4(sp)               # salvar último ponteiro

    mv    s0, a0                  # s0 = first_ptr
    mv    s1, a1                  # s1 = last_ptr

    sub   t0, s1, s0              # t0 = byte_count
    ble   t0, 4, ms_done          # se ≤ 4 bytes (1 elemento), retorno

    # calcular mid_ptr = first + ((last-first)/8*4)*4
    srli  t1, t0, 2               # t1 = nº elementos /2
    slli  t1, t1, 2               # t1 = byte offset para mid
    add   t2, s0, t1              # t2 = mid_ptr

    mv    a0, s0
    mv    a1, t2
    jal   ra, mergesort           # recursão na primeira metade

    mv    a0, t2
    mv    a1, s1
    jal   ra, mergesort           # recursão na segunda metade

    mv    a0, s0
    mv    a1, t2
    mv    a2, s1
    jal   ra, merge               # chamar merge(first, mid, last)

ms_done:
    lw    ra, 12(sp)
    lw    s0, 8(sp)
    lw    s1, 4(sp)
    addi  sp, sp, 16
    ret                           # retorna via jalr x0, ra,0

# ------------------------------------------------------------
# merge(first_ptr=a0, mid_ptr=a1, last_ptr=a2)
# ------------------------------------------------------------
merge:
    addi  sp, sp, -20
    sw    ra, 16(sp)
    sw    s0, 12(sp)
    sw    s1,  8(sp)
    sw    s2,  4(sp)

    mv    s0, a0                  # s0 = first_ptr
    mv    s1, a1                  # s1 = mid_ptr
    mv    s2, a2                  # s2 = last_ptr
    la    s3, temp_buf            # s3 = buffer temporário

    # copiar [s0, s2) para temp_buf
copy_loop:
    bge   s0, s2, copy_done
    lw    t0, 0(s0)
    sw    t0, 0(s3)
    addi  s0, s0, 4
    addi  s3, s3, 4
    j     copy_loop
copy_done:

    mv    s0, a0                  # repor ponteiros
    mv    s1, a1
    la    s3, temp_buf

merge_loop:
    bge   s3, a1, drain_second
    bge   a1, a2, drain_first
    lw    t0, 0(s3)
    lw    t1, 0(a1)
    blt   t0, t1, use_first
    # usar segundo
    lw    t2, 0(a1)
    sw    t2, 0(a0)
    addi  a1, a1, 4
    j     advance
use_first:
    sw    t0, 0(a0)
    addi  s3, s3, 4
advance:
    addi  a0, a0, 4
    j     merge_loop

drain_first:
    blt   s3, a1, use_first
    j     merge_exit
drain_second:
    blt   a1, a2, use_second
    j     merge_exit
use_second:
    lw    t2, 0(a1)
    sw    t2, 0(a0)
    addi  a1, a1, 4
    addi  a0, a0, 4
    j     merge_loop

merge_exit:
    lw    ra, 16(sp)
    lw    s0, 12(sp)
    lw    s1,  8(sp)
    lw    s2,  4(sp)
    addi  sp, sp, 20
    ret
