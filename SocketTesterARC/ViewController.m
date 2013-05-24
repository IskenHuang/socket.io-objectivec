//
//  ViewController.m
//  SocketTesterARC
//
//  Created by Kyeck Philipp on 01.06.12.
//  Copyright (c) 2012 beta_interactive. All rights reserved.
//

#import "ViewController.h"
#import "UserObject.h"
#import "SBJson.h"
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) IBOutlet UITextField *myTextField;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    //socketIO.useSecure = YES;
    [socketIO connectToHost:@"localhost" onPort:3000];
    
    self.dataArray = [NSMutableArray new];
    [self.myTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark - textfield
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self sendMessage:textField.text];
    [textField setText:@""];
    [textField becomeFirstResponder];
    return YES;
}

-(void) sendMessage:(NSString *)message{
//    NSDictionary * chat = [NSDictionary dictionaryWithObjectsAndKeys:message,@"msg", nil];
    [socketIO sendEvent:@"user message" withData:message];
    [self.dataArray addObject:message];
    [self.myTableView beginUpdates];
    [self.myTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
    [self.myTableView endUpdates];
    [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark -
#pragma mark - tableView
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(float) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *message = [self.dataArray objectAtIndex:indexPath.row];
    int row = abs(message.length / 20);
    if (row < 1) {
        row = 1;
    }
    return row*40;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

    [cell.textLabel setText:[self.dataArray objectAtIndex:indexPath.row]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}


#pragma mark -
#pragma mark - socket.io
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent()");
//    type, pId, name, ack, data, args, endpoint
//    DLogv(packet.type);
//    DLogv(packet.pId);
//    DLogv(packet.name);
//    DLogv(packet.ack);
//    DLogv(packet.args);
//    DLogv(packet.endpoint);
    DLogv(packet.data);
    
    if ([packet.name isEqualToString:@"announcement"]){
        //in or out
        [self.dataArray addObject:[NSString stringWithFormat:@"%@", [packet.args objectAtIndex:0]]];
//        [self.myTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
    }else if ([packet.name isEqualToString:@"nicknames"]){
        //who in here
    }else{
//        user message
        for (int i = 0; i < packet.args.count; i +=2 ) {
            NSString *message = [NSString stringWithFormat:@"%@:%@", [packet.args objectAtIndex:i], [packet.args objectAtIndex:i+1]];
            [self.dataArray addObject:message];
            [self.myTableView beginUpdates];
            [self.myTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
            [self.myTableView endUpdates];
            [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }    
}

-(void) socketIODidConnect:(SocketIO *)socket{
//    [socketIO sendEvent:@"user message" withData:message];
//    NSDictionary * chat = [NSDictionary dictionaryWithObjectsAndKeys:@"ios",@"ios", nil];
    [socket sendEvent:@"nickname" withData:@"ios"];
}

-(void) socketIODidDisconnect:(SocketIO *)socket{
//    NSDictionary * chat = [NSDictionary dictionaryWithObjectsAndKeys:@"goooooood bye~~",@"msg", nil];
//    [socket sendEvent:@"disconnect" withData:chat];
}

@end
