#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <fpe.h>

void hex2chars(unsigned char hex[], unsigned char result[])
{
    int len = strlen(hex);
    unsigned char temp[3];
    temp[2] = 0x00;

    int j = 0;
    for (int i = 0; i < len; i += 2)
    {
        temp[0] = hex[i];
        temp[1] = hex[i + 1];
        result[j] = (char)strtol(temp, NULL, 16);
        ++j;
    }
}

void map_chars(unsigned char str[], unsigned int result[])
{
    int len = strlen(str);

    for (int i = 0; i < len; ++i)
        if (str[i] >= 'a')
            result[i] = str[i] - 'a' + 10;
        else
            result[i] = str[i] - '0';
}

void inverse_map_chars(unsigned result[], unsigned char str[], int len)
{
    for (int i = 0; i < len; ++i)
        if (result[i] < 10)
            str[i] = result[i] + '0';
        else
            str[i] = result[i] - 10 + 'a';

    str[len] = 0x00;
}

int main(int argc, char *argv[])
{
    if (argc != 5)
    {
        printf("Usage: %s <key> <tweak> <radix> <path-to-plaintexts>\n", argv[0]);
        return 0;
    }

    unsigned char k[100],
        t[100],
        result[100];
    int xlen = 0,
        klen = strlen(argv[1]) / 2,
        tlen = strlen(argv[2]) / 2,
        radix = atoi(argv[3]);
    unsigned int x[100],
        y[100];
    unsigned int tmp;

    const verbose = 0;

    hex2chars(argv[1], k);
    hex2chars(argv[2], t);

    FILE *plaintexts;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;

    plaintexts = fopen(argv[4], "r");

    if (plaintexts == NULL)
    {
        puts("Couldn't open plaintext file!");
        exit(1);
    }

    while ((read = getline(&line, &len, plaintexts)) != -1)
    {

        line[read - 1] = '\0';

        if (read > sizeof(k))
        {
            puts("Input ciphertext too long!");
            exit(1);
        }

        xlen = read - 1;  
        map_chars(line, x);
    

        for (int i = 0; i < xlen; ++i)
            assert(x[i] < radix);

        FPE_KEY ff3;

        if (verbose)
        {
            printf("key:");
            for (int i = 0; i < klen; ++i)
                printf(" %02x", k[i]);
            puts("");
            if (tlen)
                printf("tweak:");
            for (int i = 0; i < tlen; ++i)
                printf(" %02x", t[i]);
            if (tlen)
                puts("");
        }

        FPE_set_ff3_key(k, klen * 8, t, radix, &ff3);

        if (verbose)
        {
            printf("after map: ");
            for (int i = 0; i < xlen; ++i)
                printf(" %d", x[i]);
            printf("\n\n");
        }

        if (verbose)
            printf("========== FF3 ==========\n");

        FPE_ff3_encrypt(x, y, xlen, &ff3, FPE_ENCRYPT);

        if (verbose)
        {
            printf("ciphertext(numeral string):");
            for (int i = 0; i < xlen; ++i)
                printf(" %d", y[i]);
            printf("\n");
        }

        inverse_map_chars(y, result, xlen);
        if (verbose)
            printf("ciphertext: %s\n\n", result);

        puts(result);
        

        FPE_unset_ff3_key(&ff3);

        // loop ends here
    }

    return 0;
}
