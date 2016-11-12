//
//  MHGatewayBindSceneManager.m
//  MiHome
//
//  Created by Lynn on 1/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayBindSceneManager.h"
#import "MHGatewaySceneListRequest.h"
#import "MHGatewaySceneListResponse.h"
#import "MHGatewaySceneManager.h"
#import "MHDataScene.h"
#import "MHIFTTTManager.h"

#define kCURRENTMODEL @"CURRENTMODEL"

@interface MHGatewayBindSceneManager ()

@property (nonatomic, copy) void(^deleteBindBlock)(void);

@end

@implementation MHGatewayBindSceneManager

static NSArray *bindSceneName = nil;

static NSArray *bindRealSceneName = nil;

static NSArray *bindMethodEvent = nil;

static NSDictionary *ACPartnerBindLaunchDictionary = nil;

static NSDictionary *BindLaunchDictionary = nil;


static NSArray *BindActionArray = nil;

static NSArray *ACPartnerBindActionArray = nil;


static NSDictionary *cameraBindLaunchDictionary;
static NSArray *cameraBindActionArray;



+ (id)sharedInstance {
    bindSceneName = @[ @"lm_scene_1_1" , @"lm_scene_1_2" , @"lm_scene_1_3" , @"lm_scene_1_4" ,
                       @"lm_scene_2_1" ,
                       @"lm_scene_3_1" , @"lm_scene_3_2" , @"lm_scene_3_3" ,
                       @"lm_scene_4_1" , @"lm_scene_4_2" , @"lm_scene_4_3"
                       ];
    bindRealSceneName = @[ NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_1_1", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_1_2", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_1_3", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_1_4", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_2_1", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_3_1", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_3_2", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_3_3", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_4_1", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_4_2", @"plugin_gateway", "") ,
                           NSLocalizedStringFromTable(@"mydevice.gateway.scene.sysscene.name.lm_scene_4_3", @"plugin_gateway", "") ,
                           ];
    bindMethodEvent = @[
                        @[Method_Alarm , Gateway_Event_Motion_Motion],
                        @[Method_Alarm , Gateway_Event_Magnet_Open],
                        @[Method_Alarm , Gateway_Event_Switch_Click],
                        @[Method_Alarm , Gateway_Event_Cube_alert],
                        @[Method_OpenNightLight , Gateway_Event_Motion_Motion],
                        @[Method_Door_Bell , Gateway_Event_Switch_Click],
                        @[Method_Door_Bell , Gateway_Event_Magnet_Open],
                        @[Method_Door_Bell , Gateway_Event_Motion_Motion],
                        @[Method_StopClockMusic , Gateway_Event_Motion_Motion],
                        @[Method_StopClockMusic , Gateway_Event_Magnet_Open],
                        @[Method_StopClockMusic , Gateway_Event_Switch_Click],
                        ];
    
    //空调伴侣
    ACPartnerBindLaunchDictionary = @{
                                      @"0" : @[
                                              @{
                                                  @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                                  @"value" : @"" ,
                                                  @"key"   : @"event.lumi.sensor_motion.v2.motion"
                                                  } ,
                                              @{
                                                  @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                                  @"value" : @"on" ,
                                                  @"key"   : @"prop.lumi.acpartner.v1.arming"
                                                  }
                                              ] ,
                                      
                                      @"1" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_magnet.v2.open",
                                                  },
                                              @{
                                                  @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                                  @"value" : @"on",
                                                  @"key" : @"prop.lumi.acpartner.v1.arming",
                                                  }
                                              ],
                                      
                                      @"2" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_switch.v2.click",
                                                  },
                                              @{
                                                  @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                                  @"value" : @"on",
                                                  @"key" : @"prop.lumi.acpartner.v1.arming",
                                                  }
                                              ],
                                      @"3" : @[
                                              @{
                                                  @"extra" : @"[1,18,2,85,[0,2],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_cube.v1.alert",
                                                  },
                                              @{
                                                  @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                                  @"value" : @"on",
                                                  @"key" : @"prop.lumi.acpartner.v1.arming",
                                                  }
                                              ],
                                      @"4" : @[
                                              @{
                                                  @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_motion.v2.motion",
                                                  }
                                              ],
                                      @"5" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_switch.v2.click",
                                                  }
                                              ],
                                      @"6" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_magnet.v2.open",
                                                  }
                                              ],
                                      @"7" : @[
                                              @{
                                                  @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_motion.v2.motion",
                                                  }
                                              ],
                                      @"8" : @[
                                              @{
                                                  @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_motion.v2.motion",
                                                  }
                                              ],
                                      @"9" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_magnet.v2.open",
                                                  }
                                              ],
                                      @"10" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_switch.v2.click",
                                                  }
                                              ]
                                      };
    BindLaunchDictionary = @{
                             @"0" : @[
                                     @{
                                         @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                         @"value" : @"" ,
                                         @"key"   : @"event.lumi.sensor_motion.v2.motion"
                                         } ,
                                     @{
                                         @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                         @"value" : @"on" ,
                                         @"key"   : @"prop.lumi.gateway.v3.arming"
                                         }
                                     ] ,
                             
                             @"1" : @[
                                     @{
                                         @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_magnet.v2.open",
                                         },
                                     @{
                                         @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                         @"value" : @"on",
                                         @"key" : @"prop.lumi.gateway.v3.arming",
                                         }
                                     ],
                             
                             @"2" : @[
                                     @{
                                         @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_switch.v2.click",
                                         },
                                     @{
                                         @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                         @"value" : @"on",
                                         @"key" : @"prop.lumi.gateway.v3.arming",
                                         }
                                     ],
                             @"3" : @[
                                     @{
                                         @"extra" : @"[1,18,2,85,[0,2],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_cube.v1.alert",
                                         },
                                     @{
                                         @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                         @"value" : @"on",
                                         @"key" : @"prop.lumi.gateway.v3.arming",
                                         }
                                     ],
                             @"4" : @[
                                     @{
                                         @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_motion.v2.motion",
                                         }
                                     ],
                             @"5" : @[
                                     @{
                                         @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_switch.v2.click",
                                         }
                                     ],
                             @"6" : @[
                                     @{
                                         @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_magnet.v2.open",
                                         }
                                     ],
                             @"7" : @[
                                     @{
                                         @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_motion.v2.motion",
                                         }
                                     ],
                             @"8" : @[
                                     @{
                                         @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_motion.v2.motion",
                                         }
                                     ],
                             @"9" : @[
                                     @{
                                         @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_magnet.v2.open",
                                         }
                                     ],
                             @"10" : @[
                                     @{
                                         @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                         @"value" : @"",
                                         @"key" : @"event.lumi.sensor_switch.v2.click",
                                         }
                                     ]
                             };
    BindActionArray = @[
                        @{
                            @"value"    : @"10000",
                            @"command"  : @"lumi.gateway.v3.alarm",
                            @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                            },
                        @{
                            @"value"    : @"10000",
                            @"command"  : @"lumi.gateway.v3.alarm",
                            @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                            },
                        @{
                            @"value"    : @"0",
                            @"command"  : @"lumi.gateway.v3.alarm",
                            @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                            },
                        @{
                            @"value"    : @"10000",
                            @"command"  : @"lumi.gateway.v3.alarm",
                            @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                        },
                        @{
                            @"value"    : @"on",
                            @"command"  : @"lumi.gateway.v3.toggle_smart_light",
                            @"extra"    : @"[1,19,7,111,[48,3],0,0]",
                            },
                        @{
                            @"value"    : @"10000",
                            @"command"  : @"lumi.gateway.v3.door_bell",
                            @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                            },
                        @{
                            @"value"    : @"10000",
                            @"command"  : @"lumi.gateway.v3.door_bell",
                            @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                            },
                        @{
                            @"value"    : @"10000",
                            @"command"  : @"lumi.gateway.v3.door_bell",
                            @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                            },
                        @{
                            @"value"    : @[@"off"],
                            @"command"  : @"lumi.gateway.v3.play_alarm_clock",
                            @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                            },
                        @{
                            @"value"    : @[@"off"],
                            @"command"  : @"lumi.gateway.v3.play_alarm_clock",
                            @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                            },
                        @{
                            @"value"    : @[@"off"],
                            @"command"  : @"lumi.gateway.v3.play_alarm_clock",
                            @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                            }
                        ];
    
    ACPartnerBindActionArray = @[
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.acpartner.v1.alarm",
                                     @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.acpartner.v1.alarm",
                                     @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"0",
                                     @"command"  : @"lumi.acpartner.v1.alarm",
                                     @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.acpartner.v1.alarm",
                                     @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"on",
                                     @"command"  : @"lumi.acpartner.v1.toggle_smart_light",
                                     @"extra"    : @"[1,19,7,111,[48,3],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.acpartner.v1.door_bell",
                                     @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.acpartner.v1.door_bell",
                                     @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.acpartner.v1.door_bell",
                                     @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @[@"off"],
                                     @"command"  : @"lumi.acpartner.v1.play_alarm_clock",
                                     @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                                     },
                                 @{
                                     @"value"    : @[@"off"],
                                     @"command"  : @"lumi.acpartner.v1.play_alarm_clock",
                                     @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                                     },
                                 @{
                                     @"value"    : @[@"off"],
                                     @"command"  : @"lumi.acpartner.v1.play_alarm_clock",
                                     @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                                     }
                                 ];
    
