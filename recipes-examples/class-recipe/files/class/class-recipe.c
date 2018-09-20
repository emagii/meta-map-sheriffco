#include <stdio.h>

#ifdef	DEVELOPMENT
#define	CLASS_TYPE	"development"
#elif	defined(PRODUCTION)
#define	CLASS_TYPE	"production"
#elif	defined(RELEASE)
#define	CLASS_TYPE	"release"
#else
#define	CLASS_TYPE	"<undefined class>"
#endif

const	char	*class = CLASS_TYPE;

int main(void)
{
	printf("class: %s\n", class);
}
