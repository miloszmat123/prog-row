#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <vector>
#include <algorithm>
#include <string>
#include <cuda.h>
#include <cuda_runtime.h>
using namespace std;


void matrixMulCPU(int *c, const int *a, const int *b, int width) {
    for(int y = 0; y < width; ++y) {
        for(int x = 0; x < width; ++x) {
            int sum = 0;
            for(int k = 0; k < width; ++k) {
                sum += a[y * width + k] * b[k * width + x];
            }
            c[y * width + x] = sum;
        }
    }
}

#define BLOCK_SIZE 32

__global__ void matrixMulCUDA(int *c, const int *a, const int *b, int width) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if(row < width && col < width) {
        int temp = 0;
        for(int i = 0; i < width; ++i) {
            temp += a[row * width + i] * b[i * width + col];
        }
        c[row * width + col] = temp;
    }
}

void matrixMul(int* h_a, int* h_b, int* h_c, int width) {
    int size = width * width * sizeof(int);

    int *d_a, *d_b, *d_c;

    cudaMalloc((void**)&d_a, size);
    cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);

    cudaMalloc((void**)&d_b, size);
    cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

    cudaMalloc((void**)&d_c, size);

    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    dim3 dimGrid((width + dimBlock.x - 1) / dimBlock.x, (width + dimBlock.y - 1) / dimBlock.y);

    matrixMulCUDA<<<dimGrid, dimBlock>>>(d_c, d_a, d_b, width);

    cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
}

int main() {
    int WIDTH = 128;
    int size = WIDTH * WIDTH * sizeof(int);
    int* h_a = new int[size];
    int* h_b = new int[size];
    int* h_c_cpu = new int[size];
    int* h_c_gpu = new int[size];

    for(int i = 0; i < WIDTH; i++) {
        for(int j = 0; j < WIDTH; j++) {
            h_a[i * WIDTH + j] = i + j;
            h_b[i * WIDTH + j] = i - j;
        }
    }

    clock_t start = clock();
    matrixMulCPU(h_c_cpu, h_a, h_b, WIDTH);
    clock_t end = clock();

    std::cout << "CPU Matrix Multiplication Time: " << double(end - start) / CLOCKS_PER_SEC << " s\n";

    start = clock();
    matrixMul(h_c_cpu, h_a, h_b, WIDTH);
    end = clock();
    std::cout << "GPU Matrix Multiplication Time: " << double(end - start) / CLOCKS_PER_SEC << " s\n";

    delete[] h_a;
    delete[] h_b;
    delete[] h_c_cpu;
    delete[] h_c_gpu;

    return 0;
}


