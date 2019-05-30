#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

#define MAXKW     10     /* Maximum number of keywords */
#define MAXREPL   50     /* Maximum number of target files */
#define MAXSTRING 256    /* Maximum number of line length */

typedef struct input_gen_struct
{
    int             n_keywords;
    int             n_replace;
    char            keyword[MAXREPL][MAXSTRING];
    char            fname[MAXREPL][MAXSTRING];
    char            replace[MAXREPL][MAXKW][MAXSTRING];
} input_gen_struct;

void ReadConfig(const char *fname, input_gen_struct *input_gen)
{
    FILE           *config_file;
    int             bytes_now;
    int             bytes_consumed;
    char            cmdstr[MAXSTRING];
    char            optstr[MAXSTRING];
    char            buffer[MAXSTRING];
    char            temp[MAXSTRING];
    int             match;
    int             counter;
    int             i;

    /*
     * Open configuration file
     */
    config_file = fopen(fname, "r");
    if (!config_file)
    {
        printf("Unable to open configuration file %s!!\n", fname);
        exit(EXIT_FAILURE);
    }

    /*
     * Read header line
     */
    fgets(cmdstr, MAXSTRING, config_file);

    match = sscanf(cmdstr, "%s %[^\n]", optstr, buffer);
    if (match != 2 || strcasecmp("DEST_FILE", optstr) != 0)
    {
        printf("Header line format error.\n");
        printf("Please refer to README file.\n");
        exit(EXIT_FAILURE);
    }

    /* Read keywords to be replaced (should start with "$") */
    counter = 0;
    bytes_consumed = 0;
    while (1)
    {
        match = sscanf(buffer + bytes_consumed, "%s%n",
            temp, &bytes_now);
        if (match != 1)
        {
            break;
        }
        else if (temp[0] != '$')
        {
            printf("Header line keyword format error.\n");
            printf("Please refer to README file.\n");
            exit(EXIT_FAILURE);
        }
        else
        {
            strcpy(&(input_gen->keyword[counter][0]), temp);
            counter++;
            bytes_consumed += bytes_now;
        }
    }

    input_gen->n_keywords = counter;

    /*
     * Read each line of configuration
     */
    counter = 0;
    while (1)
    {
        if (fgets(cmdstr, MAXSTRING, config_file) == NULL)
        {
            break;
        }
        else
        {
            match = sscanf(cmdstr, "%s %[^\n]", input_gen->fname[counter],
                buffer);
            if (match != 2)
            {
                printf("Configuration format error.\n");
                printf("Please refer to README file.\n");
                exit(EXIT_FAILURE);
            }

            /* Read replace words */
            bytes_consumed = 0;
            for (i = 0; i < input_gen->n_keywords; i++)
            {
                match = sscanf(buffer + bytes_consumed, "%s%n",
                        input_gen->replace[counter][i], &bytes_now);
                if (match != 1)
                {
                    printf("Configuration format error.\n");
                    printf("Please refer to README file.\n");
                    exit(EXIT_FAILURE);
                }
                else
                {
                    bytes_consumed += bytes_now;
                }
            }

            counter++;
        }
    }

    input_gen->n_replace = counter;

    fclose(config_file);
}

void Replace(const char template_name[MAXSTRING], const char fname[MAXSTRING],
    const char outdir[MAXSTRING], char keyword[][MAXSTRING],
    char replace[][MAXSTRING], int n_keywords)
{
    FILE           *template;
    FILE           *dest;
    char            string[MAXSTRING];
    char            fpath[MAXSTRING];
    char           *ptr1, *ptr2;
    int             i;
    int             flag = 0;

    /* Open input file in read mode */
    template = fopen(template_name, "r");

    /* Error handling */
    if (!template)
    {
        printf("Unable to open the input file!!\n");
        exit(EXIT_FAILURE);
    }

    /* Open temporary file in write mode */
    sprintf(fpath, "%s/%s", outdir, fname);
    dest = fopen(fpath, "w");

    /* Error handling */
    if (!dest)
    {
        printf("Unable to open destination file %s!!\n", fname);
        exit(EXIT_FAILURE);
    }

    /* Delete the given word from the file */
    while (!feof(template))
    {
        flag = 0;
        strcpy(string, "\0");

        /* Read line by line from the input file */
        fgets(string, MAXSTRING, template);

        /*
         * Check whether the word to delete is present in the current scanned
         * line
         */
        for (i = 0; i < n_keywords; i++)
        {
            if (strstr(string, keyword[i]))
            {
                flag = 1;

                ptr2 = string;
                while ((ptr1 = strstr(ptr2, keyword[i])))
                {
                    /*
                     * letters present before the word to be replaced
                     */
                    while (ptr2 != ptr1)
                    {
                        fputc(*ptr2, dest);
                        ptr2++;
                    }
                    /* Skip the word to be replaced */
                    ptr1 = ptr1 + strlen(keyword[i]);
                    fprintf(dest, "%s", replace[i]);
                    ptr2 = ptr1;
                }

                /* Characters present after the word to be replaced */
                while (*ptr2 != '\0')
                {
                    fputc(*ptr2, dest);
                    ptr2++;
                }

                break;
            }
        }

        if (0 == flag)
        {
            /*
             * current scanned line doesn't have the word that need to be
             * replaced
             */
            fputs(string, dest);
        }
    }

    /* Close the opened files */
    fclose(template);
    fclose(dest);
}

int main(int argc, char *argv[])
{
    char            template_name[MAXSTRING];
    char            config_name[MAXSTRING];
    char            outdir[MAXSTRING];
    int             i;
    input_gen_struct input_gen;

  /*
   * Get template file name and configuration file name from command line
   */
    if (argc != 4)
    {
        printf(
            "Please specify names of template file and configuration file, "
            "and path for generated files.\n");
        return(EXIT_FAILURE);
    }

    strcpy(template_name, argv[1]);
    strcpy(config_name, argv[2]);
    strcpy(outdir, argv[3]);

    /*
     * Read configuration file
     */
    ReadConfig(config_name, &input_gen);

    /*
     * Replace keywords from template file
     */
    mkdir(outdir, 0755);

    for (i = 0; i < input_gen.n_replace; i++)
    {
        Replace(template_name, input_gen.fname[i], outdir, input_gen.keyword,
            input_gen.replace[i], input_gen.n_keywords);
    }

    return 0;
}
