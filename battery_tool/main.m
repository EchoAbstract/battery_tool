//
//  main.m
//  battery_tool
//
//  Created by Brian Wilson on 2/11/13.
//  Copyright (c) 2013 Polytopes. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "battery.h"
#import "format_tools.h"



int main(int argc, const char * argv[])
{

    @autoreleasepool {

        // Use the user's locale, but fall back to UTF-8
        if (!setlocale(LC_CTYPE, "")){
            setlocale(LC_ALL, "en_US.UTF-8");
        }
        
        const char *names[10];
        int percts[10];
        int i = 0;

        NSArray *a = @[@"BNBMouseDevice", @"BNBTrackpadDevice", @"AppleBluetoothHIDKeyboard"];
        for (NSString *str in a) {
            struct bt_power_info_t bp = GetBatteryPercentForBluetoothClass([str UTF8String]);
            if (bp.deviceInstalled){
                names[i] = [(__bridge NSString *)bp.productName UTF8String];
                percts[i] = bp.batteryPercent;
                i++;
            }
            
            if (bp.productName){
                CFRelease(bp.productName);
            }
        }
        
        int batteryPercent = GetSystemBatterPercent();
        if (batteryPercent != kBatteryNotInstalled){
            names[i] = "System Battery";
            percts[i] = batteryPercent;
            i++;
        }
        
        PrintBatteryInfo(names, percts, i);
        
    }
    return 0;
}

