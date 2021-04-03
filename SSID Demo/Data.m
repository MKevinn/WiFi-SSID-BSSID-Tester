//
//  Data.m
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import "Data.h"

@implementation SingleItem

+ (BOOL)supportsSecureCoding {
    return true;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_ssid forKey:@"ssid"];
    [coder encodeObject:_bssid forKey:@"bssid"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _ssid = [coder decodeObjectForKey:@"ssid"];
        _bssid = [coder decodeObjectForKey:@"bssid"];
    }
    return self;
}

- (instancetype)initWithSsid:(NSString *)ssid bssid:(NSString *)bssid {
    if (self = [super init]) {
        self.ssid = ssid;
        self.bssid = bssid;
    }
    return self;
}

@end

@implementation Data

static NSURL* _archiveURL;

+ (NSURL *)archiveURL {
    return _archiveURL;
}

+ (void)setArchiveURL:(NSURL *)archiveURL {
    _archiveURL = archiveURL;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_floorMsg forKey:@"floorMsg"];
    [coder encodeObject:_items forKey:@"items"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _floorMsg = [coder decodeObjectForKey:@"floorMsg"];
        _items = [coder decodeObjectForKey:@"items"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return true;
}

- (instancetype)initWithFloor:(NSString*)floorMsg items:(NSMutableArray<SingleItem *> *)items {
    if (self = [super init]) {
        _floorMsg = floorMsg;
        _items = [NSMutableArray arrayWithArray:items];
    }
    return self;
}

+ (void)saveData:(NSMutableArray<Data *> *)allData {
    NSError* err;
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:allData requiringSecureCoding:false error:&err];
    [data writeToURL:_archiveURL atomically:true];
}

+ (NSMutableArray<Data *> *)loadData {
    [Data setArchiveURL:[[[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"data"] URLByAppendingPathExtension:@"plist"]];
    NSData* data = [NSData dataWithContentsOfURL:_archiveURL];
    NSError* err;
    NSMutableArray<Data*>* allData = (NSMutableArray<Data*>*)[NSKeyedUnarchiver unarchivedObjectOfClass:NSObject.class fromData:data error:&err];
    return allData;
}

@end
