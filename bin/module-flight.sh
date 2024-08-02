#!/bin/bash
sudo sh -c "chat -t 1 -sv '' AT OK 'AT+CFUN=4' OK < /dev/ttyUSB2 > /dev/ttyUSB2"
