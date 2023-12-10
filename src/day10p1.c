#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>

//#define INPUT_FILE_NAME ("d10test.txt")
#define INPUT_FILE_NAME ("input_d10.txt")

typedef struct {
    char *data;
    int width;
    int height;
} Matrix;

#define MATRIX_GET(m, y, x)  ( *((m) + (148 * (y)) + (x)) )

void find_first_pipe(const Matrix *matrix, const int s_pos[2], int out[2], int dir[2]) {
    char c = 0;
    // top
    int y = s_pos[0] - 1;
    int x = s_pos[1];
    if (y > -1) {
        c = MATRIX_GET(matrix->data, y, x);
        switch (c) {
            case '|':
            case '7':
            case 'F':
                out[0] = y;
                out[1] = x;
                dir[0] = -1;
                dir[1] = 0;
                return;
        }
    }

    // right
    y = s_pos[0];
    x = s_pos[1] + 1;
    if (x < matrix->width) {
        c = MATRIX_GET(matrix->data, y, x);
        switch (c) {
            case '-':
            case 'J':
            case '7':
                out[0] = y;
                out[1] = x;
                dir[0] = 0;
                dir[1] = 1;
                return;
        }
    }

    // bottom
    y = s_pos[0] + 1;
    x = s_pos[1];
    if (y < matrix->height) {
        c = MATRIX_GET(matrix->data, y, x);
        switch (c) {
            case '|':
            case 'L':
            case 'J':
                out[0] = y;
                out[1] = x;
                dir[0] = 1;
                dir[1] = 0;
                return;
        }
    }

    // left
    y = s_pos[0];
    x = s_pos[1] - 1;
    if (x > -1) {
        c = MATRIX_GET(matrix->data, y, x);
        switch (c) {
            case '-':
            case 'L':
            case 'F':
                out[0] = y;
                out[1] = x;
                dir[0] = 0;
                dir[1] = -1;
                return;
        }
    }

    abort();
}

size_t calc(const Matrix *matrix, const int s_pos[2]) {
    size_t steps = 1;
    int next_pos[2] = {0, 0};
    int dir[2] = {0, 0};
    find_first_pipe(matrix, s_pos, next_pos, dir);

    while (1) {
        char c = MATRIX_GET(matrix->data, next_pos[0], next_pos[1]);
        //printf("%c  ", c);

        int temp = 0;
        switch (c) {
            case 'S':
                goto END;
            case '-':
                next_pos[1] += dir[1];
                break;
            case '|':
                next_pos[0] += dir[0];
                break;
            case 'L':
                next_pos[0] += dir[1];
                next_pos[1] += dir[0];
                temp = dir[0];
                dir[0] = dir[1];
                dir[1] = temp;
                break;
            case 'J':
                next_pos[0] += -dir[1];
                next_pos[1] += -dir[0];
                temp = -dir[0];
                dir[0] = -dir[1];
                dir[1] = temp;
                break;
            case '7':
                next_pos[0] += dir[1];
                next_pos[1] += dir[0];
                temp = dir[0];
                dir[0] = dir[1];
                dir[1] = temp;
                break;
            case 'F':
                next_pos[0] += -dir[1];
                next_pos[1] += -dir[0];
                temp = -dir[0];
                dir[0] = -dir[1];
                dir[1] = temp;
                break;
        }

        steps++;
    }

END:
    printf("\nend. steps: %lu\n", steps);
    return 0;
}

int main() {
    FILE *f = fopen(INPUT_FILE_NAME, "r");
    assert(f != NULL);
    char *line = NULL;
    size_t n = 0;
    size_t count = 0;

    char *matrix = malloc(sizeof(char) * 4000 * 148);
    int width = 0;
    int height = 0;
    int s_pos[2] = {0, 0};

    while ( (count = getline(&line, &n, f)) != -1 ) {
        char c = 0;
        int i = 0;
        const char *line_copy = line;
        while (1) {
            c = *line_copy++;
            if ((c == 0) || (c == '\n') || (c == '\r')) {
                break;
            }
            if (c == 'S') {
                s_pos[0] = height;
                s_pos[1] = i;
            }
            MATRIX_GET(matrix, height, i) = c;
            i++;
        }

        if (width == 0) {
            width = i;
        }
        height++;
    }

    Matrix matrix_s = {
        matrix, width, height,
    };

    size_t sum = calc(&matrix_s, s_pos);

    fclose(f);
    free(line);
    free(matrix);

    return 0;
}
