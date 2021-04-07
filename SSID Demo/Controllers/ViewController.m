//
//  ViewController.m
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/1.
//

#import "ViewController.h"

@interface ViewController () <CLLocationManagerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) CLLocationManager* locManager;
@property (strong, nonatomic) UILabel* ssidLb;
@property (strong, nonatomic) UILabel* bssidLb;
@property (strong, nonatomic) UIButton* updateBt;
@property (strong, nonatomic) UILabel* floorLb;
@property (strong, nonatomic) UITextField* floorTF;
@property (strong, nonatomic) NSArray<NetworkInfo*>* currentNetworkInfos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self readDataFromLocal];
    [self initUI];
    [self requestLocation];
}

- (void)readDataFromLocal {
    _allData = [NSMutableArray arrayWithArray:[Data loadData]];
    if (!_allData) {
        _allData = [[NSMutableArray<Data*> alloc] init];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    if (touch.phase == UITouchPhaseBegan) {
        [_floorTF resignFirstResponder];
    }
}

- (void)presentDisplayVC {
    DisplayViewController* vc = DisplayViewController.new;
    vc.allData = _allData;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:true completion:nil];
}

- (void)updateWifi {
    _currentNetworkInfos = [NSArray arrayWithArray:[self fetchNetworkInfo]];
    _ssidLb.text = [@"SSID: " stringByAppendingString:_currentNetworkInfos.firstObject.success ? _currentNetworkInfos.firstObject.ssid:@"N/A"];
    _bssidLb.text = [@"BSSID: " stringByAppendingString:_currentNetworkInfos.firstObject.success ? _currentNetworkInfos.firstObject.bssid:@"N/A"];
    if (_currentNetworkInfos.firstObject.success) {
        _ssidLb.text = [@"SSID: " stringByAppendingString:_currentNetworkInfos.firstObject.ssid];
        _bssidLb.text = [@"BSSID: " stringByAppendingString:_currentNetworkInfos.firstObject.bssid];
        if (!_floorTF.text || [_floorTF.text isEqualToString:@""]) return;
        BOOL exists = false;
        Data* floorDataToRemove;
        for (Data* floorData in _allData) {
            if ([floorData.floorMsg isEqualToString:_floorTF.text]) {
                SingleItem* newItem = [[SingleItem alloc] initWithSsid:_currentNetworkInfos.firstObject.ssid bssid:_currentNetworkInfos.firstObject.bssid];
                for (SingleItem* item in floorData.items) {
                    if ([item.bssid isEqualToString:newItem.bssid] && [item.ssid isEqualToString:newItem.ssid]) {
                        [self.view makeToast:[NSString stringWithFormat:@"楼层 %@ 中已存在该BSSID，已去重",floorData.floorMsg]
                         duration:2 position:CSToastPositionBottom];
                        return;
                    }
                }
                
                [self.view makeToast:[NSString stringWithFormat:@"楼层 %@ 已存在，已使用最新数据覆盖",floorData.floorMsg]
                 duration:2 position:CSToastPositionBottom];
                floorDataToRemove = floorData;
                Data* newFloorData = [[Data alloc] initWithFloor:_floorTF.text items: [[NSMutableArray<SingleItem*> alloc] init]];
                [newFloorData.items addObject:newItem];
                [_allData addObject:newFloorData];
                exists = true;
                break;
            }
        }
        
        if (floorDataToRemove) {
            [_allData removeObject:floorDataToRemove];
        } else if (!exists) {
            Data* floorData = [[Data alloc] initWithFloor:_floorTF.text items: [[NSMutableArray<SingleItem*> alloc] init]];
            [floorData.items addObject:[[SingleItem alloc] initWithSsid:_currentNetworkInfos.firstObject.ssid bssid:_currentNetworkInfos.firstObject.bssid]];
            [_allData addObject:floorData];
        }
        [Data saveData:_allData];
        
    } else {
        _ssidLb.text = @"SSID: N/A";
        _bssidLb.text = @"BSSID: N/A";
    }
}

- (void)textFieldEdited {
    [self enableUpdateBt:_floorTF.text && ![_floorTF.text isEqualToString:@""]];
}

- (void)enableUpdateBt:(BOOL)enable {
    [_updateBt setUserInteractionEnabled:enable];
    [_updateBt setAlpha:enable ? 1:0.6];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage systemImageNamed:@"tablecells"] style:UIBarButtonItemStylePlain target:self action:@selector(presentDisplayVC)];
    
    _updateBt = [UIButton buttonWithType:UIButtonTypeSystem];
    _updateBt.backgroundColor = UIColor.whiteColor;
    [self enableUpdateBt:false];
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
    _floorLb.text = @"楼层";
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
    
    _floorTF = UITextField.new;
    _floorTF.delegate = self;
    _floorTF.borderStyle = UITextBorderStyleRoundedRect;
    _floorTF.tintColor = UIColor.whiteColor;
    _floorTF.placeholder = @"i.e. C3-15F";
    _floorTF.textAlignment = NSTextAlignmentRight;
    _floorTF.textColor = UIColor.whiteColor;
    [_floorTF addTarget:self action:@selector(textFieldEdited) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_floorTF];
    [_floorTF makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.updateBt).offset(-20);
        make.centerY.equalTo(self.floorLb);
        make.leading.greaterThanOrEqualTo(self.floorLb.trailing).offset(20);
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

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self updateWifi];
    }
}

// MARK: - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}


@end
