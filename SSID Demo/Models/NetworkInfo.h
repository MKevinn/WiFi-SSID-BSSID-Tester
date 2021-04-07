//
//  NetworkInfo.h
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkInfo : NSObject

@property (copy, nonatomic) NSString* interface;
@property (assign, nonatomic) BOOL success;
@property (copy, nonatomic) NSString* ssid;
@property (copy, nonatomic) NSString* bssid;

- (instancetype)initWithInterface:(NSString*)interfaceName success:(BOOL)success ssid:(NSString*)ssid bssid:(NSString*)bssid;

@end

NS_ASSUME_NONNULL_END
