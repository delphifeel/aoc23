#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>

#define INPUT_FILE_NAME ("input_d9.txt")

#define MAX_SEQ_SIZE (64)

size_t calc_diff(size_t seq[], size_t seq_len) {
    size_t new_seq[MAX_SEQ_SIZE];

    bool all_zeroes = true;
    for (int i = 1; i < seq_len; i++) {
        size_t v = seq[i] - seq[i - 1];
        if (v != 0) {
            all_zeroes = false;
        }
        new_seq[i - 1] = v;
    }

    if (all_zeroes) {
        return seq[seq_len - 1];
    }

    return calc_diff(new_seq, seq_len - 1) + seq[seq_len - 1];
}

size_t calc_line(char *line) {
    size_t numbers[MAX_SEQ_SIZE];
    size_t numbers_count = 0;
    char *n_str = strtok(line, " \n\r");
    numbers[numbers_count++] = atoll(n_str);
    while (1) {
        n_str = strtok(NULL, " \n\r");
        if (n_str == NULL) {
            break;
        }
        numbers[numbers_count++] = atoll(n_str);
    }

    // 1   3   6  10  15  21
    //   2   3   4   5   6
    // 1   1   1   1
    //   0   0   0
    
    return calc_diff(numbers, numbers_count);
}

int main() {
    FILE *f = fopen(INPUT_FILE_NAME, "rb");
    assert(f != NULL);
    char *line = NULL;
    size_t n = 0;
    size_t count = 0;
    size_t sum = 0;

    while ( (count = getline(&line, &n, f)) != -1 ) {
        sum += calc_line(line);
    }

    printf("sum: %lu\n", sum);

    if (line != NULL) {
        free(line);
    }
    fclose(f);

    return 0;
}
