#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    FILE *fptr;
    fptr = fopen("../../inputs/1.txt", "r");
    if (fptr == NULL) {
        printf("Cannot open file\n");
        return 1;
    }

    int *times = malloc(sizeof(int *));
    int times_len = 1;

    int disabled_count = 0;
    int disabled_time;
    int max_time = 0;
    int max_disabled_count = 0;
    int max_disabled_time = 0;

    int time;
    int id;
    char state[9];
    while (fscanf(fptr, "t=%d #%d %s\n", &time, &id, state) == 3) {
            int times_len_needed = id + 1;
            if (times_len < times_len_needed) {
                int *t = realloc(times, sizeof(int *) * times_len_needed);
		times = t;
		for (int i = times_len; i < times_len_needed; i++) {
			times[i] = 0;
		}
                times_len = times_len_needed;
	    }
 
            if (strcmp(state, "disabled") == 0) {
                times[id] = time;
                disabled_count++;
	        disabled_time = time;
	    } else if (strcmp(state, "enabled") == 0) {
                int time_diff = time - times[id];
                if (time_diff > max_time) {
		    max_time = time_diff;
		}
		if (disabled_count > max_disabled_count) {
              	    max_disabled_count = disabled_count;
              	    max_disabled_time = time - disabled_time;
		} else if (disabled_count == max_disabled_count) {
              	    int time_diff = time - disabled_time;
                    if (time_diff > max_disabled_time) {
                	    max_disabled_time = time_diff;
		    }
		}
          	
		disabled_count--;
            }
    }

    fclose(fptr);

    printf("%d\n%d\n", max_time, max_disabled_time);

    return 0;
}