#pragma mark - 摄像头
    cameraBindActionArray = @[
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.camera.v1.alarm",
                                     @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.camera.v1.alarm",
                                     @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"0",
                                     @"command"  : @"lumi.camera.v1.alarm",
                                     @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.camera.v1.alarm",
                                     @"extra"    : @"[1,19,1,85,[40,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"on",
                                     @"command"  : @"lumi.camera.v1.toggle_smart_light",
                                     @"extra"    : @"[1,19,7,111,[48,3],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.camera.v1.door_bell",
                                     @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.camera.v1.door_bell",
                                     @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @"10000",
                                     @"command"  : @"lumi.camera.v1.door_bell",
                                     @"extra"    : @"[1,19,2,85,[44,10000],0,0]",
                                     },
                                 @{
                                     @"value"    : @[@"off"],
                                     @"command"  : @"lumi.camera.v1.play_alarm_clock",
                                     @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                                     },
                                 @{
                                     @"value"    : @[@"off"],
                                     @"command"  : @"lumi.camera.v1.play_alarm_clock",
                                     @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                                     },
                                 @{
                                     @"value"    : @[@"off"],
                                     @"command"  : @"lumi.camera.v1.play_alarm_clock",
                                     @"extra"    : @"[1,19,5,111,[44,0],0,0]",
                                     }
                                 ];

    
    cameraBindLaunchDictionary = @{
                                      @"0" : @[
                                              @{
                                                  @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                                  @"value" : @"" ,
                                                  @"key"   : @"event.lumi.sensor_motion.v2.motion"
                                                  } ,
                                              @{
                                                  @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                                  @"value" : @"on" ,
                                                  @"key"   : @"prop.lumi.camera.v1.arming"
                                                  }
                                              ] ,
                                      
                                      @"1" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_magnet.v2.open",
                                                  },
                                              @{
                                                  @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                                  @"value" : @"on",
                                                  @"key" : @"prop.lumi.camera.v1.arming",
                                                  }
                                              ],
                                      
                                      @"2" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_switch.v2.click",
                                                  },
                                              @{
                                                  @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                                  @"value" : @"on",
                                                  @"key" : @"prop.lumi.camera.v1.arming",
                                                  }
                                              ],
                                      @"3" : @[
                                              @{
                                                  @"extra" : @"[1,18,2,85,[0,2],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_cube.v1.alert",
                                                  },
                                              @{
                                                  @"extra" : @"[1,19,6,111,[0,1],2,0]",
                                                  @"value" : @"on",
                                                  @"key" : @"prop.lumi.camera.v1.arming",
                                                  }
                                              ],
                                      @"4" : @[
                                              @{
                                                  @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_motion.v2.motion",
                                                  }
                                              ],
                                      @"5" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_switch.v2.click",
                                                  }
                                              ],
                                      @"6" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_magnet.v2.open",
                                                  }
                                              ],
                                      @"7" : @[
                                              @{
                                                  @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_motion.v2.motion",
                                                  }
                                              ],
                                      @"8" : @[
                                              @{
                                                  @"extra" : @"[1,1030,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_motion.v2.motion",
                                                  }
                                              ],
                                      @"9" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,1],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_magnet.v2.open",
                                                  }
                                              ],
                                      @"10" : @[
                                              @{
                                                  @"extra" : @"[1,6,1,0,[0,0],0,0]",
                                                  @"value" : @"",
                                                  @"key" : @"event.lumi.sensor_switch.v2.click",
                                                  }
                                              ]
                                      };


    static MHGatewayBindSceneManager *obj = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        obj = [[MHGatewayBindSceneManager alloc] init];
    });
    return obj;
}

