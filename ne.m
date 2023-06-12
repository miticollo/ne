#include <dispatch/dispatch.h>
#include <stdio.h>

/*
 * How to correctly include ObjC framework?
 *
 * See https://discord.com/channels/349243932447604736/688122301975363591/1052050898999853116
 */

#import <Foundation/Foundation.h>

@interface NEConfiguration : NSObject

@property(readonly) NSUUID* identifier;
@property(copy) NSString* name;

- (id)description;

@end

@interface NEConfigurationManager : NSObject

+ (id)sharedManager;
- (void)loadConfigurationsWithCompletionQueue:(dispatch_queue_t)completionQueue
                                      handler:
                                          (void (^)(NSArray<NEConfiguration*>* _Nullable configurations, NSError* _Nullable error))handler;
- (void)repopulateNetworkPrivacyConfigurationResetAll:(BOOL)arg1;
- (void)removeConfiguration:(id)configuration withCompletionQueue:(id)arg2 handler:(id)arg3;

@end

int main(void) {
    // Create the dispatch queue
    dispatch_queue_t _neServiceQueue = dispatch_queue_create("Network Extension service Queue", NULL);

    /*
     * Because handler: in [- loadConfigurationsWithCompletionQueue:hander:] is run async.
     *
     * See https://stackoverflow.com/a/21191050
     */
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    // Load the NEConfigurations
    NEConfigurationManager* manager = [NEConfigurationManager sharedManager];
    [manager repopulateNetworkPrivacyConfigurationResetAll:TRUE];
    [manager loadConfigurationsWithCompletionQueue:_neServiceQueue handler:^(NSArray<NEConfiguration*>* neConfigurations, NSError* error) {
        if (error != nil) {
            NSLog(@"ERROR loading configurations - %@", error);
            return;
        }
        unsigned int count = [neConfigurations count];
        for (unsigned int i = 0; i != count; i++) {
            [manager removeConfiguration:[neConfigurations objectAtIndex:i] withCompletionQueue:dispatch_get_main_queue() handler:^(void) {
                return;
            }];
        }
        dispatch_semaphore_signal(sem);
    }];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    [manager repopulateNetworkPrivacyConfigurationResetAll:TRUE];
    return 0;
}
