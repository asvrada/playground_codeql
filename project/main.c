#include <stdio.h>
#include <stdlib.h>

// Query about dataflow
void query_dataflow_pointer_free()
{
    // Freed
    {
        char *p = malloc(10);
        free(p);
    }

    // Not freed
    {
        char *p = malloc(10);
        // p not freed
    }

    // Indrect not free
    {
        char *p = malloc(10);
        char *q = p;
        // p not freed
    }

    // Indrect freed
    {
        char *p = malloc(10);
        char *q = p;
        free(q);
    }

    // Freed after use
    {
        char *p = malloc(10);
        free(p);
        printf("%p\n", p);
    }
}

int oe_is_outside_enclave(void *ptr)
{
    // Don't actually check
    (void *)ptr;
    // Just return yes for testing purpose
    return 1;
}

// Test cases around missing call to oe_is_outside_enclave
void query_outside()
{
    // Positive case
    // We call oe_is_outside_enclave then access pointer
    {
        void *ptr = malloc(16);
        // Make sure the ptr is from outside enclave
        if (oe_is_outside_enclave(ptr))
        {
            // Our code doesn't check for variable initialization
            // So break it down to two lines
            void *internal = NULL;
            internal = ptr;
            // Safe to use ptr
            printf("%p\n", internal);
        }
    }

    // Negative case
    // We don't call
    {
        void *ptr = malloc(16);
        // Our code doesn't check for variable initialization
        // So break it down to two lines
        void *internal = NULL;
        internal = ptr;
        // Not safe, should see CodeQL Error
        printf("%p\n", internal);
    }
}

int main(int argc, char **argv)
{
    char *message = "Hello, from demo22!";
    printf("%s\n", message);

    query_dataflow_pointer_free();
    query_outside();
    return 0;
}
