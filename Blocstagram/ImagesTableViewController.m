//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Tim on 2015-04-06.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "ImagesTableViewController.h"

@interface ImagesTableViewController ()

@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation ImagesTableViewController

-(instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.images = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i = 1; i <= 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [self.images addObject:image];
        }
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"imageCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.images.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // takes the identifier string and compares it with its roster of registered table view cells
    // Dequeue either returns a brand new cell of the type we registered
    //  or a used one no longer visible on the screen
    // Cells are recycled as they scroll off screen to preserve memory
    // since our current cell may be used, we have to make sure to update all its information
    // An index path (NSIndexPath) represents a series of indexes
    // For table views, an NSIndexPath has two properties you use when writing table-related code: section and row
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    
    
    // set to an arbitrary number: make sure it is consistent
    // a numerical tag can be attached to any UIView and used later to recover from its superview
    // by invoking viewWithTag:.
    static NSInteger imageViewTag = 1234;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
    
    
    // if we fail to recover a UIImageView
    // so this is a brand new cell
    if (!imageView) {
        // This is a new cell, it doesn't have an image view yet
        imageView = [[UIImageView alloc] init];
        // image will be stretched both horizontally and vertically to fill the bounds of
        // the UIImageView
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        // set its frame to be the same as teh UITableViewCell's contentView such that the image
        // consumes the entirety of the cell
        imageView.frame = cell.contentView.bounds;
        
        // autoresizingMask is associated with all UIView objets.
        // This property lets its superview know how to resize it when the superview's width or height changes.
        // These are called "bit-wise flags" and we set by OR-ing them together using |
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        imageView.tag = imageViewTag;
        [cell.contentView addSubview:imageView];
    }
    
    UIImage *image = self.images[indexPath.row];
    imageView.image = image;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // (widthOfTheScreen / widthOfThePicture) x heightOfThePicture = heightOfTheCell
    // for best performance, resize the image objects themselves to the exact size in which
    // they'll be displaed
    UIImage *image = self.images[indexPath.row];
    return (CGRectGetWidth(self.view.frame) / image.size.width) * image.size.height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
