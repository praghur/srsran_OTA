#!/bin/bash
sudo sh -c "chat -t 1 -sv '' AT OK 'AT+CFUN=0' OK < /dev/ttyUSB2 > /dev/ttyUSB2"
