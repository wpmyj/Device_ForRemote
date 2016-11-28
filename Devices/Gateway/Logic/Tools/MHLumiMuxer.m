//
//  MHLumiMuxer.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/18.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHLumiMuxer.h"
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavutil/imgutils.h>
#import <libswscale/swscale.h>
#import <libavutil/mathematics.h>
#import <AVFoundation/AVFoundation.h>

@interface MHLumiMuxer()
@property (nonatomic, copy) NSString *theVideoPath;
@property (nonatomic, strong) dispatch_queue_t lumiMuxerQueue;
@end


@implementation MHLumiMuxer{
    NSArray *imageArr;
    AVOutputFormat              *ofmt;
    AVFormatContext             *ifmt_ctx_v;
    AVFormatContext             *ifmt_ctx_a;
    AVFormatContext             *ofmt_ctx;
    AVPacket                    pkt;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _lumiMuxerQueue = dispatch_queue_create("queue.MHLumiMuxer", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)mux2WithInputVideoName:(NSString *)inputVideoName
               inputAudioName:(NSString *)inputAudioName
            andOutputFileName:(NSString *)outputFileName
                        queue:(dispatch_queue_t)queue
              completeHandler:(void(^)(int))completeHandler{
    dispatch_async(_lumiMuxerQueue, ^{
        NSURL *audioUrl=[NSURL fileURLWithPath:inputAudioName];
        NSURL *videoUrl=[NSURL fileURLWithPath:inputVideoName];
        
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
        AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
        
        //混合音乐
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
//        AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
//                                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
//        [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
//                                            ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
//                                             atTime:kCMTimeZero error:nil];
        
        
        //混合视频
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                       ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                        atTime:kCMTimeZero error:nil];
        AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                              presetName:AVAssetExportPresetPassthrough];
        //保存混合后的文件的过程
        NSString *exportPath = outputFileName;
        NSURL *exportUrl = [NSURL fileURLWithPath:outputFileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
        }
        NSLog(@"%@",_assetExport.supportedFileTypes);
        _assetExport.outputFileType = AVFileTypeMPEG4;
        NSLog(@"file type %@",_assetExport.outputFileType);
        _assetExport.outputURL = exportUrl;
        _assetExport.shouldOptimizeForNetworkUse = YES;
        
        [_assetExport exportAsynchronouslyWithCompletionHandler:
         ^(void ) 
         {    
             NSLog(@"完成了");
             completeHandler(0);
         }];
    });
}

- (void)muxWithInputVideoName:(NSString *)inputVideoName
               inputAudioName:(NSString *)inputAudioName
            andOutputFileName:(NSString *)outputFileName
                        queue:(dispatch_queue_t)queue
              completeHandler:(void(^)(int))completeHandler{
    dispatch_async(queue, ^{
        int retcode = [self muxWithInputVideoName:inputVideoName inputAudioName:inputAudioName andOutputFileName:outputFileName];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeHandler(retcode);
        });
    });
}

- (void)muxWithInputVideoName:(NSString *)inputVideoName
               inputAudioName:(NSString *)inputAudioName
            andOutputFileName:(NSString *)outputFileName
              completeHandler:(void(^)(int))completeHandler{
    [self muxWithInputVideoName:inputVideoName inputAudioName:inputAudioName andOutputFileName:outputFileName queue:_lumiMuxerQueue completeHandler:completeHandler];
}

