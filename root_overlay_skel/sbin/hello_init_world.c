#include <linux/unistd.h>
#include <stdio.h>

int main() {
	const char *message = "Hello, I'm init!";
	write(stdout, message, sizeof(message));
	while(1);
}
