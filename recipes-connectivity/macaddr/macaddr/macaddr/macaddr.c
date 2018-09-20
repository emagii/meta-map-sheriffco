#include <sys/ioctl.h>
#include <net/if.h>
#include <unistd.h>
#include <netinet/in.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int getopt(int argc,
           char * const argv[],
           const char *optstring);

extern char *optarg;
extern int optind, opterr, optopt;

int flags   = 0;

#define	DEBUG	(1 << 0)
#define ALL	(1 << 1)
#define	VERBOSITY	(1 << 4)

int dbg(int i)
{
    if (flags & DEBUG) {
        printf("%-16s%d\n", "probe:", i);
    }
}

int get_macaddr(const char *interface, char *mac_address, int flags)
{
    struct ifreq ifr;
    struct ifconf ifc;
    char buf[1024];
    int i;
    int retval = -1;

    int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    if (sock == -1) {
        return -1;
    };

    ifc.ifc_len = sizeof(buf);
    ifc.ifc_buf = buf;
    if (ioctl(sock, SIOCGIFCONF, &ifc) == -1) {
        close(sock);
        return -2;
    }

    struct ifreq* it = ifc.ifc_req;
    const struct ifreq* const end = it + (ifc.ifc_len / sizeof(struct ifreq));

    for (; it != end; ++it) {
        strcpy(ifr.ifr_name, it->ifr_name);
        if (!strcmp(interface, "*")) {
            if (flags & DEBUG)
                printf("%-32sACCEPTED\n", ifr.ifr_name);
        } else if(strcmp(ifr.ifr_name, interface)) {
            if (flags & DEBUG)
                printf("%-32sREJECTED\n", ifr.ifr_name);
            continue;
        } else {
            if (flags & DEBUG)
                printf("%-32sACCEPTED\n", ifr.ifr_name);
        }
        if (ioctl(sock, SIOCGIFFLAGS, &ifr) == 0) {
            if (! (ifr.ifr_flags & IFF_LOOPBACK)) { // don't count loopback
                if (ioctl(sock, SIOCGIFHWADDR, &ifr) == 0) {
                    int i;
                    unsigned char a[6];
                    memcpy(a,ifr.ifr_hwaddr.sa_data,6);
                    sprintf(mac_address, "%02x:%02x:%02x:%02x:%02x:%02x",
                            a[0]&0xff, a[1]&0xff, a[2]&0xff,
                            a[3]&0xff, a[4]&0xff, a[5]&0xff);
                    if (flags & ALL) {
                        if (flags & VERBOSITY) {
                            int i;
                            char c;
                            int len = strlen(ifr.ifr_name);
                            for (i = 0; i < 32 ; i++) {
                                if (i < len) {
                                    c = ifr.ifr_name[i];
                                } else if (i == len) {
                                    c = ':';
                                } else {
                                    c = ' ';
                                }
                                printf("%c",c);
                            }
                        }
                        printf("%s\n", mac_address);
                    }
                    retval = 0;
                    if (!(flags & ALL))
                        break;
                } else {
                    retval = -3;
                    break;
                }
            }
        }  else {
               retval = -4;
               break;
        }
    }
    close(sock);

    return retval;
}


#define	IFACE_LEN	32
int main(int argc, char * const argv[])
{
    int flags, opt;
    char macaddr[32];
    char iface[IFACE_LEN];
    int  iface_len;
    int	result;
    char *p;
    flags   = 0;
    while ((opt = getopt(argc, argv, "adv")) != -1) {
        switch (opt) {
        case 'a':
            flags |= ALL;
            break;
        case 'd':
            flags |= DEBUG;
            break;
        case 'v':
            flags |= VERBOSITY;
            break;
        default:
            fprintf(stderr, "Usage: %s <interface>\n", argv[0]);
            exit(1);
        }
    }

    if (flags & ALL) {
        iface[0] = '*';
        iface[1] = '\0';
    } else {
        if (optind >= argc) {
           fprintf(stderr, "Expected argument after options\n");
           exit(1);
        }
        iface_len = strlen(argv[optind]);
        if(iface_len < sizeof(iface)) {
            strcpy(iface, argv[optind]);
        } else {
            fprintf(stderr, "Interface %s must fit within %d characters\n", argv[optind], iface_len);
            exit(1);
        }
    }
    if (flags & VERBOSITY)
        printf("%-32s%s\n", "Interface:", iface);
    result = get_macaddr(iface, macaddr, flags);
    if (result >= 0) {
        if (!(flags & ALL)) {
            printf("%s\n", macaddr);
        }
        exit(0);
    } else {
        fprintf(stderr, "%-32s NOT FOUND; retval = %d; flags=%d\n", iface, result, flags);
        exit(1);
    }
}
