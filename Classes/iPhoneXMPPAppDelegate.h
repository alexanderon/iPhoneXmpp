#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"
#import "SettingsViewController.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPIncomingFileTransfer.h"
#import "XMPPRoomMemoryStorage.h"


@interface iPhoneXMPPAppDelegate : UIResponder <UIApplicationDelegate,XMPPIncomingFileTransferDelegate,TURNSocketDelegate>
{
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
    XMPPMessageArchiving *xmppMessageArchivingModule;
    XMPPIncomingFileTransfer *xmppIncomingFileTransfer;
    XMPPRoomCoreDataStorage *xmppRoomStorage;
    XMPPRoomMemoryStorage *roomMemory;
	NSString *password;
	
	BOOL customCertEvaluation;
	
	BOOL isXmppConnected;
	
   
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
@property (nonatomic, strong, readonly) XMPPMessageArchiving *xmppMessageArchivingModule;
@property (nonatomic, strong, readonly) XMPPIncomingFileTransfer *xmppIncomingFileTransfer;



@property (nonatomic, strong) SettingsViewController *settingsViewController;



- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
- (NSManagedObjectContext *)managedObjectContext_messageArchiving;
- (NSManagedObjectContext *)managedObjectContext_muc;

- (BOOL)connect;
- (void)disconnect;

@end