#pragma mark - 获取绑定自动化列表，st_id为22的自动化
- (void)restoreBindList:(MHDeviceGateway *)device {
    XM_WS(weakself);
    //先上缓存
    [self restoreBindData:device.did WithSuccess:^(id obj) {
        [weakself rebuildBindList:obj withDevice:device];
    }];
}

- (void)fetchBindSceneList:(MHDeviceGateway *)device
               withSuccess:(SucceedBlock)success {
//删除所有自动化
//    [self fetchSceneList:device withSuccess:^(NSMutableArray *sceneList) {
//        [sceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL *stop) {
//            [scene deleteSceneWithSuccess:nil andFailure:nil];
//        }];
//    } failure:nil];
    
    XM_WS(weakself);
    [self fetchRemote:device withSuccess:^(id respObj) {
        //获取绑定
        [weakself rebuildBindList:respObj withDevice:device];
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        //先上缓存
        [weakself restoreBindList:device];
    }];
}

- (void)fetchRemote:(MHDeviceGateway *)gateway
        withSuccess:(SucceedBlock)success
            failure:(FailedBlock)failure {

    XM_WS(weakself);
    [self fetchSceneList:gateway withSuccess:^(NSArray *sceneList) {
        //获取的远程自动化进行一步操作，处理数据，将过去scene.name命名为lm_的自动化转成对应的数据。
        NSArray *newSceneList = [weakself dealOldSceneData:sceneList];
        
        //保存缓存
        [weakself saveBindDataToPList:newSceneList withDeviceDid:gateway.did];
        if (success)success(sceneList);
        
    } failure:^(NSError *error) {
        if (failure)failure(error);
    }];
}

