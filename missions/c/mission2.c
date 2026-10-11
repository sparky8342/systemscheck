#include <stdbool.h>
#include <stdio.h>
#include "./utils/cvector.h"

typedef struct {
    int x;
    int y;
    int steps;
} POS;

typedef struct {
    POS **data;
    int capacity;
    int next;
} Heap;

int heap_parent(int i) {
    return (i - 1) / 2;
}
int heap_left(int i) {
    return 2 * i + 1;
}
int heap_right(int i) {
    return 2 * i + 2;
}

Heap *heap_new() {
    Heap *h = malloc(sizeof(Heap *));
    h->data = malloc(sizeof(POS *));
    h->next = 0;
    h->capacity = 1;
    return h;
}

void heap_insert(Heap *heap, POS *pos) {
    if (heap->capacity == heap->next) {
        heap->capacity *= 2;
        heap->data = realloc(heap->data, sizeof(POS *) * heap->capacity);
    }
    heap->data[heap->next] = pos;

    int i = heap->next;
    while (i != 0) {
        int parent = heap_parent(i);
        if (heap->data[parent]->steps > heap->data[i]->steps) {
            POS *tmp = heap->data[parent];
            heap->data[parent] = heap->data[i];
            heap->data[i] = tmp;
            i = parent;
        } else {
            break;
        }
    }

    heap->next++;
}

void min_heapify(Heap *heap, int i) {
    int l = heap_left(i);
    int r = heap_right(i);
    int smallest = i;
    if (l < heap->next && heap->data[l]->steps < heap->data[i]->steps) {
        smallest = l;
    }
    if (r < heap->next && heap->data[r]->steps < heap->data[smallest]->steps) {
        smallest = r;
    }
    if (smallest != i) {
        POS *tmp = heap->data[i];
        heap->data[i] = heap->data[smallest];
        heap->data[smallest] = tmp;
        min_heapify(heap, smallest);
    }
}

POS *heap_pop(Heap *heap) {
    POS *min = heap->data[0];
    heap->data[0] = heap->data[heap->next - 1];
    heap->next--;
    min_heapify(heap, 0);
    return min;
}

static int dirs[] = {0, 1, 0, -1, 1, 0, -1, 0};

int width;
int height;

bool in_bounds(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
}

int bfs(char grid[height][width]) {
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
            if (!in_bounds(next_x, next_y)) {
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

bool next_to_wall(char grid[height][width], int x, int y) {
    for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
            if (dx == 0 && dy == 0) {
                continue;
            }
            int new_x = x + dx;
            int new_y = y + dy;
            if (!in_bounds(new_x, new_y)) {
                continue;
            }
            if (grid[new_y][new_x] == '#') {
                return true;
            }
        }
    }
    return false;
}

int djikstra(char grid[height][width]) {
    int distances[height][width];
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            distances[y][x] = 999999;
        }
    }
    distances[0][0] = 0;

    Heap *heap = heap_new();
    POS *start = (POS *)malloc(sizeof(POS));
    start->x = 0;
    start->y = 0;
    start->steps = 0;
    heap_insert(heap, start);

    while (heap->next > 0) {
        POS *pos = heap_pop(heap);

        if (pos->x == width - 1 && pos->y == height - 1) {
            free(pos);
            free(heap);
            return distances[height - 1][width - 1];
        }

        for (int i = 0; i < 8; i += 2) {
            int new_x = pos->x + dirs[i];
            int new_y = pos->y + dirs[i + 1];
            if (!in_bounds(new_x, new_y)) {
                continue;
            }
            if (grid[new_y][new_x] == '#') {
                continue;
            }

            int new_steps = pos->steps + 1;
            if (next_to_wall(grid, new_x, new_y)) {
                new_steps++;
            }
            if (distances[new_y][new_x] > new_steps) {
                distances[new_y][new_x] = new_steps;
                POS *new_pos = (POS *)malloc(sizeof(POS));
                new_pos->x = new_x;
                new_pos->y = new_y;
                new_pos->steps = new_steps;
                heap_insert(heap, new_pos);
            }
        }
    }
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

    printf("%d\n%d\n", bfs(grid), djikstra(grid));

    return 0;
}
