#!/bin/bash
echo "Hello, World (from my Linode!)" > index.html
nohup busybox httpd -f -p 80 &