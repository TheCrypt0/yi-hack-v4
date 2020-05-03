/*
 * This file is part of libipc (https://github.com/TheCrypt0/libipc).
 * Copyright (c) 2019 roleo.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Send message to a IPC queue.
 */

#include "ipc_cmd.h"
#include "getopt.h"

mqd_t ipc_mq;

int open_queue()
{
    ipc_mq = mq_open(IPC_QUEUE_NAME, O_RDWR);
    if(ipc_mq == -1) {
        fprintf(stderr, "Can't open mqueue %s\n", IPC_QUEUE_NAME);
        return -1;
    }
    return 0;
}

int ipc_start()
{
    int ret = -1;

    ret = open_queue();
    if(ret != 0) {
        return -1;
    }

    return 0;
}

void ipc_stop()
{
    if(ipc_mq > 0) {
        mq_close(ipc_mq);
    }
}

void print_usage(char *progname)
{
    fprintf(stderr, "\nUsage: %s [t ON/OFF] [-s SENS] [-l LED] [-v WHEN] [-i IR] [-r ROTATE] [-m MOVE] [-p NUM] [-d]\n\n", progname);
    fprintf(stderr, "\t-t ON/OFF, --switch ON/OFF\n");
    fprintf(stderr, "\t\tswitch ON or OFF the cam\n");
    fprintf(stderr, "\t-s SENS, --sensitivity SENS\n");
    fprintf(stderr, "\t\tset sensitivity: LOW, MEDIUM or HIGH\n");
    fprintf(stderr, "\t-l LED, --led LED\n");
    fprintf(stderr, "\t\tset led: ON or OFF\n");
    fprintf(stderr, "\t-v WHEN, --save WHEN\n");
    fprintf(stderr, "\t\tset save mode: ALWAYS or DETECT\n");
    fprintf(stderr, "\t-i IR, --ir IR\n");
    fprintf(stderr, "\t\tset ir led: ON or OFF\n");
    fprintf(stderr, "\t-r ROTATE, --rotate ROTATE\n");
    fprintf(stderr, "\t\tset rotate: ON or OFF\n");
    fprintf(stderr, "\t-m MOVE, --move MOVE\n");
    fprintf(stderr, "\t\tsend PTZ command: RIGHT, LEFT, DOWN, UP or STOP\n");
    fprintf(stderr, "\t-p NUM, --preset NUM\n");
    fprintf(stderr, "\t\tsend PTZ go to preset command: NUM = [0..7]\n");
    fprintf(stderr, "\t-f FILE, --file FILE\n");
    fprintf(stderr, "\t\tread binary command from FILE\n");
    fprintf(stderr, "\t-x,     --xxx\n");
    fprintf(stderr, "\t\tsend xxx message\n");
    fprintf(stderr, "\t-d,     --debug\n");
    fprintf(stderr, "\t\tenable debug\n");
    fprintf(stderr, "\t-h,     --help\n");
    fprintf(stderr, "\t\tprint this help\n");
}