- (int)muxWithInputVideoName:(NSString *)inputVideoName
              inputAudioName:(NSString *)inputAudioName
           andOutputFileName:(NSString *)outputFileName{
    int ret, i;
    int videoindex_v=-1,videoindex_out=-1;
    int audioindex_a=-1,audioindex_out=-1;
    int frame_index=0;
    int64_t cur_pts_v=0,cur_pts_a=0;
    bool haveAudio = NO;
    const char *in_filename_v = [inputVideoName UTF8String];
    const char *in_filename_a = [inputAudioName UTF8String];
    
    const char *out_filename = [outputFileName UTF8String];//Output file URL
    
    if (inputAudioName && ![inputAudioName isEqualToString:@""]){
        haveAudio = YES;
    }
    //初始化
    av_register_all();
    avcodec_register_all();
    avformat_network_init();//初始化网络部分
    //Input
    ifmt_ctx_v = avformat_alloc_context();
    if ((ret = avformat_open_input(&ifmt_ctx_v, in_filename_v, 0, 0)) < 0) {
        printf( "Could not open input file.");
        return [self endWithRetcode:ret];
    }
    if ((ret = avformat_find_stream_info(ifmt_ctx_v, 0)) < 0) {
        printf( "Failed to retrieve input stream information");
        return [self endWithRetcode:ret];
    }
    
    if (haveAudio){
        ifmt_ctx_a = avformat_alloc_context();
        if ((ret = avformat_open_input(&ifmt_ctx_a, in_filename_a, 0, 0)) < 0) {
            printf( "Could not open input file.");
            char *buf = malloc(1024);
            av_strerror(ret, buf, 1024);
            printf("Couldn't open file %s: %d(%s)", in_filename_a, ret, buf);
            return [self endWithRetcode:ret];
        }
        if ((ret = avformat_find_stream_info(ifmt_ctx_a, 0)) < 0) {
            printf( "Failed to retrieve input stream information");
            return [self endWithRetcode:ret];
        }
    }
    
    
    printf("===========Input Information==========\n");
    av_dump_format(ifmt_ctx_v, 0, in_filename_v, 0);
    if (haveAudio){
        av_dump_format(ifmt_ctx_a, 0, in_filename_a, 0);
    }
    printf("======================================\n");
    
    //Output
    ofmt_ctx = avformat_alloc_context();
    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, out_filename);
    if (!ofmt_ctx) {
        printf( "Could not create output context\n");
        ret = AVERROR_UNKNOWN;
        return [self endWithRetcode:ret];
    }
    ofmt = ofmt_ctx->oformat;
    
    for (i = 0; i < ifmt_ctx_v->nb_streams; i++) {
        //Create output AVStream according to input AVStream
        if(ifmt_ctx_v->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO){
            AVStream *in_stream = ifmt_ctx_v->streams[i];
            AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
            videoindex_v=i;
            if (!out_stream) {
                printf( "Failed allocating output stream\n");
                ret = AVERROR_UNKNOWN;
                return [self endWithRetcode:ret];
            }
            videoindex_out=out_stream->index;
            //Copy the settings of AVCodecContext
            if (avcodec_copy_context(out_stream->codec, in_stream->codec) < 0) {
                printf( "Failed to copy context from input to output stream codec context\n");
                return [self endWithRetcode:ret];
            }
            out_stream->codec->codec_tag = 0;
            if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                out_stream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
            break;
        }
    }
    
    if (haveAudio){
        for (i = 0; i < ifmt_ctx_a->nb_streams; i++) {
            //Create output AVStream according to input AVStream
            if(ifmt_ctx_a->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO){
                AVStream *in_stream = ifmt_ctx_a->streams[i];
                AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
                audioindex_a=i;
                if (!out_stream) {
                    printf( "Failed allocating output stream\n");
                    ret = AVERROR_UNKNOWN;
                    return [self endWithRetcode:ret];
                }
                audioindex_out=out_stream->index;
                //Copy the settings of AVCodecContext
                if (avcodec_copy_context(out_stream->codec, in_stream->codec) < 0) {
                    printf( "Failed to copy context from input to output stream codec context\n");
                    return [self endWithRetcode:ret];
                }
                out_stream->codec->codec_tag = 0;
                if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                    out_stream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
                
                break;
            }
        }
    }
    
    printf("==========Output Information==========\n");
    av_dump_format(ofmt_ctx, 0, out_filename, 1);
    printf("======================================\n");
    
    //Open output file
    if (!(ofmt->flags & AVFMT_NOFILE)) {
        if (avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE) < 0) {
            printf( "Could not open output file '%s'", out_filename);
            return [self endWithRetcode:ret];
        }
    }
    //Write file header
    if (avformat_write_header(ofmt_ctx, NULL) < 0) {
        printf( "Error occurred when opening output file\n");
        return [self endWithRetcode:ret];
    }
    
    //FIX
