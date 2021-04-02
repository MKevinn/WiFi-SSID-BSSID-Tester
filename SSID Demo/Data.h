//
//  Data.h
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SingleItem : NSObject

@property (strong, nonatomic) NSString* ssid;
@property (strong, nonatomic) NSString* bssid;

- (instancetype)initWithSsid:(NSString*)ssid bssid:(NSString*)bssid;

@end

@interface Data : NSObject

@property (nonatomic, assign) int floorNum;
@property (nonatomic, strong) NSMutableArray<SingleItem*>* items;

- (instancetype)initWithFloor:(int)floorNum items:(NSMutableArray<SingleItem*>*) items;

@end

NS_ASSUME_NONNULL_END
