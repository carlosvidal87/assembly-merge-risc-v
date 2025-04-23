# Implementação iterativa do Merge Sort em RISC-V
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
    
    # Chama o merge sort iterativo
    la a0, array        # Endereço do array
    la a1, temp         # Endereço do array temporário
    li a2, 8            # Tamanho do array
    jal merge_sort_iterative
    
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

# Função merge_sort_iterative
# a0 = endereço do array
# a1 = endereço do array temporário
# a2 = tamanho do array
merge_sort_iterative:
    # Salva registradores na pilha
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    
    # Inicializa registradores
    mv s0, a0       # s0 = endereço do array
    mv s1, a1       # s1 = endereço do array temporário
    mv s2, a2       # s2 = tamanho do array
    
    # Implementação iterativa do Merge Sort
    # Começa com subarrays de tamanho 1 e vai dobrando
    li s3, 1        # s3 = tamanho atual do subarray
    
merge_sort_outer_loop:
    # Verifica se o tamanho atual do subarray é maior ou igual ao tamanho do array
    bge s3, s2, merge_sort_done
    
    # Percorre o array em blocos de tamanho s3*2
    li s4, 0        # s4 = índice inicial
    
merge_sort_inner_loop:
    # Verifica se já processamos todo o array
    bge s4, s2, merge_sort_inner_done
    
    # Calcula o meio e o fim do bloco atual
    add t0, s4, s3      # t0 = meio (início + tamanho)
    add t1, t0, s3      # t1 = fim (meio + tamanho)
    
    # Ajusta o meio se for maior que o tamanho do array
    blt t0, s2, skip_mid_adjust
    mv t0, s2
skip_mid_adjust:
    
    # Ajusta o fim se for maior que o tamanho do array
    blt t1, s2, skip_end_adjust
    mv t1, s2
skip_end_adjust:
    
    # Verifica se há algo para mesclar (meio < fim)
    bge t0, t1, skip_merge
    
    # Chama a função merge para mesclar os subarrays
    mv a0, s0       # a0 = endereço do array
    mv a1, s1       # a1 = endereço do array temporário
    mv a2, s4       # a2 = início
    addi a3, t0, -1 # a3 = meio - 1
    addi a4, t1, -1 # a4 = fim - 1
    jal merge
    
skip_merge:
    # Atualiza o índice para o próximo bloco
    add s4, s4, s3
    add s4, s4, s3
    
    j merge_sort_inner_loop
    
merge_sort_inner_done:
    # Dobra o tamanho do subarray para a próxima iteração
    slli s3, s3, 1
    j merge_sort_outer_loop
    
merge_sort_done:
    # Restaura registradores da pilha
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    
    ret

# Função merge para mesclar dois subarrays
# a0 = endereço do array
# a1 = endereço do array temporário
# a2 = início
# a3 = meio
# a4 = fim
merge:
    # Salva registradores na pilha
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    
    # Inicializa registradores
    mv s0, a0       # s0 = endereço do array
    mv s1, a1       # s1 = endereço do array temporário
    mv s2, a2       # s2 = início
    mv s3, a3       # s3 = meio
    mv s4, a4       # s4 = fim
    
    # Inicializa índices para o merge
    mv t0, s2       # t0 = índice para o primeiro subarray
    addi t1, s3, 1  # t1 = índice para o segundo subarray (meio + 1)
    mv t2, s2       # t2 = índice para o array temporário (começando do início)
    
merge_loop:
    # Verifica se já processamos todo o primeiro subarray
    bgt t0, s3, copy_remaining_second
    
    # Verifica se já processamos todo o segundo subarray
    bgt t1, s4, copy_remaining_first
    
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
    add t3, s1, t3      # t3 = endereço no array temporário
    sw t4, 0(t3)        # Armazena o valor no array temporário
    
    addi t0, t0, 1      # Incrementa o índice do primeiro subarray
    j next_element
    
choose_second:
    # Escolhe o elemento do segundo subarray
    slli t3, t2, 2      # t3 = t2 * 4
    add t3, s1, t3      # t3 = endereço no array temporário
    sw t5, 0(t3)        # Armazena o valor no array temporário
    
    addi t1, t1, 1      # Incrementa o índice do segundo subarray
    
next_element:
    addi t2, t2, 1      # Incrementa o índice do array temporário
    j merge_loop
    
copy_remaining_first:
    # Copia os elementos restantes do primeiro subarray
    bgt t0, s3, copy_back
    
    slli t3, t0, 2      # t3 = t0 * 4
    add t3, s0, t3      # t3 = endereço do elemento no primeiro subarray
    lw t4, 0(t3)        # t4 = valor do elemento no primeiro subarray
    
    slli t3, t2, 2      # t3 = t2 * 4
    add t3, s1, t3      # t3 = endereço no array temporário
    sw t4, 0(t3)        # Armazena o valor no array temporário
    
    addi t0, t0, 1      # Incrementa o índice do primeiro subarray
    addi t2, t2, 1      # Incrementa o índice do array temporário
    j copy_remaining_first
    
copy_remaining_second:
    # Copia os elementos restantes do segundo subarray
    bgt t1, s4, copy_back
    
    slli t3, t1, 2      # t3 = t1 * 4
    add t3, s0, t3      # t3 = endereço do elemento no segundo subarray
    lw t4, 0(t3)        # t4 = valor do elemento no segundo subarray
    
    slli t3, t2, 2      # t3 = t2 * 4
    add t3, s1, t3      # t3 = endereço no array temporário
    sw t4, 0(t3)        # Armazena o valor no array temporário
    
    addi t1, t1, 1      # Incrementa o índice do segundo subarray
    addi t2, t2, 1      # Incrementa o índice do array temporário
    j copy_remaining_second
    
copy_back:
    # Copia os elementos do array temporário de volta para o array original
    mv t0, s2       # t0 = índice inicial
    
copy_back_loop:
    bgt t0, s4, merge_done
    
    # Calcula o endereço no array temporário
    sub t3, t0, s2      # t3 = deslocamento relativo ao início
    add t3, s2, t3      # t3 = índice no array temporário
    slli t3, t3, 2      # t3 = t3 * 4
    add t3, s1, t3      # t3 = endereço no array temporário
    lw t4, 0(t3)        # t4 = valor do elemento no array temporário
    
    # Calcula o endereço no array original
    slli t3, t0, 2      # t3 = t0 * 4
    add t3, s0, t3      # t3 = endereço no array original
    sw t4, 0(t3)        # Armazena o valor no array original
    
    addi t0, t0, 1      # Incrementa o índice
    j copy_back_loop
    
merge_done:
    # Restaura registradores da pilha
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    
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
