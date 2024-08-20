#!/bin/bash
nasm -felf64 calculator.asm 
ld calculator.o
