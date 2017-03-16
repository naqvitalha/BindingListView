#import "RCTBindingListView.h"
#import "RCTBindingCell.h"
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>


@interface RCTBindingListView()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@interface TableViewCell : UITableViewCell

@property (nonatomic, weak) UIView *cellView;

@end

@implementation TableViewCell

-(void)setCellView:(UIView *)cellView
{
  _cellView = cellView;
  [self.contentView addSubview:cellView];
}

-(void)setFrame:(CGRect)frame
{
  [super setFrame:frame];
  [_cellView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

@end

@implementation RCTBindingListView

  RCTBridge *_bridge;
  RCTUIManager *_uiManager;
  NSMutableArray *_unusedCells;

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
  RCTAssertParam(bridge);
  
  if ((self = [super initWithFrame:CGRectZero]))
  {
    _bridge = bridge;
    while ([_bridge respondsToSelector:NSSelectorFromString(@"parentBridge")]
           && [_bridge valueForKey:@"parentBridge"]) {
      _bridge = [_bridge valueForKey:@"parentBridge"];
    }
    _uiManager = _bridge.uiManager;
    _unusedCells = [NSMutableArray array];
    [self createTableView];
  }
  
  return self;
}

RCT_NOT_IMPLEMENTED(-initWithFrame:(CGRect)frame)
RCT_NOT_IMPLEMENTED(-initWithCoder:(NSCoder *)aDecoder)

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
  [_unusedCells addObject:subview];
}

- (void)layoutSubviews
{
  [self.tableView setFrame:self.frame];
}

- (void)createTableView
{
  _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  _tableView.dataSource = self;
  _tableView.delegate = self;
  _tableView.backgroundColor = [UIColor whiteColor];
  [self addSubview:_tableView];
}

- (void)setRowHeight:(float)rowHeight
{
  _tableView.estimatedRowHeight = rowHeight;
  _rowHeight = rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
  return self.numRows;
}

- (UIView*)getUnusedCellFromPool
{
  UIView* res = [_unusedCells lastObject];
  [_unusedCells removeLastObject];
  if (res != nil)
  {
    res.tag = [_unusedCells count];
  }
  if (res == nil)
  {
    NSLog(@"BindingListView Error: Not enough cells, increase poolSize");
  }
  return res;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return self.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"CustomCell";
  
  TableViewCell *cell = (TableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil)
  {
    //NSLog(@"Allocating childIndex %d for row %d", (int)cell.cellView.tag, (int)indexPath.row);
    cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.cellView = [self getUnusedCellFromPool];
    
  }
  else
  {
    //NSLog(@"Recycling childIndex %d for row %d", (int)cell.cellView.tag, (int)indexPath.row);
  }
  
  RCTBindingCell *bindingCell = (RCTBindingCell *)cell.cellView;
  NSDictionary *row = [self.rows objectAtIndex:indexPath.row];
    
  for (NSString *bindingId in self.binding)
  {
    NSString *rowKey = [self.binding objectForKey:bindingId];
    NSDictionary *binding = [bindingCell.bindings objectForKey:bindingId];
    NSNumber *reactTag = [binding objectForKey:@"tag"];
    NSString *viewName = [binding objectForKey:@"viewName"];
    NSString *prop = [binding objectForKey:@"prop"];
    NSString *rowValue = [row objectForKey:rowKey];
    if ([prop isEqualToString:@"children"])
    {
      dispatch_async(RCTGetUIManagerQueue(), ^{
        [_uiManager updateView:reactTag viewName:@"RCTRawText" props:@{@"text": rowValue}];
        [_uiManager batchDidComplete];
      });
    }
    else
    {
      [_uiManager synchronouslyUpdateViewOnUIThread:reactTag viewName:viewName props:@{prop: rowValue}];
    }
  }
  
  return cell;
}

@end