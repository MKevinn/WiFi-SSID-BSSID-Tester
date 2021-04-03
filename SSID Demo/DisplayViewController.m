//
//  DisplayViewController.m
//  SSID Demo
//
//  Created by Kevin Wang on 2021/4/2.
//

#import "DisplayViewController.h"

static NSString *const cellIdentifier = @"cellIdentifier";

@interface DisplayViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tb;

@end

@implementation DisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)dismissIt {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)presentActivityVC {
    NSMutableString* msg = NSMutableString.new;
    for (Data* floor in _allData) {
        for (SingleItem* item in floor.items) {
            [msg appendString: [NSString stringWithFormat:@"%@,%@,%@\n", floor.floorMsg,item.ssid,item.bssid]];
        }
    }
    UIActivityViewController* actVC = [[UIActivityViewController alloc] initWithActivityItems:@[msg] applicationActivities:nil];
    [self presentViewController:actVC animated:true completion:nil];
}

- (void)initUI {
    self.view.backgroundColor = UIColor.blackColor;
    self.title = @"Display WiFi Info";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"xmark"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissIt)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrowshape.turn.up.right"] style:UIBarButtonItemStyleDone target:self action:@selector(presentActivityVC)];
    
    _tb = UITableView.new;
    [_tb registerClass:UITableViewCell.class forCellReuseIdentifier:cellIdentifier];
    _tb.backgroundColor = UIColor.clearColor;
    _tb.delegate = self;
    _tb.dataSource = self;
    [self.view addSubview:_tb];
    [_tb makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _allData.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allData[section].items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [@"楼层 " stringByAppendingFormat:@"%@", _allData[section].floorMsg];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    cell.contentView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    cell.textLabel.text = _allData[indexPath.section].items[indexPath.row].bssid;
    cell.detailTextLabel.text = _allData[indexPath.section].items[indexPath.row].ssid;
    cell.detailTextLabel.textColor = UIColor.lightGrayColor;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_allData[indexPath.section].items removeObjectAtIndex:indexPath.row];
        if (_allData[indexPath.section].items.count == 0) {
            [_allData removeObjectAtIndex:indexPath.section];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [Data saveData:_allData];
    }
}



@end
