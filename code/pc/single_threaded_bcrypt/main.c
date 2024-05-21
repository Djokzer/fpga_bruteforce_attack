#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <crypt.h>
#include <time.h>
#include <unistd.h>


void format_salt(const char* prefix, uint8_t cost, const char* salt, char* output);

int main() {
    char final_salt[70];
    const char *prefix = "$2b$";  // Using bcrypt
    const char *salt = "dnQY/8g/fqXHs8qIjyBD2.";
    const char *password = "b";
    uint8_t cost = 5;  


    format_salt(prefix, cost, salt, final_salt);
    printf("Salt: %s\n", final_salt);

    // Start measuring time
    clock_t start = clock();

    // Use the generated salt to hash the password
    char *hashed_password = crypt(password, final_salt);
    
    // Stop measuring time and calculate the elapsed time
    clock_t end = clock();
    double elapsed = (double)(end - start) / CLOCKS_PER_SEC;
    
    // Check hashed password result
    if (!hashed_password) {
        perror("crypt");
        return EXIT_FAILURE;
    }

    // Print the hashed password
    printf("Hashed password: %s\n", hashed_password);

    
    printf("Time measured: %f seconds.\n", elapsed);
    printf("Hash per second: %f\n", 1 / elapsed);
    return EXIT_SUCCESS;
}

void format_salt(const char* prefix, uint8_t cost, const char* salt, char* output)
{
    char cost_str[5];
    sprintf(cost_str, "04$");
    //sprintf(cost_str, "%d$", cost);

    strcpy(output, prefix);
    strcat(output, cost_str);
    strcat(output, salt);
}