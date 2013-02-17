//
//  color_tools.c
//  battery_tool
//
//  Created by Brian Wilson on 2/17/13.
//  Copyright (c) 2013 Polytopes. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "color_tools.h"

static const char kDEFAULT = 127;


char *
MakeColorString(int color){
    // "E[33;m"
    char *cstr = malloc(sizeof(char)*7);
    snprintf(cstr, 7, "%c[%d;m", kESC, color);
    return cstr;
}

char *
MakeBlinkColorString(int color){
    // "E[8;33;m"
    char *cstr = malloc(sizeof(char)*9);
    snprintf(cstr, 9, "%c[%d;%d;m", kESC, BLINK, color);
    return cstr;
}

char *
MakeResetString(){
    char *reset = malloc(sizeof(char)*5);
    snprintf(reset, 5, "%c[%dm", kESC, RESET);
    return reset;
}

size_t
NumberOfDigits(int v){
    long n = 1;
    int count = 0;
    
    if (v == 0) return 1;
    
    if (v < 0) count++; // (digit for -)
    
    while (n <= abs(v)){
        n = n * 10;
        count++;
    }
    
    return count;
}

char *
MakeWarningString(int levels[], int value){
    int dire = levels[0];
    int bad = levels[1];
    int worrysome = levels[2];
    
    size_t colorsLength;
    size_t lengthOfValue = NumberOfDigits(value)+1;
    
    char *reset = MakeResetString();
    char *cstr;
    
    if (value > worrysome){
        cstr = MakeColorString(GREEN);
    } else if (value > bad){
        cstr = MakeColorString(YELLOW);
    } else if (value > dire){
        cstr = MakeColorString(RED);
    } else {
        cstr = MakeBlinkColorString(RED);
    }
    
    colorsLength = strlen(reset) + strlen(cstr)+lengthOfValue;
    char *output = malloc(sizeof(char)*(colorsLength + 1));
    
    snprintf(output, colorsLength+1, "%s%d%%%s", cstr, value, reset);
    
    free(reset);
    free(cstr);
    
    return output;
}