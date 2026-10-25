#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "utils/cvector.h"

#define BUFFER_SIZE 1000
#define CHUNKS_SEEN_SIZE 300

typedef struct {
    int id;
    int dist;
    int buffer_len;
} Neighbour;

typedef struct {
    int x;
    int y;
    Neighbour **neighbours;
    int *buffer;
    bool chunks_seen[CHUNKS_SEEN_SIZE];
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

void add_to_buffer(Relay *relay, int chunk) {
    cvector_push_back(relay->buffer, chunk);
    relay->chunks_seen[chunk] = true;
}

bool send_chunk_to_neighbour(Relay **relays, Relay *relay, Neighbour *neighbour,
                             int chunk_id, int chunk) {
    Relay *neighbour_relay = relays[neighbour->id];
    if (neighbour_relay->chunks_seen[chunk] == false) {
        cvector_erase(relay->buffer, chunk_id);
        add_to_buffer(neighbour_relay, chunk);
        return true;
    } else {
        return false;
    }
}

int comp(const void *elem1, const void *elem2) {
    const Neighbour *const *a = elem1;
    const Neighbour *const *b = elem2;

    int da = (*a)->dist;
    int db = (*b)->dist;
    if (da < db) return -1;
    if (da > db) return 1;

    da = (*a)->buffer_len;
    db = (*b)->buffer_len;
    if (da < db) return -1;
    if (da > db) return 1;

    da = (*a)->id;
    db = (*b)->id;
    if (da < db) return -1;
    if (da > db) return 1;

    return 0;
}

void print_relays(Relay **relays) {
    for (int i = 0; i < cvector_size(relays); i++) {
        printf("Relay %d: ", i);
        for (int j = 0; j < cvector_size(relays[i]->buffer); j++) {
            printf("%d ", relays[i]->buffer[j]);
        }
        printf("\n");
    }
    printf("\n");
}

int send_message(Relay **relays) {
    int relay_id = 0;

    while (relay_id < cvector_size(relays) - 1) {
        bool move = false;
        Relay *relay = relays[relay_id];

        if (cvector_size(relay->buffer) > 0) {
            for (int j = 0; j < cvector_size(relay->neighbours); j++) {
                relay->neighbours[j]->buffer_len =
                    cvector_size(relays[relay->neighbours[j]->id]->buffer);
            }

            qsort(relay->neighbours, cvector_size(relay->neighbours),
                  sizeof(Neighbour *), comp);

            int chunk_id = 0;
            int n_id = 0;
            while (chunk_id < cvector_size(relay->buffer)) {
                int chunk = relay->buffer[chunk_id];
                bool sent = false;

                for (int j = n_id; j < cvector_size(relay->neighbours); j++) {
                    if (send_chunk_to_neighbour(relays, relay,
                                                relay->neighbours[j], chunk_id,
                                                chunk)) {
                        n_id = (j + 1) % cvector_size(relay->neighbours);
                        sent = true;
                        move = true;
                        break;
                    }
                }
                if (!sent) {
                    for (int j = 0; j < n_id; j++) {
                        if (send_chunk_to_neighbour(relays, relay,
                                                    relay->neighbours[j],
                                                    chunk_id, chunk)) {
                            n_id = (j + 1) % cvector_size(relay->neighbours);
                            sent = true;
                            move = true;
                            break;
                        }
                    }
                }

                if (!sent) {
                    chunk_id++;
                }
            }
        }

        if (move) {
            relay_id = 0;
        } else {
            relay_id++;
        }
    }

    int sum = 0;
    int *buffer = relays[cvector_size(relays) - 1]->buffer;
    for (int i = cvector_size(buffer) - 5; i < cvector_size(buffer); i++) {
        sum += buffer[i];
    }
    sum *= cvector_size(buffer);
    return sum;
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
        relay->buffer = NULL;
        for (int i = 0; i < CHUNKS_SEEN_SIZE; i++) {
            relay->chunks_seen[i] = false;
        }
        cvector_push_back(relays, relay);
    }

    char buffer[BUFFER_SIZE];
    fscanf(fptr, "%s", buffer);

    fclose(fptr);

    int message_len = 1;
    for (int i = 0; i < BUFFER_SIZE; i++) {
        if (buffer[i] == ',') {
            message_len++;
        } else if (buffer[i] == '\0') {
            break;
        }
    }

    int message[message_len];
    int message_i = 0;
    message[0] = 0;

    for (int i = 0; i < BUFFER_SIZE; i++) {
        if (buffer[i] == ',') {
            message_i++;
            message[message_i] = 0;
        } else if (buffer[i] == '\0') {
            break;
        } else {
            message[message_i] *= 10;
            message[message_i] += buffer[i] - '0';
        }
    }

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

    for (int i = 0; i < message_len; i++) {
        add_to_buffer(relays[0], message[i]);
    }

    printf("%d\n", send_message(relays));

    return 0;
}
