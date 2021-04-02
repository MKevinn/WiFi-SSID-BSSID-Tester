//
//  ViewController.m
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import "ViewController.h"

@interface ViewController () <CLLocationManagerDelegate>

@property (assign, nonatomic) int floorNum;

@property (strong, nonatomic) CLLocationManager* locManager;
@property (strong, nonatomic) UILabel* ssidLb;
@property (strong, nonatomic) UILabel* bssidLb;
@property (strong, nonatomic) UIButton* updateBt;
@property (strong, nonatomic) UIStepper* stepper;
@property (strong, nonatomic) UILabel* floorLb;
@property (strong, nonatomic) NSArray<NetworkInfo*>* currentNetworkInfos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _floorNum = 1;
    [self readDataFromLocal];
    [self initUI];
    [self requestLocation];
}

- (void)readDataFromLocal {
    _allData = NSMutableArray.new;      // FIX ME !!!!!!
}

- (void)updateWifi {
    _currentNetworkInfos = [NSArray arrayWithArray:[self fetchNetworkInfo]];
    _ssidLb.text = [@"SSID: " stringByAppendingString:_currentNetworkInfos.firstObject.success ? _currentNetworkInfos.firstObject.ssid:@"N/A"];
    _bssidLb.text = [@"BSSID: " stringByAppendingString:_currentNetworkInfos.firstObject.success ? _currentNetworkInfos.firstObject.bssid:@"N/A"];
    if (_currentNetworkInfos.firstObject.success) {
        _ssidLb.text = [@"SSID: " stringByAppendingString:_currentNetworkInfos.firstObject.ssid];
        _bssidLb.text = [@"BSSID: " stringByAppendingString:_currentNetworkInfos.firstObject.bssid];
        BOOL exists = false;
        for (Data* floorData in _allData) {
            if (floorData.floorNum == _floorNum) {
                [floorData.items addObject: [[SingleItem alloc] initWithSsid:_currentNetworkInfos.firstObject.ssid bssid:_currentNetworkInfos.firstObject.bssid]];
                exists = true;
            }
        }
        if (!exists) {
            Data* floorData = [[Data alloc] initWithFloor:_floorNum items: [[NSMutableArray<SingleItem*> alloc] init]];
            [floorData.items addObject:[[SingleItem alloc] initWithSsid:_currentNetworkInfos.firstObject.ssid bssid:_currentNetworkInfos.firstObject.bssid]];
            [_allData addObject:floorData];
        }
    } else {
        _ssidLb.text = @"SSID: N/A";
        _bssidLb.text = @"BSSID: N/A";
    }
}

- (void)stepperValueChanged {
    _floorNum = _stepper.value;
    _floorLb.text = [NSString stringWithFormat:@"楼层 %d",_floorNum];
}

- (void)requestLocation {
    _locManager = CLLocationManager.new;
    [_locManager requestWhenInUseAuthorization];
    _locManager.delegate = self;
    _locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locManager startUpdatingLocation];
}

- (NSArray<NetworkInfo*>*)fetchNetworkInfo {
    CFArrayRef interfacesRef = CNCopySupportedInterfaces();
    NSArray* interfaces = CFBridgingRelease(interfacesRef);
    if (interfaces) {
        NSMutableArray<NetworkInfo*>* networkInfos = NSMutableArray.new;
        for (id interface in interfaces) {
            NSString* interfaceName = (NSString*)interface;
            NetworkInfo* networkInfo = [[NetworkInfo alloc]initWithInterface:interfaceName success:false ssid:@"" bssid:@""];
            
            CFDictionaryRef dicRef = CNCopyCurrentNetworkInfo((__bridge  CFStringRef)(NSString*)interfaceName);
            NSDictionary* dict = CFBridgingRelease(dicRef);
            
            if (dict) {
                networkInfo.success = true;
                networkInfo.ssid = (NSString*)[dict valueForKey:(NSString*)kCNNetworkInfoKeySSID];
                networkInfo.bssid = (NSString*)[dict valueForKey:(NSString*)kCNNetworkInfoKeyBSSID];
            }
            
            [networkInfos addObject:networkInfo];
        }
        return networkInfos;
    }
    return nil;
}

- (void)initUI {
    self.view.backgroundColor = UIColor.blackColor;
    self.title = @"SSID Tester";
    
    _updateBt = [UIButton buttonWithType:UIButtonTypeSystem];
    _updateBt.backgroundColor = UIColor.whiteColor;
    _updateBt.titleLabel.font = [UIFont systemFontOfSize:18];
    [_updateBt setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [_updateBt setTitle:@"获取" forState:UIControlStateNormal];
    _updateBt.layer.cornerRadius = 8;
    _updateBt.layer.masksToBounds = true;
    [_updateBt addTarget:self action:@selector(updateWifi) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_updateBt];
    [_updateBt makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(50);
        make.trailing.equalTo(self.view).offset(-50);
        make.bottom.equalTo(self.view.safeAreaLayoutGuideBottom).offset(-40);
        make.height.mas_equalTo(50);
    }];
    
    UIView* line1 = UIView.new;
    line1.backgroundColor = UIColor.lightGrayColor;
    [self.view addSubview:line1];
    [line1 makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.updateBt);
        make.trailing.equalTo(self.updateBt);
        make.top.equalTo(self.view.safeAreaLayoutGuideTop).offset(50);
        make.height.mas_equalTo(1);
    }];
   
    _floorLb = UILabel.new;
    _floorLb.textColor = UIColor.whiteColor;
    _floorLb.font = [UIFont systemFontOfSize:18];
    _floorLb.text = [NSString stringWithFormat:@"楼层 %d",_floorNum];
    [self.view addSubview:_floorLb];
    [_floorLb makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.updateBt).offset(20);
        make.top.equalTo(line1).offset(35);
    }];
    
    UIView* line2 = UIView.new;
    line2.backgroundColor = UIColor.lightGrayColor;
    [self.view addSubview:line2];
    [line2 makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.updateBt);
        make.trailing.equalTo(self.updateBt);
        make.top.equalTo(self.floorLb.bottom).offset(35);
        make.height.mas_equalTo(1);
    }];
    
    _stepper = UIStepper.new;
    _stepper.tintColor = UIColor.whiteColor;
    _stepper.minimumValue = -99;
    _stepper.maximumValue = 99;
    _stepper.stepValue = 1;
    _stepper.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    _stepper.value = _floorNum;
    [_stepper addTarget:self action:@selector(stepperValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_stepper];
    [_stepper makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.updateBt).offset(-20);
        make.centerY.equalTo(self.floorLb);
    }];
    
    _ssidLb = UILabel.new;
    _ssidLb.textColor = UIColor.whiteColor;
    _ssidLb.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_ssidLb];
    [_ssidLb makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-10);
    }];
    
    _bssidLb =  UILabel.new;
    _bssidLb.textColor = UIColor.whiteColor;
    _bssidLb.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_bssidLb];
    [_bssidLb makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.ssidLb).offset(25);
    }];
}

// MARK: - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self updateWifi];
    }
}


@end
