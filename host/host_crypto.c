#include "PIM-common/host/include/host.h"
#include "aes_core.h"
#include "aes_local.h"
#include "common.h"
#include "crypto.h"
#include <stdio.h>
#include <time.h>
#include <pthread.h>
#include <omp.h>


#define NUM_THREADS 64 


typedef struct {
    void *in;
    void *out;
    unsigned long start;
    unsigned long end;
    const void *key_ptr;
} thread_data_t;


int host_AES_ecb(void *in, void *out, unsigned long length, const void *key_ptr,
                 int operation) {

  struct timespec start, end;

  clock_gettime(CLOCK_MONOTONIC_RAW, &start);

  int nr_repetitions = (MEGABYTE(256) + length - 1) / length;   
  //int nr_repetitions = (MEGABYTE(1) + length - 1) / length;   
  nr_repetitions += 2;

for (int i = 0; i < nr_repetitions; i++) {
    //printf("I is %d\n", i);
    switch (operation) {
    case OP_ENCRYPT:
      host_AES_ecb_encrypt(in, out, length, key_ptr);
      break;
    case OP_DECRYPT:
      host_AES_ecb_decrypt(in, out, length, key_ptr);
      break;
    default:
      return 1;
    }
  }
  clock_gettime(CLOCK_MONOTONIC_RAW, &end);

  double execution_time = TIME_DIFFERENCE(start, end) / nr_repetitions;

  // TODO: add a cycle count
  // Operation, Data size, Execution time
  MEASURE("%d,%ld,%f\n", operation, length, execution_time);

  DEBUG("%sed %ld bytes in %fs\n",
        (operation == OP_ENCRYPT) ? "Encrypt" : "Decrypt", length,
        execution_time);

  return 0;
}

void *encrypt_block(void *arg) {
    thread_data_t *data = (thread_data_t *)arg;
    AES_KEY key;
    AES_set_encrypt_key(data->key_ptr, AES_KEY_SIZE, &key);
    
    //int i=0;
    for (unsigned long location = data->start; location < data->end; location++) {
        AES_encrypt(data->in + location * 16, data->out + location * 16, &key);
    }
    return NULL;

    //pthread_exit(NULL);
}

int host_AES_ecb_encrypt_1(void *in, void *out, unsigned long length, const void *key_ptr) {
    pthread_t threads[NUM_THREADS];
    thread_data_t thread_data[NUM_THREADS];
    unsigned long block_size = length / (16 * NUM_THREADS);

    for (int i = 0; i < NUM_THREADS; i++) {
        thread_data[i].in = in;
        thread_data[i].out = out;
        thread_data[i].key_ptr = key_ptr;
        thread_data[i].start = i * block_size;
        thread_data[i].end = (i == NUM_THREADS - 1) ? length / 16 : (i + 1) * block_size;
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, encrypt_block, (void *)&thread_data[i]);
    }

    // Wait for all threads to complete
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    return 0;
}


int host_AES_ecb_encrypt(void *in, void *out, unsigned long length,
                         const void *key_ptr) {
  AES_KEY key;
  AES_set_encrypt_key(key_ptr, AES_KEY_SIZE, &key);
  //#pragma omp parallel for num_threads(64)
  for (unsigned long location = 0; location < length / 16; location++) {
    AES_encrypt(in + location * 16, out + location * 16, &key);
  }

  return 0;
}

int host_AES_ecb_decrypt(void *in, void *out, unsigned long length,
                         const void *key_ptr) {
  AES_KEY key;
  AES_set_decrypt_key(key_ptr, AES_KEY_SIZE, &key);

  for (unsigned long location = 0; location < length / 16; location++) {
    AES_decrypt(in + location * 16, out + location * 16, &key);
  }

  return 0;
}
