#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>

#define INPUT_FILE_NAME ("input_d8.txt")

typedef struct {
    char left[4];
    char right[4];
} Ptrs;

#define DIM (26)

#define CHAR_HASH(c)  (c - 65)

#define HASH(token) \
    (CHAR_HASH(token[0]) * DIM + CHAR_HASH(token[1])) * DIM + CHAR_HASH(token[2])

// AAA = (BBB, CCC)
size_t parse_line(char *line, Ptrs *ptrs, char *point) {
    char *token = strtok(line, "=(),\n\r\t ");
    // calc hash
    // 0 1 2
    size_t hash = HASH(token);
    strcpy(point, token);
    
    strcpy(ptrs->left, strtok(NULL, "=(),\n\r\t "));
    strcpy(ptrs->right, strtok(NULL, "=(),\n\r\t "));
    return hash;
}

size_t calc(
        const Ptrs *data, 
        const char *commands,
        char points[],
        size_t points_count
) {
    size_t sum = 0;
    const char *commands_iter = commands;
    // AAA
    while (1) {
        sum++;
        char c = *commands_iter++;
        if (c == 0) {
            commands_iter = commands;
            c = *commands_iter++;
        }

        size_t end_count = 0;
        for (size_t i = 0; i < points_count; i++) {
            const char *letters = points + i * 4;
            const Ptrs *ptrs = &data[HASH(letters)];
            letters = c == 'L' ? ptrs->left : ptrs->right;
            if (letters[2] == 'Z') {
                end_count++;
            }
            memcpy(points + i * 4, letters, 4);
        }

        if (end_count == points_count) {
            break;
        }
    }

    return sum;
}

int main() {
    FILE *f = fopen(INPUT_FILE_NAME, "rb");
    assert(f != NULL);
    char *line = NULL;
    size_t n = 0;

    // commands
    ssize_t count = getline(&line, &n, f);
    char buff[1024];
    strncpy(buff, line, sizeof(buff));
    buff[strlen(line) - 1] = 0;

    printf("commands: %s\n", buff);

    // skip next
    getline(&line, &n, f);

    size_t starting_points_count = 0;
    char starting_points[1024][4];
    memset(starting_points, 0, 1024 * 4);

    size_t data_size = sizeof(Ptrs) * DIM * DIM * DIM;
    Ptrs *data = malloc(data_size);
    memset(data, 0, data_size);
    // prepare map
    size_t i = 0;
    while ( (count = getline(&line, &n, f)) != -1 ) {
        Ptrs ptrs;
        char curr_point[4];
        size_t hash = parse_line(line, &ptrs, curr_point);
        if (curr_point[2] == 'A') {
            strcpy(starting_points[starting_points_count++], curr_point);
        }
        data[hash] = ptrs;
        i++;
    }

    size_t sum = calc(data, buff, (char *)starting_points, starting_points_count);
    printf("sum: %lu\n", sum);

    free(data);
    if (line != NULL) {
        free(line);
    }
    fclose(f);

    return 0;
}