- (NSArray *)dealOldSceneData:(NSArray *)oldSceneList {
    XM_WS(weakself);

//    NSLog(@"%@", oldSceneList);
    __block NSMutableArray *newSceneList = [oldSceneList mutableCopy];
    [oldSceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL *stop) {
        
        NSLog(@"自动化名字%@, 标识%@, %@", scene.name, scene.identify,NSStringFromClass([scene.identify class]));
        if([scene.name containsString:@"lm_scene_"] || ([bindRealSceneName containsObject:scene.name] && [scene.identify isEqualToString:@""])){

            NSLog(@"有问题的自动化标识<<%@>>>名字<<%@>>, 自动化id--%@", scene.identify, scene.name, scene.usId);
            NSString *realName = [weakself mapSceneName:scene.name];
            if(realName != nil) {
                scene.identify = scene.name;
                scene.name = realName;
                __block MHDataScene *newScene = [scene copy];


                newScene.usId = nil;
            //identify 只有创建时生成，不能编辑，因此要修改旧的identify只能先删除再新建
                [[MHGatewaySceneManager sharedInstance] deleteSceneWithUsid:scene.usId andSuccess:^(id obj) {
                    [newScene saveSceneWithSuccess:nil andFailure:nil];
                } andFailure:^(NSError *v) {
                    
                }];
            }
            else if ([bindRealSceneName containsObject:scene.name] && [scene.identify isEqualToString:@""]) {
                __block MHDataScene *newScene = [scene copy];
                newScene.usId = nil;
                newScene.identify = [self sceneNameToIdentify:newScene.name];
                NSLog(@"新自动化的标识%@", newScene.identify);
                if (!newScene.identify) {
                    return;
                }

                    //identify 只有创建时生成，不能编辑，因此要修改旧的identify只能先删除再新建
//                NSLog(@"%@", scene.usId);
            [[MHGatewaySceneManager sharedInstance] deleteSceneWithUsid:scene.usId andSuccess:^(id obj) {
//                        NSLog(@"新的scene%@", newScene);
                        [newScene saveSceneWithSuccess:^(id obj) {
                            NSLog(@"新建成功了欧巴");
                        } andFailure:^(NSError *error) {
//                            NSLog(@"新建失败%@",error);
                        }];
                    } andFailure:^(NSError *error) {
                        NSLog(@"删除失败%@",error);
                    }];

            }
            newSceneList[idx] = scene;
        }
        
        //用户切换语言环境可能出现的问题
        if (![bindRealSceneName containsObject:scene.name] && [scene.identify isEqualToString:@""]) {
            [[MHGatewaySceneManager sharedInstance] deleteSceneWithUsid:scene.usId andSuccess:^(id obj) {
                NSLog(@"删除不识别场景成功了%@",obj);
            } andFailure:^(NSError *error) {
                NSLog(@"删除不识别场景失败%@",error);
            }];
        }
    }];
    return [newSceneList mutableCopy];
}

