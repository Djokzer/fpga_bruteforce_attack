#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <crypt.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <errno.h>

int hash_count;

char final_salt[70];
const char *prefix = "$2b$";  // Using bcrypt
const char *salt = "dnQY/8g/fqXHs8qIjyBD2.";
const char *password = "b";
uint8_t cost = 5;

void format_salt(const char* prefix, uint8_t cost, const char* salt, char* output);

void *thread(void *args) 
{
    struct crypt_data data;
    data.initialized = 0;

    for (size_t i = 0; i < hash_count; i++)
    {
        // Use the generated salt to hash the password
        char *hashed_password = crypt_r(password, final_salt, &data);

        // Check hashed password result
        if (!hashed_password) {
            perror("crypt");
            break;
        }
    }
}

int main(int argc, char** argv) {
    if(argc < 3)
    {
        return EXIT_SUCCESS;
    }

    int cpu_count = atoi(argv[1]);
    hash_count = atoi(argv[2]);

    format_salt(prefix, cost, salt, final_salt);
    printf("Salt: %s\n", final_salt);

    // THREAD INIT
    pthread_t threads[100];

    for (int i = 0; i < cpu_count; i++) 
    {
        int code = pthread_create(&threads[i], NULL, thread, NULL);
        
        if (code != 0) 
        {
            fprintf(stderr, "pthread_create failed!\n");
            return EXIT_FAILURE;
        }
    }

    for (int i = 0; i < cpu_count; i++) 
    {
        int code = pthread_join(threads[i], NULL);
        if (code != 0) 
        {
            fprintf(stderr, "pthread_join failed!\n");
            return EXIT_FAILURE;
        }
    }

    return EXIT_SUCCESS;
}

void format_salt(const char* prefix, uint8_t cost, const char* salt, char* output)
{
    char cost_str[5];
    sprintf(cost_str, "%02d$", cost);

    strcpy(output, prefix);
    strcat(output, cost_str);
    strcat(output, salt);
}
