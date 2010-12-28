#import "EventType.h"

@implementation DatabaseSeeder

- (NSEntityDescription *)eventTypeEntityDescription {
	if (eventEntityDescription == nil) {
		eventEntityDescription = [NSEntityDescription entityForName:@"EventType" inManagedObjectContext:self.insertionContext];
	}
	return eventEntityDescription;
}

- (void)addEventTypeWithName:(NSString *)name tag:(NSString *)tag preferenceKey:(NSString *)prefKey {
	EventType *eventType = [[EventType alloc] initWithEntity:self.eventTypeEntityDescription insertIntoManagedObjectContext:managedObjectContext];
	eventType.name			= name;
	eventType.shortName = tag;
	eventType.prefKey		= prefKey;
	[eventType release];
}


- (void) seedDatabase:(NSManagedObjectContext *)managedObjectContext { 

	static NSString *const kActiveRegionName                 = @"Active Region";                   
	static NSString *const kActiveRegionTag                  = @"ar";                              
	static NSString *const kActiveRegionPreferenceKey        = @"show_active_region";
		
	static NSString *const kBrightPointName                  = @"Bright Point";                        
	static NSString *const kBrightPointTag                   = @"bp";                              
	static NSString *const kBrightPointPreferenceKey         = @"show_bright_point";                           

	static NSString *const kCoronalDimmingName               = @"Coronal Dimming";                 
	static NSString *const kCoronalDimmingTag                = @"cd";                          
	static NSString *const kCoronalDimmingPreferenceKey      = @"show_coronal_dimming";                    

	static NSString *const kCoronalMassEjectionName          = @"Coronal Mass Ejection";       
	static NSString *const kCoronalMassEjectionTag           = @"ce";                      
	static NSString *const kCoronalMassEjectionPreferenceKey = @"show_coronal_mass_ejection";          

	static NSString *const kCoronalWaveName                  = @"Coronal Wave";                        
	static NSString *const kCoronalWaveTag                   = @"cw";                              
	static NSString *const kCoronalWavePreferenceKey         = @"show_coronal_wave";                           

	static NSString *const kEmergingFluxName                 = @"Emerging Flux";                   
	static NSString *const kEmergingFluxTag                  = @"ef";                              
	static NSString *const kEmergingFluxPreferenceKey        = @"show_emerging_flux";                          

	static NSString *const kFilamentName                     = @"Filament";                            
	static NSString *const kFilamentTag                      = @"fi";                                  
	static NSString *const kFilamentPreferenceKey            = @"show_filament";                                   

	static NSString *const kFilamentEruptionName             = @"Filament Eruption";           
	static NSString *const kFilamentEruptionTag              = @"fe";                          
	static NSString *const kFilamentEruptionPreferenceKey    = @"show_filament_eruption";                  

	static NSString *const kFlareName                        = @"Flare";                                   
	static NSString *const kFlareTag                         = @"fl";                                  
	static NSString *const kFlarePreferenceKey               = @"show_flare";                                          

	static NSString *const kLoopName                         = @"Loop";                                    
	static NSString *const kLoopTag                          = @"lp";                                      
	static NSString *const kLoopPreferenceKey                = @"show_loop";                                           

	static NSString *const kOscillationName                  = @"Oscillation";                         
	static NSString *const kOscillationTag                   = @"os";                              
	static NSString *const kOscillationPreferenceKey         = @"show_oscillation";                            

	static NSString *const kSunspotName                      = @"Sunspot";                                 
	static NSString *const kSunspotTag                       = @"ss";                                  
	static NSString *const kSunspotPreferenceKey             = @"show_sunspot";                                    
	
	[self addEventTypeWithName:kActiveRegionName tag:kActiveRegionTag preferenceKey:kActiveRegionPreferenceKey];
	[self addEventTypeWithName:kBrightPointName tag:kBrightPointTag preferenceKey:kBrightPointPreferenceKey];
	[self addEventTypeWithName:kCoronalDimmingName tag:kCoronalDimmingTag preferenceKey:kCoronalDimmingPreferenceKey];
	[self addEventTypeWithName:kCoronalMassEjectionName tag:kCoronalMassEjectionTag preferenceKey:kCoronalMassEjectionPreferenceKey];
	[self addEventTypeWithName:kCoronalWaveName tag:kCoronalWaveTag preferenceKey:kCoronalWavePreferenceKey];
	[self addEventTypeWithName:kEmergingFluxName tag:kEmergingFluxTag preferenceKey:kEmergingFluxPreferenceKey];
	[self addEventTypeWithName:kFilamentName tag:kFilamentTag preferenceKey:kFilamentPreferenceKey];
	[self addEventTypeWithName:kFilamentEruptionName tag:kFilamentEruptionTag preferenceKey:kFilamentEruptionPreferenceKey];
	[self addEventTypeWithName:kFlareName tag:kFlareTag preferenceKey:kFlarePreferenceKey];
	[self addEventTypeWithName:kLoopName tag:kLoopTag preferenceKey:kLoopPreferenceKey];
	[self addEventTypeWithName:kOscillationName tag:kOscillationTag preferenceKey:kOscillationPreferenceKey];
	[self addEventTypeWithName:kSunspotName tag:kSunspotTag preferenceKey:kSunspotPreferenceKey];
	
}

@end