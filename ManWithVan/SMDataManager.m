//
//  SMDataManager.m
//  ManWithVan
//
//  Created by Syngmaster on 19/07/2017.
//  Copyright © 2017 Syngmaster. All rights reserved.
//

#import "SMDataManager.h"
#import "SMSetUpLocationData.h"
#import "SMQuoteData.h"

@interface SMDataManager ()


@end

@implementation SMDataManager

+ (SMDataManager *)sharedInstance {
    
    static SMDataManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SMDataManager alloc] init];
        sharedManager.baseColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:185.0/255.0 alpha:1.0];
        
        UIImage *placeHolder = [UIImage imageNamed:@"ImagePlaceholder.png"];
        sharedManager.placeHolder = placeHolder;
        
        UIImage *image1 = [UIImage imageNamed:@"SignInIcon.png"];
        UIImage *image2 = [UIImage imageNamed:@"about_us.png"];
        UIImage *image3 = [UIImage imageNamed:@"callback-icon.png"];
        UIImage *image4 = [UIImage imageNamed:@"reviews_icon.png"];
        UIImage *image5 = [UIImage imageNamed:@"gallery.png"];
        UIImage *image6 = [UIImage imageNamed:@"social_links.png"];
        UIImage *image7 = [UIImage imageNamed:@"home_icon.png"];

        
        sharedManager.iconArray = @[image7, image1, image2, image3, image4, image5, image6];
        
        UIImage *image11 = [UIImage imageNamed:@"SignInIcon_pressed.png"];
        UIImage *image21 = [UIImage imageNamed:@"about_us_pressed.png"];
        UIImage *image31 = [UIImage imageNamed:@"callback-icon_pressed.png"];
        UIImage *image41 = [UIImage imageNamed:@"reviews_icon_pressed.png"];
        UIImage *image51 = [UIImage imageNamed:@"gallery_pressed.png"];
        UIImage *image61 = [UIImage imageNamed:@"social_links_pressed.png"];
        UIImage *image71 = [UIImage imageNamed:@"home_icon_pressed.png"];

        sharedManager.pressedIconArray = @[image71, image11, image21, image31, image41, image51, image61];
        sharedManager.iconNameArray = @[@"Home",@"Sign in", @"About us", @"Callback", @"Reviews", @"Gallery", @"Social links"];
        
        sharedManager.centerDublinLocation = [[CLLocation alloc] initWithLatitude:53.338082 longitude:-6.259117];
        sharedManager.officeDublinLocation = [[CLLocation alloc] initWithLatitude:53.349325 longitude:-6.290251];
        
    });
    
    return sharedManager;
    
}

- (void)getAddressFromCoordinates:(CLLocationCoordinate2D) coordinates onComplete:(void(^)(CLPlacemark *placemark, NSString *error)) completionHandler {
    
    CLLocationCoordinate2D coordinate = coordinates;
    
    self.geoCoder = [[CLGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        NSString *message = nil;
        
        if (error) {
            
            message = [error description];
            completionHandler(nil, message);
            
        } else {
            
            if ([placemarks count] > 0) {
                
                CLPlacemark *placeMark = [placemarks firstObject];
                completionHandler(placeMark, nil);
                
            } else {
                
                message = @"No placemarks found";
                completionHandler(nil, message);
                
            }
        }
    }];
}

- (void)getCoordinatesFromAddress:(SMSetUpLocationData *) address onComplete:(void(^)(CLLocationCoordinate2D coordinates, NSError *error)) completionHandler {
    
    if (![address isEqual:nil]) {
        
        self.geoCoder = [[CLGeocoder alloc] init];
        
        if ([self.geoCoder isGeocoding]) {
            [self.geoCoder cancelGeocode];
        }
        
        NSString *locationAddress = [NSString stringWithFormat:@"%@ %@ %@ %@", address.houseApartmentNumber, address.streetName, address.cityName, address.countyName];
        
        [self.geoCoder geocodeAddressString:locationAddress completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if (placemarks) {
                
                CLPlacemark* placemark = [placemarks firstObject];
                CLLocationCoordinate2D coordinates;
                coordinates.latitude = placemark.location.coordinate.latitude;
                coordinates.longitude = placemark.location.coordinate.longitude;
                
                NSLog(@"Country : %@", placemark.country);
                completionHandler(coordinates, nil);
                
            } else {
                
                CLLocationCoordinate2D coordinates = kCLLocationCoordinate2DInvalid;
                completionHandler(coordinates, error);
                
            }
            
            
        }];
 
    } else {
        
        NSError *error;
        CLLocationCoordinate2D coordinates = kCLLocationCoordinate2DInvalid;
        completionHandler(coordinates, error);
        
    }
    
    
    
}

