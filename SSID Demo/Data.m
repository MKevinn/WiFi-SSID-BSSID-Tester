//
//  Data.m
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import "Data.h"

@implementation SingleItem

- (instancetype)initWithSsid:(NSString *)ssid bssid:(NSString *)bssid {
    if (self = [super init]) {
        self.ssid = ssid;
        self.bssid = bssid;
    }
    return self;
}

@end

@implementation Data

- (instancetype)initWithFloor:(int)floorNum items:(NSMutableArray<SingleItem *> *)items {
    if (self = [super init]) {
        self.floorNum = floorNum;
        self.items = [NSMutableArray arrayWithArray:items];
    }
    return self;
}

@end
