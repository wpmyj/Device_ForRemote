//
//  MHLumiTUTKHeader.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/23.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#ifndef MHLumiTUTKHeader_h
#define MHLumiTUTKHeader_h

#import "MHLumiTUTKBackwordTimeData.h"

typedef NS_ENUM(NSInteger,MHLumiTUTKClientstatus){
    MHLumiTUTKClientstatusStandby       = 0,
    MHLumiTUTKClientstatusConnecting,
    MHLumiTUTKClientstatusConnected,
    MHLumiTUTKClientstatusDisconnect,
};

typedef NS_ENUM(NSInteger,MHLumiTUTKStreamstatus){
    MHLumiTUTKStreamstatusON            = 0,
    MHLumiTUTKStreamstatusONAndRequest,
    MHLumiTUTKStreamstatusOFF,
};

typedef NS_ENUM(NSInteger,MHLumiTUTKTalkbackStatus){
    MHLumiTUTKTalkbackStatusDefault            = 0,
    MHLumiTUTKTalkbackStatusConnectting,
    MHLumiTUTKTalkbackStatusConnected,
};

typedef NS_ENUM(NSInteger,MHLumiTUTKVideoQuality){
    MHLumiTUTKVideoQualityHigh            = 0,
    MHLumiTUTKVideoQualityStandard,
    MHLumiTUTKVideoQualityAuto,
};

typedef NS_ENUM(NSInteger,MHLumiTUTKVideoMode){
    // 水平180
    MHLumiTUTKVideoModeP180           = 0,
    // 水平360
    MHLumiTUTKVideoModeP360,
    // 水平1R全景
    MHLumiTUTKVideoMode1R,
    // 水平4R
    MHLumiTUTKVideoMode4R,
    // VR视角
    MHLumiTUTKVideoModeVR,
    // 原始视角
    MHLumiTUTKVideoModeORIGIN,
};

typedef enum{
    IOTYPE_USER_IPCAM_SET_VIDEO_MODE            = 0x600,//视频的模式（水平180，水平360这种）
    IOTYPE_USER_IPCAM_SET_VIDEO_QUALITY         = 0x601,//视频清晰度
    IOTYPE_USER_IPCAM_PLAYRECORDSTART           = 0x0304,//开启回看
    IOTYPE_USER_IPCAM_PLAYRECORDSTOP            = 0x0305,//关闭回看
    IOTYPE_USER_IPCAM_SPEAKERSTART_LUMI         = 0x0302,
    IOTYPE_USER_IPCAM_SPEAKERSTOP_LUMI          = 0x0303,
    IOTYPE_USER_IPCAM_GETRECORDTIME			    = 0x0307,//请求可回看时间区域请求
 	IOTYPE_USER_IPCAM_GETRECORDTIMERSP			= 0x0308,//获取可回看时间区域
}MHLumiTUTKIOControl;

//this.codecId = Packet.byteArrayToShort_Little(frameInfo, 0);
//this.flags = frameInfo[2];
//this.camIndex = frameInfo[3];
//this.onlineNum = frameInfo[4];
//this.frmNo = Packet.byteArrayToShort_Little(frameInfo, 6);
//this.timestamp = Packet.byteArrayToInt_Little(frameInfo, 12);
//this.videoWidth = Packet.byteArrayToInt_Little(frameInfo, 16);
//this.videoHeight = Packet.byteArrayToInt_Little(frameInfo, 20);
//this.frmState = frmState;
//this.frmSize = frmSize;
//this.frmData = frmData;

typedef struct LumiTUTKFrameInfo{
    unsigned short codec_id;	// 0，1
    unsigned char flags;		//2
    unsigned char cam_index;	//3
    unsigned char onlineNum;	//4
    
    unsigned char unuse_char;    //5
    
    unsigned short frmNo;       //6，7
    
    unsigned int unuse_int;      //8,9,10,11
    
    unsigned int timestamp; 	//12,13,14,15
    unsigned int videowidth;    //16,17,18,19
    unsigned int videoheight;   //20,21,22,23
}LumiTUTKFrameInfo;

typedef struct MHLumiTUTKFrameData{
    LumiTUTKFrameInfo frameInfo;
    AVFrame  avframe;
}MHLumiTUTKFrameData;

#define TYPE_SERVER_STREAMING 16

#endif /* MHLumiTUTKHeader_h */