//自动化名数据转换
- (NSString *)mapSceneName:(NSString *)sceneName {
    if([sceneName isEqualToString:@"lm_scene_1_1"]) return bindRealSceneName[0];
    else if([sceneName isEqualToString:@"lm_scene_1_2"]) return bindRealSceneName[1];
    else if([sceneName isEqualToString:@"lm_scene_1_3"]) return bindRealSceneName[2];
    else if([sceneName isEqualToString:@"lm_scene_1_4"]) return bindRealSceneName[3];
    else if([sceneName isEqualToString:@"lm_scene_2_1"]) return bindRealSceneName[4];
    else if([sceneName isEqualToString:@"lm_scene_3_1"]) return bindRealSceneName[5];
    else if([sceneName isEqualToString:@"lm_scene_3_2"]) return bindRealSceneName[6];
    else if([sceneName isEqualToString:@"lm_scene_3_3"]) return bindRealSceneName[7];
    else if([sceneName isEqualToString:@"lm_scene_4_1"]) return bindRealSceneName[8];
    else if([sceneName isEqualToString:@"lm_scene_4_2"]) return bindRealSceneName[9];
    else if([sceneName isEqualToString:@"lm_scene_4_3"]) return bindRealSceneName[10];
    return nil;
}

- (NSString *)sceneNameToIdentify:(NSString *)sceneName {

//    NSLog(@"%@", bindRealSceneName);
    NSInteger index = [bindRealSceneName indexOfObject:sceneName];
    if (index >= 0 && index <= 10) {
        return bindSceneName[index];
    }
    return nil;
}

#pragma mark - add scene
- (void)addScene:(MHLumiBindItem *)item
     withGateway:(MHDeviceGateway *)gateway
         success:(SucceedBlock)success
         failure:(FailedBlock)failure {
    
    XM_WS(weakself);
    __block MHDataScene *newScene = [weakself bindToScene:item Gateway:gateway];

    //获取列表，删除
    [self fetchSceneList:gateway withSuccess:^(NSArray *sceneList) {
        NSLog(@"自动化列表的%@", sceneList);
        NSLog(@"自动化列表的数量%ld", sceneList.count);
        [sceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL *stop) {
            MHLumiBindItem *oldItem = [weakself sceneToBind:scene withDevice:gateway.did];
            if ([item isEqualTo:oldItem]){
                newScene = scene;
                newScene.enable = YES;
                *stop = YES;
            }
        }];
        
        //转化scene to bind
        [newScene saveSceneWithSuccess:^(id obj) {
            NSLog(@"新的%@", obj);
            [weakself restoreBindData:gateway.did WithSuccess:^(NSMutableArray *datalist){
                NSMutableArray *mutableDatalist = [NSMutableArray arrayWithArray:datalist];
                if(!mutableDatalist) mutableDatalist = [NSMutableArray new];
                [mutableDatalist addObject:newScene];
                NSLog(@"数据类型%@", mutableDatalist);
                NSLog(@"数据类型的数量%ld", mutableDatalist.count);
                gateway.systemSceneList = mutableDatalist;
                NSLog(@"%@", gateway.systemSceneList);
                NSLog(@"%ld", gateway.systemSceneList.count);
                [weakself saveBindDataToPList:mutableDatalist withDeviceDid:gateway.did];
            }];
            
            if(success) success(obj);
            
        } andFailure:^(NSError *error) {
            if(failure) failure(error);
        }];

    } failure:nil];
}

