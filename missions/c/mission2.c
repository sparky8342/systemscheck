#include <stdbool.h>
#include <stdio.h>
#include "./utils/cvector.h"

typedef struct {
    int x;
    int y;
    int steps;
} POS;

int width;
int height;

int bfs(char grid[height][width]) {
    static int dirs[] = {0, 1, 0, -1, 1, 0, -1, 0};

    bool visited[height][width];
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            visited[y][x] = false;
        }
    }

    POS **queue = NULL;
    POS *start = (POS *)malloc(sizeof(POS));
    start->x = 0;
    start->y = 0;
    start->steps = 0;
    cvector_push_back(queue, start);
    visited[0][0] = true;

    while (cvector_size(queue) > 0) {
	POS *pos = queue[0];
        cvector_erase(queue, 0);

        if (pos->x == width - 1 && pos->y == height - 1) {
            cvector_free(queue);
            return pos->steps;
        }

        for (int i = 0; i < 8; i += 2) {
            int next_x = pos->x + dirs[i];
            int next_y = pos->y + dirs[i + 1];
            if (next_x < 0 || next_x == width || next_y < 0 || next_y == height) {
                continue;
            }
            if (grid[next_y][next_x] == '#') {
                continue;
            }
            if (visited[next_y][next_x] == true) {
                continue;
            }

            POS *next = (POS *)malloc(sizeof(POS));
            next->x = next_x;
	    next->y = next_y;
	    next->steps = pos->steps + 1;
	    cvector_push_back(queue, next);
            visited[next->y][next->x] = true;
	}
    }

    cvector_free(queue);
    return -1;
}

int main() {
    FILE *fptr;
    fptr = fopen("../../inputs/2.txt", "r");
    if (fptr == NULL) {
        printf("Cannot open file\n");
        return 1;
    }

    // get size of grid
    char buffer[1000];
    fgets(buffer, sizeof(buffer), fptr);
    for (int i = 0; i < sizeof(buffer); i++) {
        if (buffer[i] == '\n') {
            width = i;
            break;
        }
    }
    height = 1;
    while (fgets(buffer, sizeof(buffer), fptr) != NULL) {
        if (buffer[0] == ' ') {
            break;
        }
        height++;
    }
    rewind(fptr);

    // create and read in grid
    char grid[height][width];
    for (int row = 0; row < height; row++) {
        fgets(buffer, sizeof(buffer), fptr);
        memcpy(grid[row], buffer, width);
    }

    fclose(fptr);

    printf("%d\n", bfs(grid));

    return 0;
}