- (void)calculationOfQuote:(SMQuoteData *) quote onComplete:(void(^)(NSInteger price, NSError *error)) completionHandler {
    
    __block NSInteger price = 0;
    
    if (quote.isSmallMoving) {
        
        if ([quote.startLocation.buildingType isEqualToString:@"House"] && [quote.endLocation.buildingType isEqualToString:@"House"]) {
            
            price = 40;
            
        } else if ([quote.startLocation.buildingType isEqualToString:@"Apartment"] && [quote.endLocation.buildingType isEqualToString:@"Apartment"]) {
            
            if (quote.startLocation.liftAvailable && quote.endLocation.liftAvailable) {
                
                price = 50;

            } else {
                
                price = 40;
                
                if (!quote.startLocation.liftAvailable) {
                    price = [self updatePrice:price ofQuote:quote withPickUpFloor:quote.startLocation];
                }
                
                if (!quote.endLocation.liftAvailable) {
                    price = [self updatePrice:price ofQuote:quote withPickUpFloor:quote.endLocation];
                }
                
            }
            
        } else {
            price = 40;
            
            if ([quote.startLocation.buildingType isEqualToString:@"Apartment"] || [quote.startLocation.buildingType isEqualToString:@"Other"]) {
                
                if (quote.startLocation.liftAvailable) {
                    price = 50;
                } else {
                    price = [self updatePrice:price ofQuote:quote withPickUpFloor:quote.startLocation];
                }
                
            }
            
            if ([quote.endLocation.buildingType isEqualToString:@"Apartment"] || [quote.endLocation.buildingType isEqualToString:@"Other"]) {
                
                if (quote.endLocation.liftAvailable) {
                    price = 50;
                } else {
                    price = [self updatePrice:price ofQuote:quote withPickUpFloor:quote.endLocation];
                }
            }
        }
        
    } else {
        
        quote.startLocation.loadingTime = quote.endLocation.loadingTime = 0.5;

        if ([quote.startLocation.buildingType isEqualToString:@"Apartment"] && [quote.endLocation.buildingType isEqualToString:@"Apartment"]) {
            
            if (!quote.startLocation.liftAvailable) {
                price = [self updatePrice:price ofQuote:quote withPickUpFloor:quote.startLocation];
            } else {
                quote.startLocation.loadingTime = 1.0;
            }
            
            if (!quote.endLocation.liftAvailable) {
                price = [self updatePrice:price ofQuote:quote withPickUpFloor:quote.endLocation];
            } else {
                quote.endLocation.loadingTime = 1.0;
            }
            
        } else {
            
            if ([quote.startLocation.buildingType isEqualToString:@"Apartment"] || [quote.startLocation.buildingType isEqualToString:@"Other"]) {
                
                if (!quote.startLocation.liftAvailable) {
                    price = [self updatePrice:price ofQuote:quote withPickUpFloor:quote.startLocation];
                } else {
                    quote.startLocation.loadingTime = 1.0;
                }
                
            }
            
            if ([quote.endLocation.buildingType isEqualToString:@"Apartment"] || [quote.endLocation.buildingType isEqualToString:@"Other"]) {
                
                if (!quote.endLocation.liftAvailable) {
                    price = [self updatePrice:price ofQuote:quote withPickUpFloor:quote.endLocation];
                } else {
                    quote.endLocation.loadingTime = 1.0;

                }


            }
        }
        
    }
    
    NSLog(@"Price is %i", (int)price);
    
    [self getCoordinatesFromAddress:quote.startLocation onComplete:^(CLLocationCoordinate2D coordinates, NSError *error) {
        
        if (!error) {
            
            CLLocationCoordinate2D startPoint = coordinates;
            
            [self getCoordinatesFromAddress:quote.endLocation onComplete:^(CLLocationCoordinate2D coordinates, NSError *error) {
                
                if (!error) {
                    
                    CLLocationCoordinate2D endPoint = coordinates;
                    
                    if (quote.isSmallMoving) {
                        
                        if (quote.startLocation && quote.endLocation) {
                            
                            price = [self updatePrice:price ofQuote:quote basedOnStartCoordinates:startPoint andEndCoordinates:endPoint];
                            
                            completionHandler(price, nil);
                            
                        } else {
                            
                            completionHandler(0, nil);
                            
                        }
                        
                    } else {
                        
                        [self getDistanceBetweenStartPoint:startPoint andEndPoint:endPoint onComplete:^(MKRoute *resultRoute, NSError *error) {
                            
                            if (resultRoute) {
                                
                                NSInteger finalPrice = [self totalPriceOfQuote:quote basedOn:resultRoute.expectedTravelTime];
                                finalPrice = finalPrice + price;
                                
                                completionHandler(finalPrice, nil);
                                
                            } else {
                                
                                completionHandler(0, error);
                                
                            }
                            
                        }];
                    }
                    
                } else {
                    
                    completionHandler(0, error);

                }
                
            }];

        } else {
            
            completionHandler(0, error);

        }
        
    }];

}

