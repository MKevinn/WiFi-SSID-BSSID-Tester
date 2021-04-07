//
//  DisplayViewController.h
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "Data.h"
#define MAS_SHORTHAND
#import "Masonry.h"
#import "Data.h"

NS_ASSUME_NONNULL_BEGIN

@interface DisplayViewController : UIViewController

@property (nonatomic,strong) NSMutableArray<Data*>* allData;

@end

NS_ASSUME_NONNULL_END