#if USE_H264BSF
    AVBitStreamFilterContext* h264bsfc =  av_bitstream_filter_init("h264_mp4toannexb");
#endif
#if USE_AACBSF
    AVBitStreamFilterContext* aacbsfc =  av_bitstream_filter_init("aac_adtstoasc");
#endif
    
    while (1) {
        AVFormatContext *ifmt_ctx;
        int stream_index=0;
        AVStream *in_stream, *out_stream;
        
        //Get an AVPacket
        if(!haveAudio || av_compare_ts(cur_pts_v,ifmt_ctx_v->streams[videoindex_v]->time_base,cur_pts_a,ifmt_ctx_a->streams[audioindex_a]->time_base) <= 0){
            ifmt_ctx=ifmt_ctx_v;
            stream_index=videoindex_out;
            
            if(av_read_frame(ifmt_ctx, &pkt) >= 0){
                do{
                    in_stream  = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = ofmt_ctx->streams[stream_index];
                    
                    if(pkt.stream_index==videoindex_v){
                        //FIX£∫No PTS (Example: Raw H.264)
                        //Simple Write PTS
                        if(pkt.pts==AV_NOPTS_VALUE){
                            //Write PTS
                            AVRational time_base1=in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts=(double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            pkt.dts=pkt.pts;
                            pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            frame_index++;
                        }
                        
                        cur_pts_v=pkt.pts;
                        break;
                    }
                }while(av_read_frame(ifmt_ctx, &pkt) >= 0);
            }else{
                break;
            }
        }else{
            ifmt_ctx=ifmt_ctx_a;
            stream_index=audioindex_out;
            if(av_read_frame(ifmt_ctx, &pkt) >= 0){
                do{
                    in_stream  = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = ofmt_ctx->streams[stream_index];
                    
                    if(pkt.stream_index==audioindex_a){
                        
                        //FIX£∫No PTS
                        //Simple Write PTS
                        if(pkt.pts==AV_NOPTS_VALUE){
                            //Write PTS
                            AVRational time_base1=in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts=(double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            pkt.dts=pkt.pts;
                            pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            frame_index++;
                        }
                        cur_pts_a=pkt.pts;
                        
                        break;
                    }
                }while(av_read_frame(ifmt_ctx, &pkt) >= 0);
            }else{
                break;
            }
            
        }
        
        //FIX:Bitstream Filter
#if USE_H264BSF
        av_bitstream_filter_filter(h264bsfc, in_stream->codec, NULL, &pkt.data, &pkt.size, pkt.data, pkt.size, 0);
#endif
#if USE_AACBSF
        av_bitstream_filter_filter(aacbsfc, out_stream->codec, NULL, &pkt.data, &pkt.size, pkt.data, pkt.size, 0);
#endif
        
        
        //Convert PTS/DTS
        pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.duration = (int)av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;
        pkt.stream_index=stream_index;
        printf("Write 1 Packet. size:%5d\tpts:%lld\n",pkt.size,pkt.pts);
        //Write
        if (av_interleaved_write_frame(ofmt_ctx, &pkt) < 0) {
            printf( "Error muxing packet\n");
            break;
        }
        av_free_packet(&pkt);
        
    }
    
    //Write file trailer
    av_write_trailer(ofmt_ctx);
    
#if USE_H264BSF
    av_bitstream_filter_close(h264bsfc);
#endif
#if USE_AACBSF
    av_bitstream_filter_close(aacbsfc);
#endif
    return 0;
}

- (int)endWithRetcode:(int) ret{
    if (ifmt_ctx_v){
        avformat_close_input(&ifmt_ctx_v);
    }
    if (ifmt_ctx_a){
        avformat_close_input(&ifmt_ctx_a);
    }
    /* close output */
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE))
        avio_close(ofmt_ctx->pb);
    avformat_free_context(ofmt_ctx);
    if (ret < 0 && ret != AVERROR_EOF) {
        printf( "Error occurred.\n");
        return -1;
    }
    return 0;
}

- (void)dealloc{
    av_free_packet(&pkt);
    [self endWithRetcode:0];
}

@end
