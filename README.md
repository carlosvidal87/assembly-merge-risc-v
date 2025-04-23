# Documentação do Algoritmo Merge Sort Iterativo em RISC-V

## 1. Introdução ao Merge Sort

O Merge Sort é um algoritmo de ordenação eficiente baseado na estratégia "dividir para conquistar". Ele divide o array em subarrays menores, ordena-os e depois mescla esses subarrays ordenados para formar o array final ordenado. A implementação iterativa evita o uso de recursão, tornando-o mais eficiente em termos de uso de memória e mais adequado para implementações em hardware.

## 2. Visão Geral do Algoritmo Iterativo

A versão iterativa do Merge Sort funciona da seguinte maneira:

1. Começa considerando cada elemento como um subarray ordenado de tamanho 1
2. Mescla pares de subarrays adjacentes para formar subarrays maiores
3. Dobra o tamanho do subarray a cada iteração
4. Continua até que todo o array esteja ordenado

## 3. Estrutura do Código em RISC-V

O código assembly RISC-V está organizado em quatro seções principais:

1. **Seção de Dados (.data)**: Define o array a ser ordenado, um array temporário, e strings para mensagens
2. **Função Principal (main)**: Imprime o array original, chama o Merge Sort, e imprime o array ordenado
3. **Função merge_sort_iterative**: Implementa o algoritmo Merge Sort iterativo
4. **Função merge**: Mescla dois subarrays ordenados
5. **Função print_array**: Imprime os elementos de um array

## 4. Detalhamento das Funções

### 4.1 Função Principal (main)

```assembly
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
```

Esta função carrega o endereço do array e do array temporário, define o tamanho do array, e chama a função `merge_sort_iterative`. Depois, imprime o array ordenado.

### 4.2 Função merge_sort_iterative

```assembly
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
```

Esta função implementa o algoritmo Merge Sort iterativo usando dois loops aninhados:
- O loop externo (`merge_sort_outer_loop`) controla o tamanho dos subarrays, começando com 1 e dobrando a cada iteração
- O loop interno (`merge_sort_inner_loop`) percorre o array em blocos do tamanho atual e mescla pares de subarrays adjacentes

### 4.3 Função merge

```assembly
merge:
    # Inicializa índices para o merge
    mv t0, s2       # t0 = índice para o primeiro subarray
    addi t1, s3, 1  # t1 = índice para o segundo subarray (meio + 1)
    mv t2, s2       # t2 = índice para o array temporário (começando do início)
    
merge_loop:
    # Verifica se já processamos todo o primeiro subarray
    bgt t0, s3, copy_remaining_second
    
    # Verifica se já processamos todo o segundo subarray
    bgt t1, s4, copy_remaining_first
    
    # Compara os elementos e escolhe o menor
    # ...
    
copy_back:
    # Copia os elementos do array temporário de volta para o array original
    # ...
```

Esta função mescla dois subarrays ordenados:
1. Compara elementos dos dois subarrays e escolhe o menor para colocar no array temporário
2. Copia os elementos restantes de qualquer subarray que não tenha sido totalmente processado
3. Copia todos os elementos do array temporário de volta para o array original

## 5. Fluxo de Execução com Exemplo

Vamos acompanhar o fluxo de execução do algoritmo com o array de exemplo: [5, 2, 9, 1, 7, 3, 8, 6]

### Primeira Iteração (tamanho do subarray = 1):
- Mescla [5] e [2] → [2, 5]
- Mescla [9] e [1] → [1, 9]
- Mescla [7] e [3] → [3, 7]
- Mescla [8] e [6] → [6, 8]
- Array após a primeira iteração: [2, 5, 1, 9, 3, 7, 6, 8]

### Segunda Iteração (tamanho do subarray = 2):
- Mescla [2, 5] e [1, 9] → [1, 2, 5, 9]
- Mescla [3, 7] e [6, 8] → [3, 6, 7, 8]
- Array após a segunda iteração: [1, 2, 5, 9, 3, 6, 7, 8]

### Terceira Iteração (tamanho do subarray = 4):
- Mescla [1, 2, 5, 9] e [3, 6, 7, 8] → [1, 2, 3, 5, 6, 7, 8, 9]
- Array final ordenado: [1, 2, 3, 5, 6, 7, 8, 9]

## 6. Otimizações e Considerações

### 6.1 Otimizações para Uso Eficiente de Cache

O algoritmo implementado aproveita a localidade espacial de várias maneiras:

1. **Acesso Sequencial aos Arrays**: Durante a mesclagem, os elementos são acessados sequencialmente tanto no array original quanto no array temporário, o que é benéfico para a localidade espacial.

2. **Processamento por Blocos**: O algoritmo processa os dados em blocos (subarrays), o que aumenta a probabilidade de hits no cache devido à localidade espacial.

### 6.2 Eficiência de Memória

A implementação iterativa é mais eficiente em termos de uso de memória do que a versão recursiva, pois:

1. **Não Usa Pilha para Chamadas Recursivas**: Evita o overhead de múltiplas chamadas recursivas que consomem espaço na pilha.

2. **Uso Constante de Memória**: O uso de memória é previsível e constante, independentemente do tamanho do array.

### 6.3 Complexidade do Algoritmo

- **Complexidade de Tempo**: O(n log n) no pior caso, melhor caso e caso médio
- **Complexidade de Espaço**: O(n) para o array temporário

## 7. Conclusão

A implementação iterativa do Merge Sort em assembly RISC-V demonstra como um algoritmo de ordenação eficiente pode ser implementado sem o uso de recursão. Esta abordagem é particularmente vantajosa para sistemas com recursos limitados e para implementações em hardware, como FPGAs ou ASICs.

O código é otimizado para uso eficiente de cache através da localidade espacial e apresenta um padrão de acesso à memória previsível, o que contribui para seu bom desempenho em sistemas reais.
