//
//  Data.h
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SingleItem : NSObject <NSSecureCoding>

@property (strong, nonatomic) NSString* ssid;
@property (strong, nonatomic) NSString* bssid;

- (instancetype)initWithSsid:(NSString*)ssid bssid:(NSString*)bssid;

@end

@interface Data : NSObject <NSSecureCoding>

@property (nonatomic, strong) NSString* floorMsg;
@property (nonatomic, strong) SingleItem* item;
@property (class) NSURL* archiveURL;

- (instancetype)initWithFloor:(NSString*)floorMsg item:(SingleItem*) item;
+ (void)saveData:(NSMutableArray<Data*>*)allData;
+ (NSMutableArray<Data*>*)loadData;

@end

NS_ASSUME_NONNULL_END
