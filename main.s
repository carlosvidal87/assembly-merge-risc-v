# Implementação recursiva do Merge Sort em RISC-V
# Otimizado para uso eficiente de cache (localidade espacial)
# Array de 8 elementos

.data
array:    .word 5, 2, 9, 1, 7, 3, 8, 6    # Array inicial com 8 elementos
temp:     .word 0, 0, 0, 0, 0, 0, 0, 0    # Array temporário para o merge
newline:  .string "\n"
space:    .string " "
msg_orig: .string "Array original: "
msg_sort: .string "Array ordenado: "

.text
.globl main

main:
    # Imprime o array original
    la a0, msg_orig
    li a7, 4
    ecall
    
    la a0, array
    li a1, 8
    jal print_array
    
    # Chama o merge sort
    la a0, array        # Endereço do array
    li a1, 0            # Índice inicial
    li a2, 7            # Índice final (tamanho - 1)
    jal merge_sort
    
    # Imprime o array ordenado
    la a0, msg_sort
    li a7, 4
    ecall
    
    la a0, array
    li a1, 8
    jal print_array
    
    # Encerra o programa
    li a7, 10
    ecall

# Função merge_sort recursiva
# a0 = endereço do array
# a1 = índice inicial
# a2 = índice final
merge_sort:
    # Verifica se o índice inicial é menor que o índice final
    # (caso base da recursão)
    bge a1, a2, merge_sort_done
    
    # Salva registradores na pilha
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    
    # Inicializa registradores
    mv s0, a0       # s0 = endereço do array
    mv s1, a1       # s1 = índice inicial
    mv s2, a2       # s2 = índice final
    
    # Calcula o índice do meio
    add s3, s1, s2
    srai s3, s3, 1  # s3 = (início + fim) / 2
    
    # Chama merge_sort para a primeira metade
    mv a0, s0
    mv a1, s1
    mv a2, s3
    jal merge_sort
    
    # Chama merge_sort para a segunda metade
    mv a0, s0
    addi a1, s3, 1
    mv a2, s2
    jal merge_sort
    
    # Chama merge para mesclar as duas metades
    mv a0, s0
    mv a1, s1
    mv a2, s3
    mv a3, s2
    jal merge
    
    # Restaura registradores da pilha
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20
    
merge_sort_done:
    ret

# Função merge para mesclar dois subarrays
# a0 = endereço do array
# a1 = início
# a2 = meio
# a3 = fim
merge:
    # Salva registradores na pilha
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    
    # Inicializa registradores
    mv s0, a0       # s0 = endereço do array
    mv s1, a1       # s1 = início
    mv s2, a2       # s2 = meio
    mv s3, a3       # s3 = fim
    
    # Calcula o tamanho do array temporário
    sub s4, s3, s1
    addi s4, s4, 1  # s4 = tamanho do array temporário
    
    # Aloca espaço para o array temporário na pilha
    slli s5, s4, 2  # s5 = tamanho * 4 (bytes)
    sub sp, sp, s5  # Aloca espaço na pilha
    mv s6, sp       # s6 = endereço do array temporário
    
    # Inicializa índices para o merge
    mv t0, s1       # t0 = índice para o primeiro subarray
    addi t1, s2, 1  # t1 = índice para o segundo subarray
    li t2, 0        # t2 = índice para o array temporário
    
merge_loop:
    # Verifica se já processamos todo o primeiro subarray
    bgt t0, s2, copy_remaining_second
    
    # Verifica se já processamos todo o segundo subarray
    bgt t1, s3, copy_remaining_first
    
    # Calcula os endereços dos elementos nos subarrays
    slli t3, t0, 2      # t3 = t0 * 4
    add t3, s0, t3      # t3 = endereço do elemento no primeiro subarray
    lw t4, 0(t3)        # t4 = valor do elemento no primeiro subarray
    
    slli t3, t1, 2      # t3 = t1 * 4
    add t3, s0, t3      # t3 = endereço do elemento no segundo subarray
    lw t5, 0(t3)        # t5 = valor do elemento no segundo subarray
    
    # Compara os elementos e escolhe o menor
    bge t4, t5, choose_second
    
    # Escolhe o elemento do primeiro subarray
    slli t3, t2, 2      # t3 = t2 * 4
    add t3, s6, t3      # t3 = endereço no array temporário
    sw t4, 0(t3)        # Armazena o valor no array temporário
    
    addi t0, t0, 1      # Incrementa o índice do primeiro subarray
    j next_element
    