#pragma mark - remove scene
- (void)removeScene:(MHLumiBindItem *)item
        withGateway:(MHDeviceGateway *)gateway
            success:(SucceedBlock)success
            failure:(FailedBlock)failure {
    XM_WS(weakself);

    //先清理缓存
    [self restoreBindData:gateway.did WithSuccess:^(NSMutableArray *sceneList) {

        NSMutableArray *oldSceneList = [sceneList mutableCopy];
        __block MHDataScene *oldScene ;
        [sceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL *stop) {
            MHLumiBindItem *oldItem = [weakself sceneToBind:scene withDevice:gateway.did];
            if ([oldItem isEqualTo:item]) {
                oldScene = scene;
                [oldSceneList removeObject:oldScene];
            }
        }];
        gateway.systemSceneList = oldSceneList;
         NSLog(@"%ld", gateway.systemSceneList.count);
        [weakself saveBindDataToPList:oldSceneList withDeviceDid:gateway.did];
    }];
    
    //获取列表，删除
    [self fetchSceneList:gateway withSuccess:^(NSArray *sceneList) {
        
        __block MHDataScene *oldScene;
        NSMutableArray *deleteSceneList = [NSMutableArray new];
        [sceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL *stop) {
            MHLumiBindItem *oldItem = [weakself sceneToBind:scene withDevice:gateway.did];
            if ([oldItem isEqualTo:item]){
                oldScene = scene;
                [deleteSceneList addObject:scene];
            }
        }];
        
        if (deleteSceneList.count) {
            __block NSInteger index = 0;
            [weakself setDeleteBindBlock:^{
                XM_SS(strongself, weakself);
                if (index > deleteSceneList.count - 1) {
                    if (success) success(nil);
                    return;
                }
                NSLog(@"%@",[deleteSceneList[index] usId]);
                [[MHGatewaySceneManager sharedInstance] deleteSceneWithUsid:[deleteSceneList[index] usId] andSuccess:^(id obj) {
                    if (weakself.deleteBindBlock) weakself.deleteBindBlock();
                } andFailure:^(NSError *error) {
                    if (failure) failure(error);
                }];
                index += 1;
            }];
            weakself.deleteBindBlock();
        }
        else {
            //没有，就当已经删除了
            if (success) success(nil);
        }
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 数据操作
- (void)fetchSceneList:(MHDeviceGateway *)device withSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    MHGatewaySceneListRequest *req = [[MHGatewaySceneListRequest alloc] init];
    req.sensor = device;
    req.st_id = @"22";
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewaySceneListResponse *rsp = [MHGatewaySceneListResponse responseWithJSONObject:json];
        
        if(!rsp.sceneList) rsp.sceneList = [NSArray new];
        if(success)success(rsp.sceneList);
        device.systemSceneList = rsp.sceneList;
    } failure:^(NSError *error) {
        NSLog(@"拉取22号自动化失败%@", error);
        if(failure)failure(error);
    }];
}

/**
 *  过滤掉离线和非本网关的系统场景
 *
 *  @param sceneList 场景列表
 *  @param device    对应的网关
 *
 *  @return 新的系统场景列表
 */
- (NSArray<MHDataScene *> *)checkSystemScene:(NSArray<MHDataScene *> *)sceneList gateway:(MHDeviceGateway *)device {
    NSMutableArray *result = [NSMutableArray new];
    [sceneList enumerateObjectsUsingBlock:^(MHDataScene * _Nonnull scene, NSUInteger idx, BOOL * _Nonnull stop1) {
        [scene.actionList enumerateObjectsUsingBlock:^(MHDataAction *action, NSUInteger idx, BOOL * _Nonnull stop2) {
            NSLog(@"action的信息---%@, %@, %@",  action.deviceName ,action.deviceModel, action.deviceDid);
            //执行设备是当前网关
            if ([action.deviceDid isEqualToString:device.did]) {
                [scene.launchList enumerateObjectsUsingBlock:^(MHDataLaunch *launch, NSUInteger idx, BOOL * _Nonnull stop3) {
                    NSLog(@"启动条件的名字和did ---- %@, %@", launch.name, launch.deviceDid);
                    MHDevice *newDevice = [[MHDevListManager sharedManager] deviceForDid:launch.deviceDid];
                    [device.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *subDevice, NSUInteger idx, BOOL * _Nonnull stop4) {
                        //设备是否存在, 在线,属于当前网关
                        if ((newDevice && newDevice.isOnline) && [newDevice.did isEqualToString:subDevice.did]) {
                            [result addObject:scene];
                            *stop4 = YES;
                        }
                    }];
                }];
            }
        }];
    }];
    return result;
}