- (NSInteger)updatePrice:(NSInteger) price ofQuote:(SMQuoteData *) quote basedOnStartCoordinates:(CLLocationCoordinate2D) startPoint andEndCoordinates:(CLLocationCoordinate2D) endPoint {
    
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:startPoint.latitude longitude:startPoint.longitude];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:endPoint.latitude longitude:endPoint.longitude];
    
    CLLocationDistance distance1 = [[SMDataManager sharedInstance].centerDublinLocation distanceFromLocation:startLocation];
    CLLocationDistance distance2 = [[SMDataManager sharedInstance].centerDublinLocation distanceFromLocation:endLocation];
    CLLocationDistance distanceFromOfficeToStartPoint = [[SMDataManager sharedInstance].officeDublinLocation distanceFromLocation:startLocation];
    CLLocationDistance workingDistance = [startLocation distanceFromLocation:endLocation];
    
    float estHoursOfWork = 0.0;
    estHoursOfWork = estHoursOfWork + workingDistance/(60000);
    
    NSLog(@"Working distance hours : %f", workingDistance/(60.0*1000));
    
    if (distanceFromOfficeToStartPoint > 9000) {
        
        NSInteger result;
        result = distanceFromOfficeToStartPoint/1000;
        price = price + result;
        estHoursOfWork = estHoursOfWork + result/60.0;
    }
    
    NSLog(@"Hours :  %f", estHoursOfWork);

    
    if (quote.twoPeople) {
        
        if (estHoursOfWork > 1) {
            float roundedResult = ceil(estHoursOfWork / 0.5) * 0.5;
            price = price + roundedResult * 20;
        } else {
            price = price + 20;
        }
        
    }
    
    double biggerDistance = MAX(distance1, distance2);
    
    if (biggerDistance > 9000) {
        
        NSInteger result;
        result = biggerDistance/1000;
        result = result - 9;
        price = price + result;
        NSLog(@"Price is %i", (int)price);
    }
    
    NSInteger roundedResult = ceil((float)price / 5) * 5;
    
    return roundedResult;
}

- (void)getDistanceBetweenStartPoint:(CLLocationCoordinate2D) startPoint andEndPoint:(CLLocationCoordinate2D) endPoint onComplete:(void(^)(MKRoute *resultRoute, NSError *error)) completionHandler {
    
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:startPoint];
    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:endPoint];
    
    MKMapItem *startItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = startItem;
    request.destination = endItem;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *direction = [[MKDirections alloc] initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        
        if (response) {
            
            MKRoute *shortestRoute = response.routes[0];
            NSLog(@"Number of routes: %li", [response.routes count]);
            
            for (MKRoute *route in response.routes) {
                NSLog(@"Driving distance : %f", route.distance);
                NSLog(@"Travel time : %f", route.expectedTravelTime);
                
                if (shortestRoute.expectedTravelTime > route.expectedTravelTime) {
                    shortestRoute = route;
                }
            }
            
            completionHandler(shortestRoute, nil);
            
        } else {
            
            completionHandler(nil, error);
        }
        
    }];
    
}

- (NSInteger)updatePrice:(NSInteger) price ofQuote:(SMQuoteData *) quote withPickUpFloor:(SMSetUpLocationData *)loadingPoint {
    
    if ([quote.startLocation isEqual:loadingPoint]) {
        
        if ([loadingPoint.pickUpFloor isEqualToString:@"First"]) {
            loadingPoint.loadingTime = loadingPoint.loadingTime + 0.5;
        } else if ([loadingPoint.pickUpFloor isEqualToString:@"Second"]) {
            loadingPoint.loadingTime = loadingPoint.loadingTime + 1.0;
        } else if ([loadingPoint.pickUpFloor isEqualToString:@"Third"]) {
            loadingPoint.loadingTime = loadingPoint.loadingTime + 1.5;
        } else if ([loadingPoint.pickUpFloor isEqualToString:@"Over third"]) {
            loadingPoint.loadingTime = loadingPoint.loadingTime + 2.5;
        }
        
    }
    
    if ([loadingPoint.pickUpFloor isEqualToString:@"First"]) {
        price = price + 5;
    } else if ([loadingPoint.pickUpFloor isEqualToString:@"Second"]) {
        price = price + 10;
    } else if ([loadingPoint.pickUpFloor isEqualToString:@"Third"]) {
        price = price + 15;
    } else if ([loadingPoint.pickUpFloor isEqualToString:@"Over third"]) {
        price = price + 25;
    }
    return price;
}

- (NSInteger)totalPriceOfQuote:(SMQuoteData *) quote basedOn:(float) expectedTravelTime {
    
    NSInteger roundedResult = ceil(expectedTravelTime / 20) * 20;
    float travelTime = roundedResult/3600.0;
    float totalTime = travelTime * 2 + (quote.startLocation.loadingTime + quote.endLocation.loadingTime);
    NSInteger price = 0;
    
    if (quote.twoPeople) {
        
        price = (totalTime - 1) * 70 + 100;
        price = ceil((float)price / 10) * 10;
        
    } else {
        
        price = (totalTime - 1) * 40 + 70;
        price = ceil((float)price / 10) * 10;
        
    }

    return price;
}



@end