int main(int argc, char ** argv)
{
    int errno;
    char *endptr;
    int c, ret;
    int switch_on = NONE;
    int sensitivity = NONE;
    int led = NONE;
    int save = NONE;
    int ir = NONE;
    int rotate = NONE;
    int move = NONE;
    int preset = NONE;
    int debug = 0;
    unsigned char preset_msg[20];
    char file[1024];
    unsigned char msg_file[1024];
    FILE *fIn;
    int nread = 0;
    int xxx = 0;

    file[0] = '\0';

    while (1) {
        static struct option long_options[] =
        {
            {"switch",  required_argument, 0, 't'},
            {"sensitivity",  required_argument, 0, 's'},
            {"led",  required_argument, 0, 'l'},
            {"save",  required_argument, 0, 'v'},
            {"ir",  required_argument, 0, 'i'},
            {"rotate",  required_argument, 0, 'r'},
            {"move",  required_argument, 0, 'm'},
            {"preset",  required_argument, 0, 'p'},
            {"file", required_argument, 0, 'f'},
            {"xxx", no_argument, 0, 'x'},
            {"debug",  no_argument, 0, 'd'},
            {"help",  no_argument, 0, 'h'},
            {0, 0, 0, 0}
        };
        /* getopt_long stores the option index here. */
        int option_index = 0;

        c = getopt_long (argc, argv, "t:s:l:v:i:r:m:p:f:xdh",
                         long_options, &option_index);

        /* Detect the end of the options. */
        if (c == -1)
            break;

        switch (c) {
        case 't':
            if (strcasecmp("on", optarg) == 0) {
                switch_on = SWITCH_ON;
            } else if (strcasecmp("off", optarg) == 0) {
                switch_on = SWITCH_OFF;
            }
            break;

        case 's':
            if (strcasecmp("low", optarg) == 0) {
                sensitivity = SENSITIVITY_LOW;
            } else if (strcasecmp("medium", optarg) == 0) {
                sensitivity = SENSITIVITY_MEDIUM;
            } else if (strcasecmp("high", optarg) == 0) {
                sensitivity = SENSITIVITY_HIGH;
            }
            break;

        case 'l':
            if (strcasecmp("off", optarg) == 0) {
                led = LED_OFF;
            } else if (strcasecmp("on", optarg) == 0) {
                led = LED_ON;
            }
            break;

        case 'v':
            if (strcasecmp("always", optarg) == 0) {
                save = SAVE_ALWAYS;
            } else if (strcasecmp("detect", optarg) == 0) {
                save = SAVE_DETECT;
            }
            break;

        case 'i':
            if (strcasecmp("off", optarg) == 0) {
                ir = IR_OFF;
            } else if (strcasecmp("on", optarg) == 0) {
                ir = IR_ON;
            }
            break;

        case 'r':
            if (strcasecmp("off", optarg) == 0) {
                rotate = ROTATE_OFF;
            } else if (strcasecmp("on", optarg) == 0) {
                rotate = ROTATE_ON;
            }
            break;

        case 'm':
            if (strcasecmp("right", optarg) == 0) {
                move = MOVE_RIGHT;
            } else if (strcasecmp("left", optarg) == 0) {
                move = MOVE_LEFT;
            } else if (strcasecmp("down", optarg) == 0) {
                move = MOVE_DOWN;
            } else if (strcasecmp("up", optarg) == 0) {
                move = MOVE_UP;
            } else if (strcasecmp("stop", optarg) == 0) {
                move = MOVE_STOP;
            }
            break;

        case 'p':
            errno = 0;    /* To distinguish success/failure after call */
            preset = strtol(optarg, &endptr, 10);

            /* Check for various possible errors */
            if ((errno == ERANGE && (preset == LONG_MAX || preset == LONG_MIN)) || (errno != 0 && preset == 0)) {
                print_usage(argv[0]);
                exit(EXIT_FAILURE);
            }
            if (endptr == optarg) {
                print_usage(argv[0]);
                exit(EXIT_FAILURE);
            }
            break;

        case 'f':
            /* Check for various possible errors */
            if (strlen(optarg) < 1023) {
                strcpy(file, optarg);
            } else {
                print_usage(argv[0]);
                exit(EXIT_FAILURE);
            }
            break;

        case 'd':
            fprintf (stderr, "debug on\n");
            debug = 1;
            break;

        case 'x':
            xxx = 1;
            break;

        case 'h':
            print_usage(argv[0]);
            exit(EXIT_SUCCESS);
            break;

        case '?':
            /* getopt_long already printed an error message. */
            break;

        default:
            print_usage(argv[0]);
            exit(EXIT_SUCCESS);
        }
    }

    if (argc == 1) {
        print_usage(argv[0]);
        exit(EXIT_SUCCESS);
    }

    ret=ipc_start();
    if(ret != 0) {
        exit(EXIT_FAILURE);
    }

    if (switch_on == SWITCH_ON) {
        mq_send(ipc_mq, IPC_SWITCH_ON, sizeof(IPC_SWITCH_ON) - 1, 0);
    } else if (switch_on == SWITCH_OFF) {
        mq_send(ipc_mq, IPC_SWITCH_OFF, sizeof(IPC_SWITCH_OFF) - 1, 0);
    }

    if (sensitivity == SENSITIVITY_LOW) {
        mq_send(ipc_mq, IPC_SENS_LOW, sizeof(IPC_SENS_LOW) - 1, 0);
    } else if (sensitivity == SENSITIVITY_MEDIUM) {
        mq_send(ipc_mq, IPC_SENS_MEDIUM, sizeof(IPC_SENS_MEDIUM) - 1, 0);
    } else if (sensitivity == SENSITIVITY_HIGH) {
        mq_send(ipc_mq, IPC_SENS_HIGH, sizeof(IPC_SENS_HIGH) - 1, 0);
    }

    if (led == LED_OFF) {
        mq_send(ipc_mq, IPC_LED_OFF, sizeof(IPC_LED_OFF) - 1, 0);
    } else if (led == LED_ON) {
        mq_send(ipc_mq, IPC_LED_ON, sizeof(IPC_LED_ON) - 1, 0);
    }

    if (save == SAVE_ALWAYS) {
        mq_send(ipc_mq, IPC_SAVE_ALWAYS, sizeof(IPC_SAVE_ALWAYS) - 1, 0);
    } else if (save == SAVE_DETECT) {
        mq_send(ipc_mq, IPC_SAVE_DETECT, sizeof(IPC_SAVE_DETECT) - 1, 0);
    }

    if (ir == IR_OFF) {
        mq_send(ipc_mq, IPC_IR_OFF, sizeof(IPC_IR_OFF) - 1, 0);
    } else if (ir == IR_ON) {
        mq_send(ipc_mq, IPC_IR_ON, sizeof(IPC_IR_ON) - 1, 0);
    }

    if (rotate == ROTATE_OFF) {
        mq_send(ipc_mq, IPC_ROTATE_OFF, sizeof(IPC_ROTATE_OFF) - 1, 0);
    } else if (rotate == ROTATE_ON) {
        mq_send(ipc_mq, IPC_ROTATE_ON, sizeof(IPC_ROTATE_ON) - 1, 0);
    }

    if (move == MOVE_RIGHT) {
        mq_send(ipc_mq, IPC_MOVE_RIGHT, sizeof(IPC_MOVE_RIGHT) - 1, 0);
    } else if (move == MOVE_LEFT) {
        mq_send(ipc_mq, IPC_MOVE_LEFT, sizeof(IPC_MOVE_LEFT) - 1, 0);
    } else if (move == MOVE_DOWN) {
        mq_send(ipc_mq, IPC_MOVE_DOWN, sizeof(IPC_MOVE_DOWN) - 1, 0);
    } else if (move == MOVE_UP) {
        mq_send(ipc_mq, IPC_MOVE_UP, sizeof(IPC_MOVE_UP) - 1, 0);
    } else if (move == MOVE_STOP) {
        mq_send(ipc_mq, IPC_MOVE_STOP, sizeof(IPC_MOVE_STOP) - 1, 0);
    }

    if (preset != NONE) {
        memcpy(preset_msg, IPC_GOTO_PRESET, sizeof(IPC_GOTO_PRESET) - 1);
        preset_msg[16] = preset & 0xff;
        mq_send(ipc_mq, preset_msg, sizeof(IPC_GOTO_PRESET) - 1, 0);
    }

    if (file[0] != '\0') {
        fIn = fopen(file, "r");
        if (fIn == NULL) {
            fprintf(stderr, "Error opening file %s\n", file);
            exit(EXIT_FAILURE);
        }

        // Tell size
        fseek(fIn, 0L, SEEK_END);
        nread = ftell(fIn);
        fseek(fIn, 0L, SEEK_SET);

        if (fread(msg_file, 1, nread, fIn) != nread) {
            fprintf(stderr, "Error reading file %s\n", file);
            exit(EXIT_FAILURE);
        }
        fclose(fIn);
        mq_send(ipc_mq, msg_file, nread, 0);
    }

    if (xxx == 1) {
        mq_send(ipc_mq, IPC_XXX_0, sizeof(IPC_XXX_0) - 1, 0);
    }

    ipc_stop();

    return 0;
}
