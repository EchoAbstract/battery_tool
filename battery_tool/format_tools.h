//
//  color_tools.h
//  battery_tool
//
//  Created by Brian Wilson on 2/17/13.
//  Copyright (c) 2013 Polytopes. All rights reserved.
//

#ifndef battery_tool_color_tools_h
#define battery_tool_color_tools_h

const static char kESC = 27;

typedef enum escape_code {
    // Attributes
    RESET     = 0,
    BOLD      = 1,
    UNDERLINE = 4,
    BLINK     = 5,
    REVERSE   = 7,
    INVISIBLE = 8,
    
    // Foreground Colors
    BLACK     = 30,
    RED       = 31,
    GREEN     = 32,
    YELLOW    = 33,
    BLUE      = 34,
    MAGENTA   = 35,
    CYAN      = 36,
    WHITE     = 37,
    
    // Background Colors
    BG_BLACK  = 40,
    BG_RED    = 41,
    BG_GREEN  = 42,
    BG_YELLOW = 43,
    BG_BLUE   = 44,
    BG_MAGENTA= 45,
    BG_CYAN   = 46,
    BG_WHITE  = 47
    
} ESCAPE_CODE;


char *MakeWarningString(int levels[], int value);
void PrintBatteryInfo(const char *names[], const int percentages[], const int n);


#endif
