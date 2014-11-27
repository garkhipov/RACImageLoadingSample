//
//  ViewController.m
//  RACImageLoadingSample
//
//  Created by Gleb Arkhipov on 26.11.14.
//  Copyright (c) 2014 Gleb Arkhipov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "ViewController.h"

@interface TableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *kittenImageView;
@end

@implementation TableViewCell
@end

@interface ViewController ()
@property (nonatomic, strong) NSArray *imageURLs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *mutableImageURLs = [NSMutableArray array];
    for (int i = 0; i < 20; ++i) {
        [mutableImageURLs addObject:@"http://lorempixel.com/80/80/cats"];
    }
    self.imageURLs = mutableImageURLs;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.imageURLs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellID"
                                                                           forIndexPath:indexPath];
    
    RAC(cell.kittenImageView, image) =
    [[[self signalForLoadingImage:self.imageURLs[indexPath.row]]
      takeUntil:cell.rac_prepareForReuseSignal]      // Crashes on multiple binding assertion!
     deliverOn:[RACScheduler mainThreadScheduler]];  // Swap these two lines to 'fix'
    
    return cell;
}

- (RACSignal *)signalForLoadingImage:(NSString *)imageURLString
{
    RACScheduler *scheduler = [RACScheduler
                               schedulerWithPriority:RACSchedulerPriorityBackground];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
