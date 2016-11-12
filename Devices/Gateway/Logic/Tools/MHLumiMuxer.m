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
@end


@implementation MHLumiMuxer{
    NSArray *imageArr;
    AVOutputFormat              *ofmt;
    AVFormatContext             *ifmt_ctx_v;
    AVFormatContext             *ifmt_ctx_a;
    AVFormatContext             *ofmt_ctx;
    AVPacket                    pkt;
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

-(void)testCompressionSession
{
    NSLog(@"开始");
    //NSString *moviePath = [[NSBundle mainBundle]pathForResource:@"Movie" ofType:@"mov"];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *moviePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"test"]];
    self.theVideoPath=moviePath;
    CGSize size =CGSizeMake(320,400);//定义视频的大小
    
    //    [selfwriteImages:imageArr ToMovieAtPath:moviePath withSize:sizeinDuration:4 byFPS:30];//第2中方法
    
    NSError *error =nil;
    
//    unlink([moviePathUTF8String]);
    NSLog(@"path->%@",moviePath);
    //—-initialize compression engine
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath]
                                                        fileType:AVFileTypeQuickTimeMovie
                                                           error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error =%@", [error localizedDescription]);
    
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor
                                                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                    sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
        NSLog(@"11111");
    else
        NSLog(@"22222");
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while([writerInput isReadyForMoreMediaData])
        {
            if(++frame >= [imageArr count]*10)
            {
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                //              [videoWriterfinishWritingWithCompletionHandler:nil];
                break;
            }
            
            CVPixelBufferRef buffer =NULL;
            
            int idx =frame/10;
            NSLog(@"idx==%d",idx);
            
            buffer = [self pixelBufferFromCGImage:[[imageArr objectAtIndex:idx] CGImage] andImageSize:size];
            if (buffer)
            {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,10)])
                    NSLog(@"FAIL");
                else
                    NSLog(@"OK");
                CFRelease(buffer);
            }
        }
    }];
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)cgImage andImageSize:(CGSize)size
{
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer =NULL;
    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status ==kCVReturnSuccess && pxbuffer !=NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata !=NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(cgImage),CGImageGetHeight(cgImage)), cgImage);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}



////第二种方式
//- (void)writeImages:(NSArray *)images ArrayToMovieAtPath:(NSString *) path withSize:(CGSize) size
//         inDuration:(float)duration byFPS:(int32_t)fps{
//    //Wire the writer:
//    NSError *error =nil;
//    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:path]
//                                                        fileType:AVFileTypeQuickTimeMovie
//                                                           error:&error];
//    NSParameterAssert(videoWriter);
//    
//    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:
//                                  AVVideoCodecH264,AVVideoCodecKey,
//                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
//                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,
//                                  nil];
//    
//    AVAssetWriterInput* videoWriterInput =[AVAssetWriterInput
//                                           assetWriterInputWithMediaType:AVMediaTypeVideo
//                                           outputSettings:videoSettings];
//    
//    
//    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor
//                                                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
//                                                    sourcePixelBufferAttributes:nil];
//    NSParameterAssert(videoWriterInput);
//    NSParameterAssert([videoWritercanAddInput:videoWriterInput]);
//    [videoWriteraddInput:videoWriterInput];
//    
//    //Start a session:
//    [videoWriterstartWriting];
//    [videoWriterstartSessionAtSourceTime:kCMTimeZero];
//    
//    //Write some samples:
//    CVPixelBufferRef buffer =NULL;
//    
//    int frameCount =0;
//    
//    int imagesCount = [imagesArraycount];
//    float averageTime =duration/imagesCount;
//    int averageFrame =(int)(averageTime * fps);
//    
//    for(UIImage *img in imagesArray)
//    {
//        buffer=[selfpixelBufferFromCGImage:[imgCGImage]size:size];
//        BOOL append_ok =NO;
//        int j =0;
//        while (!append_ok&& j <</b> 30)
//        {
//            if(adaptor.assetWriterInput.readyForMoreMediaData)
//            {
//                printf("appending %d attemp%d\n", frameCount, j);
//                
//                CMTime frameTime =CMTimeMake(frameCount,(int32_t)fps);
//                floatframeSeconds =CMTimeGetSeconds(frameTime);
//                NSLog(@"frameCount:%d,kRecordingFPS:%d,frameSeconds:%f",frameCount,fps,frameSeconds);
//                append_ok = [adaptorappendPixelBuffer:bufferwithPresentationTime:frameTime];
//                
//                if(buffer)
//                    [NSThreadsleepForTimeInterval:0.05];
//            }
//            else
//            {
//                printf("adaptor not ready %d,%d\n", frameCount, j);
//                [NSThreadsleepForTimeInterval:0.1];
//            }
//            j++;
//        }
//        if (!append_ok){
//            printf("error appendingimage %d times %d\n", frameCount, j);
//        }
//        
//        frameCount = frameCount + averageFrame;
//    }
//    
//    //Finish the session:
//    [videoWriterInputmarkAsFinished];
//    [videoWriterfinishWriting];
//    NSLog(@"finishWriting");
//}
@end
