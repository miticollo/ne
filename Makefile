CFLAGS		= -Wall -Wextra -Wfloat-equal
CFLAGS		+= -Os

LDFLAGS		= -framework Foundation -framework NetworkExtension

IOS_OBJ		= ne

all: ne

ne: ne.m
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	ldid -S$@.entitlements $@

beautify: ne.m
	clang-format --verbose -i $^

clean:
	-$(RM) $(IOS_OBJ)

.PHONY: clean

