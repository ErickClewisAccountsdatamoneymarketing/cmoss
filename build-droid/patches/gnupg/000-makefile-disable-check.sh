#!/bin/sh

mv "Makefile" "Makefile~"
sed '/checks =/d' "Makefile~" > "Makefile"  # Patch Makefile to disable checks