#pragma mark : subdevice build bindlist
- (void)rebuildBindList:(NSArray *)sceneList withDevice:(MHDeviceGateway *)gateway {
    NSMutableArray *sensorBindList = [NSMutableArray arrayWithCapacity:1];
    XM_WS(weakself);
    [sceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL *stop) {
        MHLumiBindItem *item = [self sceneToBind:scene withDevice:gateway.did];
        if(item)[sensorBindList addObject:item];
        
        //单个子设备拆分
        [weakself subdeviceSensorBindList:gateway withGatewayBindItem:item];
    }];
}

//单个子设备拆分
- (void)subdeviceSensorBindList:(MHDeviceGateway *)gateway
            withGatewayBindItem:(MHLumiBindItem *)bindItem {
    
    [gateway.subDevices enumerateObjectsWithOptions:NSEnumerationConcurrent
                                         usingBlock:^(MHDeviceGatewayBase *sensor,
                                                      NSUInteger idx, BOOL *stop) {
                                             
                                             if ([bindItem.from_sid isEqualToString:sensor.did] &&
                                                 [sensor respondsToSelector:@selector(bindList)]) {
                                                 NSMutableArray *newBindList = [NSMutableArray arrayWithArray:sensor.bindList];
                                                 
                                                 BOOL canAdd = YES;
                                                 for (MHLumiBindItem *item in sensor.bindList) {
                                                     if ([item isEqualTo:bindItem]) {
                                                         canAdd = NO;
                                                     }
                                                 }
                                                 if (canAdd) [newBindList addObject:bindItem];
                                                 sensor.bindList = newBindList;
                                                 sensor.isBindListGot = YES;
                                                 [sensor saveBindItems];
                                                 NSLog(@"%@ , %@", sensor, sensor.bindList);
                                             }
                                         }];
}

#pragma mark : Scene to bind
- (MHLumiBindItem *)sceneToBind:(MHDataScene *)scene withDevice:(NSString *)gatewayDid {
    if([bindSceneName indexOfObject:scene.identify] != NSNotFound ||
       [bindSceneName indexOfObject:scene.name] != NSNotFound){
        NSInteger index = [bindSceneName indexOfObject:scene.name];
        if(scene.identify.length) index = [bindSceneName indexOfObject:scene.identify];
        
        MHLumiBindItem* bindItem = [[MHLumiBindItem alloc] init];
        //launchList 不获取网关的id
        [scene.launchList enumerateObjectsUsingBlock:^(MHDataLaunch *launch, NSUInteger idx, BOOL *stop) {
            if (![launch.deviceDid isEqualToString:gatewayDid]) {
                bindItem.from_sid = launch.deviceDid ;
                * stop = YES;
            }
        }];
        
        bindItem.to_sid = gatewayDid;
        bindItem.method = bindMethodEvent[index][0];
        bindItem.event = bindMethodEvent[index][1];
        bindItem.enable = scene.enable;
        return bindItem;
    }
    else {
        return nil;
    }
}

#pragma mark : Bind to Scene
- (MHDataScene *)bindToScene:(MHLumiBindItem *)bindItem
                     Gateway:(MHDeviceGateway *)gateway {
    
    NSInteger index = [bindMethodEvent indexOfObject:@[bindItem.method,bindItem.event]];
    NSString *userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    
    MHDataScene *scene = [[MHDataScene alloc] init];
    scene.std_id = @"22";
    scene.name = bindRealSceneName[index];
    scene.identify = bindSceneName[index];
    scene.enable = YES;
    scene.uid = userID;

    scene.actionList = [self actionFromSceneName:index withGateway:gateway];
//    scene.launchList = [self launchFromSceneName:index
//                             withLaunchDeviceDid:bindItem.from_sid
//                                      gatewayDid:gateway.did];
    scene.launchList = [self launchFromSceneName:index withLaunchDeviceDid:bindItem.from_sid gateway:gateway];
    //添加感应夜灯的时段
    if ([bindItem.method isEqualToString:Method_OpenNightLight]) {
        for (MHDataLaunch *lauch in scene.launchList) {
            lauch.timeSpan = [bindItem.params firstObject];
        }
    }
    return scene;
}

