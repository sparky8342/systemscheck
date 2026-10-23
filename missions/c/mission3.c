#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils/cvector.h"

typedef struct {
    int id;
    int dist;
} Neighbour;

typedef struct {
    int x;
    int y;
    Neighbour **neighbours;
} Relay;

int manhattan_dist(Relay *relay1, Relay *relay2) {
    return abs(relay1->x - relay2->x) + abs(relay1->y - relay2->y);
}

void add_neighbour(Relay *relay, int id, int dist) {
    Neighbour *neighbour = (Neighbour *)malloc(sizeof(Neighbour));
    neighbour->id = id;
    neighbour->dist = dist;
    cvector_push_back(relay->neighbours, neighbour);
}

int dfs(Relay **relays, int id, int visited) {
    if (id == cvector_size(relays) - 1) {
        return 1;
    }

    int paths = 0;
    for (int i = 0; i < cvector_size(relays[id]->neighbours); i++) {
        int neighbour_id = relays[id]->neighbours[i]->id;
        if ((visited & (1 << neighbour_id)) == 0) {
            visited |= (1 << neighbour_id);
            paths += dfs(relays, neighbour_id, visited);
            visited ^= (1 << neighbour_id);
        }
    }

    return paths;
}

int count_paths(Relay **relays) {
    int start = 0;
    int visited = 1;
    return dfs(relays, start, visited);
}

int main() {
    FILE *fptr;
    fptr = fopen("../../inputs/3.txt", "r");
    if (fptr == NULL) {
        printf("Cannot open file\n");
        return 1;
    }

    Relay **relays = NULL;

    char id[2];
    int x;
    int y;

    while (fscanf(fptr, "#%s X%d Y%d\n", id, &x, &y) == 3) {
        Relay *relay = (Relay *)malloc(sizeof(Relay));
        relay->x = x;
        relay->y = y;
        relay->neighbours = NULL;
        cvector_push_back(relays, relay);
    }
    char message[1000];
    fscanf(fptr, "%s", message);

    fclose(fptr);

    for (int i = 0; i < cvector_size(relays); i++) {
        for (int j = i + 1; j < cvector_size(relays); j++) {
            int dist = manhattan_dist(relays[i], relays[j]);
            if (dist <= 5) {
                add_neighbour(relays[i], j, dist);
                add_neighbour(relays[j], i, dist);
            }
        }
    }

    printf("%d\n", count_paths(relays));

    return 0;
}
