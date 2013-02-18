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
#include "format_tools.h"
#include "string_tools.h"

static const char kDEFAULT = 127;


char *
makeColorString(int color){
    // "E[33;m"
    char *cstr = malloc(sizeof(char)*7);
    snprintf(cstr, 7, "%c[%d;m", kESC, color);
    return cstr;
}

char *
makeBlinkColorString(int color){
    // "E[8;33;m"
    char *cstr = malloc(sizeof(char)*9);
    snprintf(cstr, 9, "%c[%d;%d;m", kESC, BLINK, color);
    return cstr;
}

char *
makeResetString(){
    char *reset = malloc(sizeof(char)*5);
    snprintf(reset, 5, "%c[%dm", kESC, RESET);
    return reset;
}

size_t
numberOfDigits(int v){
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
    size_t lengthOfValue = numberOfDigits(value)+1;
    
    char *reset = makeResetString();
    char *cstr;
    
    if (value > worrysome){
        cstr = makeColorString(GREEN);
    } else if (value > bad){
        cstr = makeColorString(YELLOW);
    } else if (value > dire){
        cstr = makeColorString(RED);
    } else {
        cstr = makeBlinkColorString(RED);
    }
    
    colorsLength = strlen(reset) + strlen(cstr)+lengthOfValue;
    char *output = malloc(sizeof(char)*(colorsLength + 1));
    
    snprintf(output, colorsLength+1, "%s%d%%%s", cstr, value, reset);
    
    free(reset);
    free(cstr);
    
    return output;
}

char *
mkChars(char c, char *output, size_t n){
    int i;
    for (i = 0; i < n; i++){
        output[i] = c;
    }
    output[i] = '\0';
    return output;
}

void PrintBatteryInfo(const char *names[], const int percentages[], const int n){
    struct term_info ti = GetTermInfo();
    int i, leftSide = 5, rightSide = 5;
    char *leader = "     ";
    char *trailer = leader;
    char *devName = "Device Name ";
    char *pctName = "| Percent Remaining";
    size_t devLen = strlen(devName);
    size_t pctLen = strlen(pctName);
    
    // Nothing to do
    if (n == 0){
        return;
    }
    
    // Get maxlen and sizes
    size_t *sizes = malloc(sizeof(size_t)*n);
    for (i = 0; i < n; i++){
        size_t len = GetStringLength(names[i]);
        sizes[i] = len;
    }
    
    // Print header
    printf("\nBattery Percentages:\n\n");
    size_t numFiller = ti.cols - leftSide - rightSide - devLen - pctLen;
    
    if (ti.cols < leftSide + rightSide + devLen + pctLen) numFiller = 1; // For the \0
    
    char *filler = malloc(sizeof(char) * numFiller);
    filler = mkChars(' ', filler, numFiller);
    printf("%s%s%s%s%s\n", leader, devName, filler, pctName, trailer);
    free(filler);
    
    filler = malloc(sizeof(char) * (ti.cols));
    filler = mkChars('-', filler, ti.cols);
    printf("%s\n", filler);
    free(filler);
    
    int levels[3] = {10, 33, 66};
    for (i = 0; i < n; i++){
        char *coloredOutput = MakeWarningString(levels, percentages[i]);
        size_t nDots = ti.cols - leftSide - rightSide - pctLen - sizes[i];
        if (ti.cols < leftSide + rightSide + pctLen + sizes[i]) nDots = 1; // For the \0
        char *dots = malloc(sizeof(char) * nDots);
        dots = mkChars('.', dots, nDots);
        printf("%s%s %s %s%s\n", leader, names[i], dots, coloredOutput, trailer);
        free(dots);
        free(coloredOutput);
    }
    
    free(sizes);
    printf("\n");
}
