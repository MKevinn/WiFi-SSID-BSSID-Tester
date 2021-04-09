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
        [msg appendString: [NSString stringWithFormat:@"%@,%@,%@\n", floor.floorMsg,floor.item.ssid,floor.item.bssid]];
    }
    UIActivityViewController* actVC = [[UIActivityViewController alloc] initWithActivityItems:@[msg] applicationActivities:nil];
    [self presentViewController:actVC animated:true completion:nil];
}

- (void)setShare {
    [self.navigationItem.rightBarButtonItem setEnabled:_allData && _allData.count>0];
}

- (void)initUI {
    self.navigationController.navigationBar.prefersLargeTitles = true;
    self.view.backgroundColor = UIColor.blackColor;
    self.title = @"Display WiFi Info";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"xmark"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissIt)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrowshape.turn.up.right"] style:UIBarButtonItemStyleDone target:self action:@selector(presentActivityVC)];
    [self setShare];
    
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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [@"楼层 " stringByAppendingFormat:@"%@", _allData[section].floorMsg];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* v = UIView.new;
    v.backgroundColor = UIColor.clearColor;
    return v;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    cell.contentView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    cell.textLabel.text = _allData[indexPath.section].item.bssid;
    cell.detailTextLabel.text = _allData[indexPath.section].item.ssid;
    cell.detailTextLabel.textColor = UIColor.lightGrayColor;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_allData removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [Data saveData:_allData];
        [self setShare];
    }
}



@end
