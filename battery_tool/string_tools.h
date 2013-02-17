//
//  string_tools.h
//  battery_tool
//
//  Created by Brian Wilson on 2/16/13.
//  Copyright (c) 2013 Polytopes. All rights reserved.
//

#ifndef battery_tool_string_tools_h
#define battery_tool_string_tools_h

struct term_info {
    int rows;
    int cols;
};

size_t GetStringLength(const char *str);
struct term_info GetTermInfo();
void PrintTwoStrings(char *one, char *two);

#endif
