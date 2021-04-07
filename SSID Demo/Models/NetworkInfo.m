//
//  NetworkInfo.m
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import "NetworkInfo.h"

@implementation NetworkInfo

- (instancetype)initWithInterface:(NSString *)interfaceName success:(BOOL)success ssid:(NSString *)ssid bssid:(NSString *)bssid {
    if (self = [super init]) {
        self.interface = [NSString stringWithString:interfaceName];
        self.success = success;
        self.ssid = [NSString stringWithString:ssid];
        self.bssid = [NSString stringWithString:bssid];
    }
    return self;
}

@end
