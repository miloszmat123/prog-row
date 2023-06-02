#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <algorithm>
#include <string>
#include <omp.h>
#include <random>
using namespace std;


long getMax(long arr[], long n)
{
    long mx = arr[0];
    for (long i = 1; i < n; i++)
        if (arr[i] > mx)
            mx = arr[i];
    return mx;
}

void countSort(long arr[], long n, long exp)
{
    long* output = new long[n];
    long i, count[10] = { 0 };
 

    for (i = 0; i < n; i++)
        count[(arr[i] / exp) % 10]++;
 

    for (i = 1; i < 10; i++)
        count[i] += count[i - 1];
 
    for (i = n - 1; i >= 0; i--) {
        output[count[(arr[i] / exp) % 10] - 1] = arr[i];
        count[(arr[i] / exp) % 10]--;
    }
 
    for (i = 0; i < n; i++)
        arr[i] = output[i];
}

void radixsort(long arr[], long n)
{
    
    long m = getMax(arr, n);
 

    for (long exp = 1; m / exp > 0; exp *= 10)
        countSort(arr, n, exp);
}


void countSort_openmp(long arr[], long n, long exp)
{
    long* output = new long[n];
    long i;
    long local_count[10] = { 0 };

    #pragma omp parallel num_threads(6)
    {
        long local_count_private[10] = { 0 };

        #pragma omp for
        for (i = 0; i < n; i++)
            local_count_private[(arr[i] / exp) % 10]++;

        #pragma omp critical
        for (i = 0; i < 10; i++)
            local_count[i] += local_count_private[i];

        #pragma omp barrier

        #pragma omp single
        for (i = 1; i < 10; i++)
            local_count[i] += local_count[i - 1];

        #pragma omp for
        for (i = n - 1; i >= 0; i--) {
            long index = (arr[i] / exp) % 10;
            output[local_count[index] - 1] = arr[i];
            local_count[index]--;
        }

        #pragma omp for
        for (i = 0; i < n; i++)
            arr[i] = output[i];
    }

    delete[] output;
}

void radixsort_openmp(long arr[], long n)
{
    long m = getMax(arr, n);

    for (long exp = 1; m / exp > 0; exp *= 10)
        countSort_openmp(arr, n, exp);
}

void print(long arr[], long n)
{
    for (long i = 0; i < n; i++)
        cout << arr[i] << " ";
}

int main()
{
    const long size = 517000;
    long arr[size];
    ofstream file("numbers.txt");
    

    srand(time(NULL));
    for (long i = 0; i < size; i++) {
        arr[i] = rand() % 2000000000000000 + 500000000000;
        file << arr[i] << "\n";
    }
    file.close();

    // Function Call
    clock_t start = clock();
    radixsort(arr, size);
    clock_t end = clock();
    double elapsed = double(end - start) / CLOCKS_PER_SEC;
    cout << elapsed << endl;

    ifstream file_in("numbers.txt");
    for (long i = 0; i < size; i++) {
        file_in >> arr[i];
    }
    file_in.close();

    start = clock();
    radixsort_openmp(arr, size);
    end = clock();
    elapsed = double(end - start) / CLOCKS_PER_SEC;
    cout  << elapsed << endl;
    
    sort(arr, arr + size, greater<long>());

    start = clock();
    radixsort(arr, size);
    end = clock();
    elapsed = double(end - start) / CLOCKS_PER_SEC;
    cout << elapsed << endl;

    sort(arr, arr + size, greater<long>());

    start = clock();
    radixsort_openmp(arr, size);
    end = clock();
    elapsed = double(end - start) / CLOCKS_PER_SEC;
    cout << elapsed << endl;

    start = clock();
    radixsort(arr, size);
    end = clock();
    elapsed = double(end - start) / CLOCKS_PER_SEC;
    cout << elapsed << endl;
    start = clock();
    radixsort_openmp(arr, size);
    end = clock();
    elapsed = double(end - start) / CLOCKS_PER_SEC;
    cout << elapsed << endl;


    return 0;
}
