#include "./utils/ht.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int comp(const void *a, const void *b) {
    int x = *(const int *)a;
    int y = *(const int *)b;

    if (x > y) {
        return -1;
    } else if (x < y) {
        return 1;
    } else {
        return 0;
    }
}

void find_commands(char message[100], ht *commands) {
    int i = 0;
    while (message[i] != '|') {
        i++;
    }
    i++;
    while (message[i] != '|') {
        char command[3] = {message[i], message[i + 1], '\0'};
        void *amount = ht_get(commands, command);
        if (amount == NULL) {
            int *amount = malloc(sizeof(int));
            *amount = 1;
            ht_set(commands, command, amount);
        } else {
            int *val = (int *)amount;
            *val = *val + 1; // *val++ doesn't work
        }
        i += 2;
    }
}

int main() {
    FILE *fptr;
    fptr = fopen("../../inputs/4.txt", "r");
    if (fptr == NULL) {
        printf("Cannot open file\n");
        return 1;
    }

    int sum = 0;
    ht *commands = ht_create();

    char message[100];
    while (fscanf(fptr, "%s", message) == 1) {
        int pipes = 0;
        int checksum = 0;
        int cksum = 0;
        for (int i = 0; i < strlen(message); i++) {
            cksum ^= message[i];
            if (message[i] == '|') {
                pipes++;
                if (pipes == 2) {
                    i++;
                    checksum = message[i] - '0';
                    i++;
                    while (message[i] != '\0') {
                        checksum = checksum * 10 + message[i] - '0';
                        i++;
                    }
                    if (checksum != cksum) {
                        sum += checksum;
                        find_commands(message, commands);
                    }
                    break;
                }
            }
        }
    }

    int l = ht_length(commands);
    int values[l];
    int i = 0;
    hti it = ht_iterator(commands);
    while (ht_next(&it)) {
        values[i] = *(int *)it.value;
        i++;
    }
    qsort(values, l, sizeof(values[0]), comp);

    printf("%d\n%d\n", sum, values[0] * values[1]);
}
