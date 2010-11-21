#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#include <stdlib.h>

#define OFF 0x00
#define BLUE 0x01
#define RED 0x02
#define GREEN 0x02
#define LTBLUE 0x02
#define PURPLE 0x02
#define YELLOW 0x02
#define WHITE 0x02

void MyInputCallback(void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength)
{
    NSLog(@"MyInputCallback called");
    // process device response buffer (report) here 
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    IOReturn sendRet;
    IOReturn ret;
    const long productId = 0x1320;
    const long vendorId = 0x1294;
    size_t bufferSize = 5;
    char *inputBuffer = malloc(bufferSize);
    char *outputBuffer = malloc(bufferSize);
    memset(outputBuffer, 0, bufferSize);
    unsigned int color = 0x01;
    unsigned int count = 10;
    
    //0) get color from command line
    if(argc > 1){
        color = atoi(argv[1]);
    }
    if(argc > 2){
        count = 2 * atoi(argv[2]);//since half the time we're off, double the number of blinks
    }
    

    //1) Setup your manager and schedule it with the main run loop:
    
    IOHIDManagerRef managerRef = IOHIDManagerCreate(kCFAllocatorDefault,
                                                    kIOHIDOptionsTypeNone);
    IOHIDManagerScheduleWithRunLoop(managerRef, CFRunLoopGetMain(),
                                    kCFRunLoopDefaultMode);
    ret = IOHIDManagerOpen(managerRef, 0L);
    
    //2) Get your device:
    

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithLong:productId] forKey:[NSString
                                                                stringWithCString:kIOHIDProductIDKey encoding:NSUTF8StringEncoding]];
    [dict setObject:[NSNumber numberWithLong:vendorId] forKey:[NSString
                                                               stringWithCString:kIOHIDVendorIDKey encoding:NSUTF8StringEncoding]];
    IOHIDManagerSetDeviceMatching(managerRef, (CFMutableDictionaryRef)dict); NSSet *allDevices = [((NSSet *)IOHIDManagerCopyDevices(managerRef)) autorelease];
    NSArray *deviceRefs = [allDevices allObjects];
    IOHIDDeviceRef deviceRef = ([deviceRefs count]) ?
    (IOHIDDeviceRef)[deviceRefs objectAtIndex:0] : nil;
    
    //3) Setup your buffers (I'm making the assumption the input and output buffer sizes are 64 bytes):
    

    IOHIDDeviceRegisterInputReportCallback(deviceRef, (uint8_t *)inputBuffer, bufferSize, MyInputCallback, NULL);
    
    //4) Send your message to the device (I'm assuming report ID 0):
    
    // populate output buffer
    // ....
   
    if(count > 0){
        for(int i = 0; i < count; i++){
            if(i % 2 == 0){
                outputBuffer[0] = color;
            }else{
                outputBuffer[0] = 0x00;
            }
            sendRet = IOHIDDeviceSetReport(deviceRef, kIOHIDReportTypeOutput, 0, (uint8_t *)outputBuffer, bufferSize);
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        }
    }else{
        outputBuffer[0] = color;
        sendRet = IOHIDDeviceSetReport(deviceRef, kIOHIDReportTypeOutput, 0, (uint8_t *)outputBuffer, bufferSize);        
    }

    //5) Enter main run loop (which will call MyInputCallback when data has come back from the device):
    
    //[[NSRunLoop mainRunLoop] run];
    
    
    
    [pool drain];
    return 0;
}


