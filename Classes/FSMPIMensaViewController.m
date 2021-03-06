#import "FSMPIMensaViewController.h"

const CGFloat kMenuCellHeight = 81;
const CGFloat kDateCellHeight = 44;
const NSTimeInterval kLoadingOverlayFadeOutDuration = 1;

@implementation FSMPIMensaViewController

@synthesize tableView, currentCell, loadingOverlayView, menus;

#pragma mark View Lifecycle

- (id)initWithMensaID:(NSString*)mensaIDString {
    self = [super init];
    if (self) {
        mensaID = mensaIDString;
    }
    return self;
}

- (void)viewDidLoad
{
    dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[dateFormatter setDateFormat:@"EEEE"];
    localizedDateFormatter = [[NSDateFormatter alloc] init];
    [localizedDateFormatter setLocale:[NSLocale currentLocale]];
   	[localizedDateFormatter setDateStyle:NSDateFormatterShortStyle];
	currentlyLoading = NO;
	didShowErrorAlertView = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	if(currentlyLoading) return;
	if([menus count] == 0) [self refreshAllMenus];
}

- (void)viewWillDisappear:(BOOL)animated
{
	didShowErrorAlertView = NO;
}

#pragma mark -
#pragma mark Functionality

- (void)refreshAllMenus
{
	currentlyLoading = YES;
	self.loadingOverlayView.hidden = NO;

	parser = [[FSMPIMensaParser alloc] init];
	[parser setDelegate:self];
	[parser parseMenuForMensaID:mensaID];
}

#pragma mark -
#pragma mark Mensa Parser Delegate

-  (void)mensaParser:(FSMPIMensaParser*)parser
didFinishParsingMenu:(NSArray*)parsedMenu
		  forMensaID:(NSString*)mensaId
{
	currentlyLoading = NO;
	self.loadingOverlayView.hidden = YES;
    self.menus = parsedMenu;
	[tableView reloadData];
}

- (void)mensaParser:(FSMPIMensaParser*)parser 
   didFailWithError:(NSError*)error
		 forMensaID:(NSString*)mensaId
{
	currentlyLoading = NO;
	self.loadingOverlayView.hidden = YES;
	[tableView reloadData];
	if(!didShowErrorAlertView){
		didShowErrorAlertView = YES;
    
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error alert view title")
                                                                            message:[error localizedDescription]
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Dismiss", @"Error alert dismiss button label")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [errorAlert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [errorAlert addAction:cancel];
        [self presentViewController:errorAlert animated:YES completion:nil];
	}
}

#pragma mark -
#pragma mark UITableView Data Source

- (UITableViewCell*)tableView:(UITableView *)aTableView 
  	    cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuseIdentifier = @"menuCell";
	
	// Reuse cells
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FSMPIMensaCell" owner:self options:nil];
		cell = self.currentCell;
    }
	
	// Configure cells
    UILabel *mealLabel = (UILabel*)[cell viewWithTag:1];		// Label with the meal name
    UILabel *descriptionLabel = (UILabel*)[cell viewWithTag:2];	// Label with meal description		
    UIImageView *vegetarianIcon = (UIImageView*)[cell viewWithTag:3];   // Vegetarian meal icon
    UIImageView *porkIcon = (UIImageView*)[cell viewWithTag:4];         // Pork meal icon
    UIImageView *beefIcon = (UIImageView*)[cell viewWithTag:5];         // Beef meal icon
    NSDictionary *dateContainer = [menus objectAtIndex:indexPath.section];
    NSDictionary *dish = [(NSArray*)[dateContainer objectForKey:@"dishes"] objectAtIndex:indexPath.row];
    [mealLabel setText:[dish objectForKey:@"meal"]];
    [descriptionLabel setText:[dish objectForKey:@"description"]];
    
    [vegetarianIcon setHidden:![(NSNumber*)[dish objectForKey:@"isVegetarian"] boolValue]];
    [porkIcon setHidden:![(NSNumber*)[dish objectForKey:@"containsPork"] boolValue]];
    [beefIcon setHidden:![(NSNumber*)[dish objectForKey:@"containsBeef"] boolValue]];
    
    if(![beefIcon isHidden] && ![porkIcon isHidden]){
        CGRect rect = [beefIcon frame];
        rect.origin.x -= 27;
        [beefIcon setFrame:rect];
    }

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [menus count];
}

- (NSInteger)tableView:(UITableView *)table 
 numberOfRowsInSection:(NSInteger)section;
{
    NSDictionary *menu = [menus objectAtIndex:section];
	if(menu){
		return [(NSArray*)[menu objectForKey:@"dishes"] count];
	} 
	return 0;
}

-   (NSString*)tableView:(UITableView *)tableView
 titleForHeaderInSection:(NSInteger)section
{
    NSString *titleString;
    NSDate *date = (NSDate*)[[menus objectAtIndex:section] objectForKey:@"date"];
    NSUInteger daysSinceToday = floor([date timeIntervalSinceDate:[NSDate date]] / 60 / 60 / 24) + 1;
    if(daysSinceToday == 0) titleString = NSLocalizedString(@"Today", @"Today text label");
    if(daysSinceToday == 1) titleString = NSLocalizedString(@"Tomorrow", @"Tomorrow text label");
    if(daysSinceToday > 1 && daysSinceToday <= 7) titleString = [dateFormatter stringFromDate:date];
    if(daysSinceToday > 7) titleString = [localizedDateFormatter stringFromDate:date];
    
	return titleString;
}

- (CGFloat)tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMenuCellHeight;
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
}


@end
