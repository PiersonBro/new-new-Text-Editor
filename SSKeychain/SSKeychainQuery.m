//
//  SSKeychainQuery.m
//  SSKeychain
//
//  Created by Caleb Davenport on 3/19/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import "SSKeychainQuery.h"
#import "SSKeychain.h"

@implementation SSKeychainQuery

@synthesize account = _account;
@synthesize service = _service;
@synthesize label = _label;
@synthesize passwordData = _passwordData;

#if __IPHONE_3_0 && TARGET_OS_IPHONE
@synthesize accessGroup = _accessGroup;
#endif


#pragma mark - Public

- (BOOL)save:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    if (!self.service || !self.account || !self.passwordData) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
    
    [self delete:nil];
    
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecValueData] = self.passwordData;
    if (self.label) {
        query[(__bridge id)kSecAttrLabel] = self.label;
    }
#if __IPHONE_4_0 && TARGET_OS_IPHONE
	CFTypeRef accessibilityType = [SSKeychain accessibilityType];
    if (accessibilityType) {
        query[(__bridge id)kSecAttrAccessible] = (__bridge id)accessibilityType;
    }
#endif
    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
	}
    
	return (status == errSecSuccess);
}


- (BOOL)delete:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
    
    NSMutableDictionary *query = [self query];
#if TARGET_OS_IPHONE
    status = SecItemDelete((__bridge CFDictionaryRef)query);
#else
    CFTypeRef result = NULL;
    [query setObject:@YES forKey:(__bridge id)kSecReturnRef];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess) {
        status = SecKeychainItemDelete((SecKeychainItemRef)result);
        CFRelease(result);
    }
#endif
    
    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
    }
    
    return (status == errSecSuccess);
}


- (NSArray *)fetchAll:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
	
	CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return nil;
	}

    return (__bridge NSArray *)result;
}


- (BOOL)fetch:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
	if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}
	
	CFTypeRef result = NULL;
	NSMutableDictionary *query = [self query];
    query[(__bridge_transfer id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	
	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return NO;
	}
    
    self.passwordData = (__bridge_transfer NSData *)result;
    return YES;
}


#pragma mark - Accessors

- (void)setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)password {
    if (self.passwordData) {
        return [[NSString alloc] initWithData:self.passwordData encoding:NSUTF8StringEncoding];
    }
    return nil;
}


#pragma mark - Private

- (NSMutableDictionary *)query {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    dictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    
    if (self.service) {
        dictionary[(__bridge id)kSecAttrService] = self.service;
    }
    
    if (self.account) {
        dictionary[(__bridge id)kSecAttrAccount] = self.account;
    }
    
#if __IPHONE_3_0 && TARGET_OS_IPHONE
    if (self.accessGroup) {
        dictionary[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
#endif
    
    return dictionary;
}


+ (NSError *)errorWithCode:(OSStatus) code {
    NSString *message = nil;
    switch (code) {
        case errSecSuccess: return nil;
        case SSKeychainErrorBadArguments: message = @"Some of the arguments were invalid"; break;
            
#if TARGET_OS_IPHONE
        case errSecUnimplemented: {
			message = @"Function or operation not implemented";
			break;
		}
        case errSecParam: {
			message = @"One or more parameters passed to a function were not valid";
			break;
		}
        case errSecAllocate: {
			message = @"Failed to allocate memory";
			break;
		}
        case errSecNotAvailable: {
			message = @"No keychain is available. You may need to restart your computer";
			break;
		}
        case errSecDuplicateItem: {
			message = @"The specified item already exists in the keychain";
			break;
		}
        case errSecItemNotFound: {
			message = @"The specified item could not be found in the keychain";
			break;
		}
        case errSecInteractionNotAllowed: {
			message = @"User interaction is not allowed";
			break;
		}
        case errSecDecode: {
			message = @"Unable to decode the provided data";
			break;
		}
        case errSecAuthFailed: {
			message = @"The user name or passphrase you entered is not correct";
			break;
		}
        default: {
			message = @"Refer to SecBase.h for description";
		}
#else
        default:
            message = (__bridge_transfer NSString *)SecCopyErrorMessageString(code, NULL);
#endif
    }
    
    NSDictionary *userInfo = nil;
    if (message != nil) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    return [NSError errorWithDomain:kSSKeychainErrorDomain code:code userInfo:userInfo];
}

@end
