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

// For strings
#import "string_tools.h"
#import "color_tools.h"

#define kBatteryNotInstalled -1

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
    Boolean deviceInstalled;
    CFStringRef productName;
};

struct bt_power_info_t
getBatteryPercentForBluetoothClass(const char *class){
    io_iterator_t iter = 0;
    struct bt_power_info_t powerInfo = {-1, NO, NULL};
    
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
                        powerInfo.deviceInstalled = YES;
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

int
getSystemBatterPercent(){
    CFTypeRef       info;
    CFArrayRef      list;
    CFDictionaryRef battery;
    int             batteryPercent = kBatteryNotInstalled;
    
    info = IOPSCopyPowerSourcesInfo();
    if (!info){
        return kBatteryNotInstalled;
    }
    
    list = IOPSCopyPowerSourcesList(info);
    
    if (!list){
        goto CLEANUP;
    }
    
    CFIndex c = CFArrayGetCount(list);
    if (c > 0){
        battery = IOPSGetPowerSourceDescription(info, CFArrayGetValueAtIndex(list, 0));
        int currentCapacity;
        
        CFNumberRef cc = CFDictionaryGetValue(battery, CFSTR(kIOPSCurrentCapacityKey));
        
        if (CFNumberGetValue(cc, kCFNumberSInt64Type, &currentCapacity)){
            batteryPercent = currentCapacity;
        }
    }
    
    CFRelease(list);
    
CLEANUP:
    CFRelease(info);
    return batteryPercent;
    
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
    size_t maxLen;
    char *leader = "     ";
    char *trailer = leader;
    char *devName = "Device Name ";
    char *pctName = "| Percent Remaining";
    size_t devLen = strlen(devName);
    size_t pctLen = strlen(pctName);
    
    // Get maxlen and sizes
    size_t *sizes = malloc(sizeof(int)*n);
    for (i = 0; i < n; i++){
        size_t len = GetStringLength(names[i]);
        sizes[i] = len;
        if (len > maxLen)
            maxLen = len;
    }
    
    // Print header
    printf("\nBattery Percentages:\n\n");
    size_t numFiller = ti.cols - leftSide - rightSide - devLen - pctLen;

    if (ti.cols < leftSide + rightSide + devLen + pctLen) numFiller = 0;
    
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
        if (ti.cols < leftSide + rightSide + pctLen + sizes[i]) nDots = 0;
        char *dots = malloc(sizeof(char) * nDots);
        dots = mkChars('.', dots, nDots);
        printf("%s%s %s %s%s\n", leader, names[i], dots, coloredOutput, trailer);
        free(dots);
        free(coloredOutput);
    }
    
    free(sizes);
    printf("\n");
}


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
            struct bt_power_info_t bp = getBatteryPercentForBluetoothClass([str UTF8String]);
            if (bp.deviceInstalled){
                names[i] = [(__bridge NSString *)bp.productName UTF8String];
                percts[i] = bp.batteryPercent;
                i++;
            } else {
                printf("No devices of class %s installed.\n", [str UTF8String]);
            }
            
            if (bp.productName){
                CFRelease(bp.productName);
            }
        }
        
        int batteryPercent = getSystemBatterPercent();
        if (batteryPercent != kBatteryNotInstalled){
            names[i] = "System Battery";
            percts[i] = batteryPercent;
            i++;
//            printf("System Battery -> %d%%\n", batteryPercent);
        }
        
        PrintBatteryInfo(names, percts, i);
        
    }
    return 0;
}

