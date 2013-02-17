//
//  string_tools.c
//  battery_tool
//
//  Created by Brian Wilson on 2/16/13.
//  Copyright (c) 2013 Polytopes. All rights reserved.
//
#include <stdio.h>
#include <string.h>
#include <wchar.h>
#include <stdlib.h>
#include <locale.h>
#include <assert.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include "string_tools.h"


size_t
GetStringLength(const char *str){
    
    size_t totalStringLength = 0;
    
    size_t maxBytes = strlen(str); // May be bigger than needed
    wchar_t *output = malloc(sizeof(wchar_t) * maxBytes + 1);
    size_t bytesToConvert = mbstowcs(output, str, maxBytes);
    assert(bytesToConvert <= maxBytes);
    if (output){
        totalStringLength = (size_t)wcswidth(output, maxBytes);
        free(output);
    }
    
    return totalStringLength;
}

struct term_info GetTermInfo(){
    struct term_info info;
    
#ifdef TIOCGSIZE
    struct ttysize ts;
    ioctl(STDIN_FILENO, TIOCGSIZE, &ts);
    info.cols = ts.ts_cols;
    info.rows = ts.ts_lines;
#elif defined(TIOCGWINSZ)
    struct winsize ts;
    ioctl(STDIN_FILENO, TIOCGWINSZ, &ts);
    info.cols = ts.ws_col;
    info.rows = ts.ws_row;
#endif /* TIOCGSIZE */
    
    return info;

}