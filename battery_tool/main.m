//
//  main.m
//  battery_tool
//
//  Created by Brian Wilson on 2/11/13.
//  Copyright (c) 2013 Polytopes. All rights reserved.
//

#import <Foundation/Foundation.h>

// For Bluetooth devices
#include <IOKit/IOKitLib.h>

// For System Power
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>


#define kBatteryNotInstalled -1.0

static void printKeys (const void *key, const void* value, void *context){
    CFShow(CFSTR("Key "));
    CFShow(key);
    CFShow(CFSTR("Value "));
    CFShow(value);
    
}

void
printDictKeys(CFDictionaryRef d){
    CFDictionaryApplyFunction(d, printKeys, NULL);
}

static CFStringRef kBatteryPercentField = CFSTR("BatteryPercent");
static CFStringRef kProductField = CFSTR("Product");

struct bt_power_info_t {
    int batteryPercent;
    CFStringRef productName;
};

struct bt_power_info_t
getBatteryPercentForBluetoothClass(const char *class){
    io_iterator_t iter = 0;
    struct bt_power_info_t powerInfo = {-1, NULL};
    
    CFMutableDictionaryRef m = IOServiceMatching(class);
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, m, &iter) == KERN_SUCCESS){
        io_registry_entry_t entry = IOIteratorNext(iter);
        if (entry){
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS){
                //                printDictKeys(dict);
                //                CFNumberRef bp_r = (CFNumberRef)CFDictionaryGetValue(dict, CFSTR("BatteryPercent"));
                CFNumberRef bp_r = (CFNumberRef)CFDictionaryGetValue(dict, kBatteryPercentField);
                if (bp_r){
                    int32_t bp = 0;
                    if (CFNumberGetValue(bp_r, kCFNumberSInt32Type, &bp)){
                        powerInfo.batteryPercent = bp;
                    }
                    
                }
                CFStringRef pName = (CFStringRef)CFDictionaryGetValue(dict, kProductField);
                if (pName){
                    CFRetain(pName);
                    powerInfo.productName = pName;
                }
            }
            CFRelease(dict);
        }
        IOObjectRelease(entry);
    }
    IOObjectRelease(iter);
    
    return powerInfo;
}

double
getSystemBatterPercent(){
    CFTypeRef       info;
    CFArrayRef      list;
    CFDictionaryRef battery;
    double          batteryPercent = kBatteryNotInstalled;
    
    info = IOPSCopyPowerSourcesInfo();
    if (!info){
        return kBatteryNotInstalled;
    }
    
    list = IOPSCopyPowerSourcesList(info);
    
    if (!list){
        goto CLEANUP;
    }
    
    if (CFArrayGetCount(list) && (battery = IOPSGetPowerSourceDescription(info, 0))){
        double currentCapacity;
        double maxCapacity;
        
        CFNumberRef cc = CFDictionaryGetValue(battery, kIOPSCurrentCapacityKey);
        CFNumberRef mp = CFDictionaryGetValue(battery, kIOPSMaxCapacityKey);
        
        CFNumberGetValue(cc, kCFNumberDoubleType, &currentCapacity);
        CFNumberGetValue(mp, kCFNumberDoubleType, &maxCapacity);
        
        assert(maxCapacity != 0);
        
        batteryPercent = (currentCapacity/maxCapacity) * 100;
        
    }
    
    CFRelease(list);
    
CLEANUP:
    CFRelease(info);
    return batteryPercent;
    
}


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        NSArray *a = @[@"BNBMouseDevice", @"BNBTrackpadDevice", @"AppleBluetoothHIDKeyboard"];
        for (NSString *str in a) {
            struct bt_power_info_t bp = getBatteryPercentForBluetoothClass([str UTF8String]);
            printf("%s(%s) -> %d%%\n",
                   [(__bridge NSString *)bp.productName UTF8String],
                   [str UTF8String],
                   bp.batteryPercent);
            
            if (bp.productName){
                CFRelease(bp.productName);
            }
        }
        
        double batteryPercent = getSystemBatterPercent();
        if (batteryPercent == kBatteryNotInstalled){
            printf("System battery not installed.\n");
        } else {
            printf("System Battery -> %.2f%%\n", batteryPercent);
        }
        
    }
    return 0;
}