choose_second:
    # Escolhe o elemento do segundo subarray
    slli t3, t2, 2      # t3 = t2 * 4
    add t3, s6, t3      # t3 = endereço no array temporário
    sw t5, 0(t3)        # Armazena o valor no array temporário
    
    addi t1, t1, 1      # Incrementa o índice do segundo subarray
    
next_element:
    addi t2, t2, 1      # Incrementa o índice do array temporário
    j merge_loop
    
copy_remaining_first:
    # Copia os elementos restantes do primeiro subarray
    bgt t0, s2, copy_back
    
    slli t3, t0, 2      # t3 = t0 * 4
    add t3, s0, t3      # t3 = endereço do elemento no primeiro subarray
    lw t4, 0(t3)        # t4 = valor do elemento no primeiro subarray
    
    slli t3, t2, 2      # t3 = t2 * 4
    add t3, s6, t3      # t3 = endereço no array temporário
    sw t4, 0(t3)        # Armazena o valor no array temporário
    
    addi t0, t0, 1      # Incrementa o índice do primeiro subarray
    addi t2, t2, 1      # Incrementa o índice do array temporário
    j copy_remaining_first
    
copy_remaining_second:
    # Copia os elementos restantes do segundo subarray
    bgt t1, s3, copy_back
    
    slli t3, t1, 2      # t3 = t1 * 4
    add t3, s0, t3      # t3 = endereço do elemento no segundo subarray
    lw t4, 0(t3)        # t4 = valor do elemento no segundo subarray
    
    slli t3, t2, 2      # t3 = t2 * 4
    add t3, s6, t3      # t3 = endereço no array temporário
    sw t4, 0(t3)        # Armazena o valor no array temporário
    
    addi t1, t1, 1      # Incrementa o índice do segundo subarray
    addi t2, t2, 1      # Incrementa o índice do array temporário
    j copy_remaining_second
    
copy_back:
    # Copia os elementos do array temporário de volta para o array original
    li t0, 0            # t0 = contador
    
copy_back_loop:
    bge t0, t2, merge_done
    
    # Calcula o endereço no array temporário
    slli t3, t0, 2      # t3 = t0 * 4
    add t3, s6, t3      # t3 = endereço no array temporário
    lw t4, 0(t3)        # t4 = valor do elemento no array temporário
    
    # Calcula o endereço no array original
    add t5, s1, t0      # t5 = índice no array original
    slli t3, t5, 2      # t3 = t5 * 4
    add t3, s0, t3      # t3 = endereço no array original
    sw t4, 0(t3)        # Armazena o valor no array original
    
    addi t0, t0, 1      # Incrementa o contador
    j copy_back_loop
    
merge_done:
    # Libera o espaço do array temporário
    add sp, sp, s5      # Libera espaço na pilha
    
    # Restaura registradores da pilha
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    
    ret

# Função para imprimir um array
# a0 = endereço do array
# a1 = tamanho do array
print_array:
    # Salva registradores na pilha
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    # Inicializa registradores
    mv s0, a0       # s0 = endereço do array
    mv s1, a1       # s1 = tamanho do array
    
    li s2, 0        # s2 = contador
print_loop:
    bge s2, s1, print_done
    
    # Calcula o endereço do elemento
    slli t0, s2, 2      # t0 = s2 * 4
    add t0, s0, t0      # t0 = endereço do elemento
    lw a0, 0(t0)        # a0 = valor do elemento
    
    # Imprime o valor
    li a7, 1
    ecall
    
    # Imprime um espaço
    mv t0, a0           # Salva o valor atual de a0
    la a0, space
    li a7, 4
    ecall
    mv a0, t0           # Restaura o valor original de a0
    
    addi s2, s2, 1
    j print_loop
    
print_done:
    # Imprime uma nova linha
    la a0, newline
    li a7, 4
    ecall
    
    # Restaura registradores da pilha
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    
    ret
