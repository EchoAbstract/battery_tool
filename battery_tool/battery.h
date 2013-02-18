//
//  battery.h
//  battery_tool
//
//  Created by Brian Wilson on 2/17/13.
//  Copyright (c) 2013 Polytopes. All rights reserved.
//

#ifndef battery_tool_battery_h
#define battery_tool_battery_h

#define kBatteryNotInstalled -1

struct bt_power_info_t {
    int batteryPercent;
    Boolean deviceInstalled;
    CFStringRef productName;
};

int GetSystemBatterPercent();
struct bt_power_info_t GetBatteryPercentForBluetoothClass(const char *class);


#endif