- (NSMutableArray *)actionFromSceneName:(NSInteger)sceneNameIndex
                          withGateway:(MHDeviceGateway *)gateway {
    
    NSMutableArray *actionlist = [NSMutableArray arrayWithCapacity:1];
    NSDictionary *actionDic = nil;
    if ([gateway.model isEqualToString:DeviceModelAcpartner]) {
        actionDic = ACPartnerBindActionArray[sceneNameIndex];
    }
    else if ([gateway.model isEqualToString:DeviceModelCamera]) {
        actionDic = cameraBindActionArray[sceneNameIndex];
    }
    else {
        actionDic = BindActionArray[sceneNameIndex];
    }
    
    MHDataAction *action = [[MHDataAction alloc] init];
    action.deviceModel = gateway.model;
    action.name = @"name";
    action.deviceName = gateway.name;
    action.type = @"0";
    
    action.command = [actionDic valueForKey:@"command"];
    action.extra = [actionDic valueForKey:@"extra"];
    action.deviceDid = gateway.did;
    action.value = [actionDic valueForKey:@"value"];
    action.total_length = @"0";
    
    [actionlist addObject:action];
    
    return actionlist;
}

- (NSMutableArray *)launchFromSceneName:(NSInteger)sceneNameIndex
                    withLaunchDeviceDid:(NSString *)deviceDid
                             gatewayDid:(NSString *)gatewayDid {
    NSMutableArray *launchlist = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *launchArray = [BindLaunchDictionary valueForKey:[NSString stringWithFormat:@"%ld",sceneNameIndex]];
    
    [launchArray enumerateObjectsUsingBlock:^(NSDictionary *launchDic, NSUInteger idx, BOOL *stop) {
        MHDataLaunch *launch = [[MHDataLaunch alloc] init];
        launch.name = @"name";
        launch.deviceName = @"dev";
        launch.src = @"device";
        
        if (idx == 0) {
            launch.deviceDid = deviceDid ;
        }
        else {
            launch.deviceDid = gatewayDid ;
        }
        launch.deviceKey = [launchDic valueForKey:@"key"];
        launch.value = [launchDic valueForKey:@"value"];
        launch.extra = [launchDic valueForKey:@"extra"];
        
        [launchlist addObject:launch];
    }];
    
    return launchlist;
}

#pragma mark - new
- (NSMutableArray *)launchFromSceneName:(NSInteger)sceneNameIndex
                    withLaunchDeviceDid:(NSString *)deviceDid
                                gateway:(MHDeviceGateway *)gateway {
    NSMutableArray *launchlist = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *launchArray = nil;
    if ([gateway.model isEqualToString:DeviceModelAcpartner]) {
        launchArray = [ACPartnerBindLaunchDictionary valueForKey:[NSString stringWithFormat:@"%ld",sceneNameIndex]];
    }
    else if ([gateway.model isEqualToString:DeviceModelCamera]) {
        launchArray = [cameraBindLaunchDictionary valueForKey:[NSString stringWithFormat:@"%ld",sceneNameIndex]];
    }
    else {
        launchArray = [BindLaunchDictionary valueForKey:[NSString stringWithFormat:@"%ld",sceneNameIndex]];
    }

    
    
    [launchArray enumerateObjectsUsingBlock:^(NSDictionary *launchDic, NSUInteger idx, BOOL *stop) {
        MHDataLaunch *launch = [[MHDataLaunch alloc] init];
        launch.name = @"name";
        launch.deviceName = @"dev";
        launch.src = @"device";
        
        if (idx == 0) {
            launch.deviceDid = deviceDid ;
        }
        else {
            launch.deviceDid = gateway.did;
        }
        launch.deviceKey = [launchDic valueForKey:@"key"];
        launch.value = [launchDic valueForKey:@"value"];
        launch.extra = [launchDic valueForKey:@"extra"];
        
        [launchlist addObject:launch];
    }];
    
    return launchlist;
}

#pragma mark - 处理缓存
//缓存的原始scenelist
- (void)saveBindDataToPList:(NSArray *)bindList withDeviceDid:(NSString *)did {
    //保存缓存
    NSString *userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncSave:bindList
                                          toFile:[NSString stringWithFormat:@"lumi_gateway_bindlist_%@_%@", userID, did]
                                      withFinish:nil];
}

- (void)restoreBindData:(NSString *)deviceDid WithSuccess:(SucceedBlock)success {
    NSString *userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"lumi_gateway_bindlist_%@_%@", userID,deviceDid]
                                              withFinish:^(id obj) {
                                                  if (success) success(obj);
                                              }];
}

@end
