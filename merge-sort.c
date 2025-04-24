/**
 * Implementação iterativa do Merge Sort em C
 * Otimizado para uso eficiente de cache (localidade espacial)
 * Array de 8 elementos
 */

#include <stdio.h>

// Função para mesclar dois subarrays
void merge(int arr[], int temp[], int start, int mid, int end) {
    int i = start;      // Índice para o primeiro subarray
    int j = mid + 1;    // Índice para o segundo subarray
    int k = start;      // Índice para o array temporário
    
    // Mescla os dois subarrays em ordem crescente
    while (i <= mid && j <= end) {
        if (arr[i] <= arr[j]) {
            temp[k] = arr[i];
            i++;
        } else {
            temp[k] = arr[j];
            j++;
        }
        k++;
    }
    
    // Copia os elementos restantes do primeiro subarray, se houver
    while (i <= mid) {
        temp[k] = arr[i];
        i++;
        k++;
    }
    
    // Copia os elementos restantes do segundo subarray, se houver
    while (j <= end) {
        temp[k] = arr[j];
        j++;
        k++;
    }
    
    // Copia os elementos do array temporário de volta para o array original
    for (i = start; i <= end; i++) {
        arr[i] = temp[i];
    }
}

// Função principal do merge sort iterativo
void merge_sort_iterative(int arr[], int temp[], int size) {
    // Implementação iterativa do Merge Sort
    // Começa com subarrays de tamanho 1 e vai dobrando
    for (int width = 1; width < size; width = width * 2) {
        // Percorre o array em blocos de tamanho width*2
        for (int i = 0; i < size; i = i + 2 * width) {
            // Calcula o meio e o fim do bloco atual
            int mid = i + width - 1;
            int end = i + 2 * width - 1;
            
            // Ajusta o meio se for maior que o tamanho do array
            if (mid >= size) {
                mid = size - 1;
            }
            
            // Ajusta o fim se for maior que o tamanho do array
            if (end >= size) {
                end = size - 1;
            }
            
            // Verifica se há algo para mesclar (meio < fim)
            if (mid < end) {
                merge(arr, temp, i, mid, end);
            }
        }
    }
}

// Função para imprimir um array
void print_array(int arr[], int size) {
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

int main() {
    // Array inicial com 8 elementos
    int array[8] = {5, 2, 9, 1, 7, 3, 8, 6};
    // Array temporário para o merge
    int temp[8] = {0};
    
    // Imprime o array original
    printf("Array original: ");
    print_array(array, 8);
    
    // Chama o merge sort iterativo
    merge_sort_iterative(array, temp, 8);
    
    // Imprime o array ordenado
    printf("Array ordenado: ");
    print_array(array, 8);
    
    return 0;
}
