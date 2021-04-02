//
//  ViewController.h
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>

#define MAS_SHORTHAND
#import "Masonry.h"
#import "Data.h"
#import "NetworkInfo.h"

@interface ViewController : UIViewController

@property (nonatomic,strong) NSMutableArray<Data*>* allData;

@end

