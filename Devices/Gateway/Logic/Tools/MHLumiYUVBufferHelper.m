//
//  MHLumiYUVBufferHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/3.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHLumiYUVBufferHelper.h"
#import <libswscale/swscale.h>
#import <string.h>

@interface MHLumiYUVBufferHelper()
@property (nonatomic, copy) NSString *inputPath;
@property (nonatomic, strong) NSData *yuvData;
@end

@implementation MHLumiYUVBufferHelper{
    //声明变量
    AVFormatContext     *pFormatCtx;
    AVCodecContext      *pCodecCtx;
    AVCodec             *pCodec;
    AVFrame             *pFrame;
    AVPacket            *packet;
    int                 videoStreamIndex;
    unsigned char       *buf;
    bool                _isReadToEnd;
    int                 _frameWidth;
    int                 _frameHeight;
}
+ (NSData *)yuvBufferWithYData:(uint8_t **)data linesize:(int *)linesize frameWidth:(int)width frameHeight:(int)height{
    
    int picSize = width * height;
    int newSize = picSize * 1.5;
    unsigned char *buf = (unsigned char *)malloc(newSize);
    memset(buf, 0, newSize);
    int a=0,j;
    for (j=0; j<height; j++){
        memcpy(buf+a,data[0] + j * linesize[0], width);
        a+=width;
    }
    for (j=0; j<height/2; j++){
        memcpy(buf+a,data[1] + j * linesize[1], width/2);
        a+=width/2;
    }
    for (j=0; j<height/2; j++)
    {
        memcpy(buf+a,data[2] + j * linesize[2], width/2);
        a+=width/2;
    }
    NSData *todoData = [[NSData alloc] initWithBytes:buf length:newSize];
    free(buf);
    return todoData;
}

- (instancetype)initWithPath:(NSString *)path{
    self = [super init];
    if (self) {
        self.inputPath = path;
    }
    return self;
}

- (void)dealloc{
    if (pFrame){
        avcodec_free_frame(&pFrame);
        pFrame = NULL;
    }
    if (pCodecCtx){
        avcodec_close(pCodecCtx);
        av_free(pCodecCtx);
        pCodecCtx = NULL;
    }
    av_free_packet(packet);
}

- (void)initffmpeg{
    //初始化
    av_register_all();
    avformat_network_init();//初始化网络部分
    pFormatCtx = avformat_alloc_context();
    
    //Open an input stream and read the header. The codecs are not opened.
    //打开媒体文件入口
    if(avformat_open_input(&pFormatCtx,[self.inputPath UTF8String],NULL,NULL)!=0){
        printf("Couldn't open input stream.\n");
        return ;
    }
    
    //没有头文件时候，打开。Read packets of a media file to get stream information.
    if(avformat_find_stream_info(pFormatCtx,NULL)<0){
        printf("Couldn't find stream information.\n");
        return;
    }
    
    videoStreamIndex = -1;
    for(int i=0; i<pFormatCtx->nb_streams; i++)//nb_streams，AVFormatContext的元素个数
        if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO){
            videoStreamIndex=i;
            break;
        }
    if(videoStreamIndex == -1){//依旧为-1，则没找到stream
        printf("Couldn't find a video stream.\n");
        return;
    }
    
    //找到的流媒体赋值给AVCodecContext，准备解码
    pCodecCtx=pFormatCtx->streams[videoStreamIndex]->codec;
    
    //用于查找FFmpeg的解码器。参数为id，按照id查找解码器，返回解码器AVCodec
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec==NULL){
        printf("Couldn't find Codec.\n");
        return;
    }
    
    //avctx：需要初始化的AVCodecContext。 codec：输入的AVCodec
    if(avcodec_open2(pCodecCtx, pCodec,NULL)<0){
        printf("Couldn't open codec.\n");
        return;
    }
    
    //初始化frame
    pFrame=av_frame_alloc();
    
    //AVPacket：解码前数据,存储压缩编码数据相关信息的结构体
    packet=(AVPacket *)av_malloc(sizeof(AVPacket));
    
}

//开始读取文件，读到文件解码
- (void *)readAVFrameFile{
    //开始读取文件
    int gotPictureCount = -1;
    int ret = av_read_frame(pFormatCtx, packet);
    if (ret>=0){
        if(packet->stream_index == videoStreamIndex){
            //下面开始真正的解码
            int ret = avcodec_decode_video2(pCodecCtx, pFrame, &gotPictureCount, packet);
            
            //成功解码
            if(ret >= 0 && gotPictureCount){
                
                _yuvData = [MHLumiYUVBufferHelper yuvBufferWithYData:pFrame->data linesize:pFrame->linesize frameWidth:pCodecCtx->width frameHeight:pCodecCtx->height];
                
                //                NSLog(@"成功解码一次");
                int picSize = pCodecCtx->height * pCodecCtx->width;
                int newSize = picSize * 1.5;
                //申请内存
                if (!buf || _frameWidth != pCodecCtx->width || _frameHeight != pCodecCtx->height){
                    _frameWidth = pCodecCtx->width;
                    _frameHeight = pCodecCtx->height;
                    NSLog(@"申请内存: %d",newSize);
                    if (buf){
                        free(buf);
                    }
                    buf = (unsigned char*)malloc(newSize);
                }
                memset(buf, 0, newSize);
                memcpy(buf, _yuvData.bytes, newSize);
                return buf;
            }
        }
    }else{
        NSLog(@"文件读取完毕");
        _isReadToEnd = YES;
    }
    _yuvData = nil;
    return NULL;
}

- (BOOL)isReadToEnd{
    return _isReadToEnd;
}

- (NSData *)fetchYUVBufferData{
    unsigned char *yuv;
    yuv = [self readAVFrameFile];
    if (yuv == NULL){
        return nil;
    }
    return _yuvData;
}

@end
