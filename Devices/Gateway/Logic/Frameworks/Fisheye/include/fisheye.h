#if !defined( __LIBFISHEYE_H__ )
#define __LIBFISHEYE_H__

#ifdef __cplusplus
extern "C" {
#endif

#ifndef MAKEFOURCC
    #define MAKEFOURCC(ch0, ch1, ch2, ch3)                          \
                ((DWORD)(BYTE)(ch0) | ((DWORD)(BYTE)(ch1) << 8) |   \
                ((DWORD)(BYTE)(ch2) << 16) | ((DWORD)(BYTE)(ch3) << 24 ))
#endif //defined(MAKEFOURCC)


#define LIBFISHEYE_VERSION MAKEFOURCC('3', '1', '1', '12')

#ifndef DLLAPI
#ifdef _WIN32
#ifdef _USRDLL
#define DLLAPI __declspec(dllexport) __stdcall
#else
#define DLLAPI __stdcall
#endif //defined(_USRDLL)
#else
#define DLLAPI
#endif //defined(_WIN32)
#endif //defined(DLLAPI)

#include "typedef.h"

typedef enum _FisheyeVPixelFormat
{
	FE_PIXELFORMAT_YUV420P,  // YUV420 planar
	FE_PIXELFORMAT_RGB32     // RGBA interleaved
}FEVPIXELFORMAT;

typedef enum _FisheyeMountType
{
	FE_MOUNT_WALL,     // Wall
	FE_MOUNT_CEILING,  // Ceiling 
	FE_MOUNT_FLOOR     // Floor
}FEMOUNTTYPE;

typedef enum _FisheyeDewarpType
{
	FE_DEWARP_RECTILINEAR,       // Rectilinear
	FE_DEWARP_FULLVIEWPANORAMA,  // Full-view panorama
	FE_DEWARP_DUALVIEWPANORAMA,  // Dual-view panorama (which is only available in FE_MOUNT_CEILING and FE_MOUNT_CEILING type)
	FE_DEWARP_CLIPVIEWPANORAMA,  // Full-HD panorama
	FE_DEWARP_AERIALVIEW,		 // Aerial view
	FE_DEWARP_TENSIVEVIEW,		 // Tensive view
	FE_DEWARP_AROUNDVIEW,		 // Around view (Panorama to Rectilinear)
	FE_DEWARP_PLANETVIEW,		 // Planet view (Panorama720 to Planet view)
	FE_DEWARP_MARBLEVIEW,		 // Marble view (Panorama720 to Marble view)
	FE_DEWARP_BOWLERVIEW,		 // Bowler view
	FE_DEWARP_PILLARVIEW,		 // Pillar view
}FEDEWARPTYPE;

typedef enum _FisheyeOptionFlag
{
	FE_OPTION_INIMAGEHEADER		= (1 << 0),   // Input image header
	FE_OPTION_INIMAGEBUFFER		= (1 << 1),   // Input image buffer
	FE_OPTION_OUTIMAGEHEADER	= (1 << 2),   // Output image header
	FE_OPTION_OUTIMAGEBUFFER	= (1 << 3),   // Output image buffer
	FE_OPTION_FOVCENTER			= (1 << 4),   // FOV's center
	FE_OPTION_FOVRADIUS			= (1 << 5),   // FOV's radius
	FE_OPTION_MOUNTTYPE			= (1 << 6),   // Mount type (which is one of the FEMOUNTTYPE)
	FE_OPTION_DEWARPTYPE		= (1 << 7),   // Dewarp type (which is one of the FEDEWARPTYPE)
	FE_OPTION_OUTROI			= (1 << 8),   // Ouput ROI
}FEOPTIONFLAG;

typedef enum _FisheyePTZPositionFlag
{
	FE_POSITION_ABSOLUTE,   // Absolute position
	FE_POSITION_RELATIVE,   // Relative position
}FEPTZPOSITIONFLAG;

typedef enum _FisheyeInImageType
{
	FE_IMAGE_ORIGINAL,   // Original fisheye image
	FE_IMAGE_PANORAMA,   // Panorama image (dewarped fisheye image)
}FEINIMAGETYPE;

typedef struct _FisheyePoint
{
	int X;  // X
	int Y;  // Y
}FEPOINT;

typedef struct _FisheyeRect
{
	int Left;    // Left
	int Top;     // Top
	int Right;   // Right
	int Bottom;  // Bottom
}FERECT;

typedef struct _FisheyeVPicture
{
	/* Header field */
	unsigned int   Width;    // Width
	unsigned int   Height;   // Height
	unsigned int   Stride;   // Stride
	FEVPIXELFORMAT Format;   // Pixel format (which is one of the FEVPIXELFORMAT)

	/* Buffer field */
	BYTE           *Buffer;  // Buffer
}FEVPICTURE;

typedef struct _FisheyeOption
{
	DWORD        Flags;        // Option flags (which is the combination of one or more flags in FEOPTIONFLAG)
	FEVPICTURE   InVPicture;   // Input picture
	FEVPICTURE   OutVPicture;  // Output picture
	FEPOINT      FOVCenter;    // FOV's center
	unsigned int FOVRadius;    // FOV's radius
	FEMOUNTTYPE  MountType;    // Mount type 
	FEDEWARPTYPE DewarpType;   // Dewarp type
	FERECT       OutRoi;       // Output ROI
}FEOPTION;

/* Initial the fisheye dewarp module */
SCODE DLLAPI Fisheye_Initial(HANDLE *phObject, DWORD dwVersion);

/* Release the fisheye dewarp module */
SCODE DLLAPI Fisheye_Release(HANDLE *phObject);

/* Dewarp the fisheye frame */
SCODE DLLAPI Fisheye_OneFrame(HANDLE hObject);

/* Change the settings in fisheye dewarp module */
SCODE DLLAPI Fisheye_SetOption(HANDLE hObject, FEOPTION *pOption);

/* Set customized fisheye lens distortion table */
SCODE DLLAPI Fisheye_SetLensDistortionTable(HANDLE hObject, const double* pTable, unsigned int Count, double AngleStep);

/* Set input image type */
SCODE DLLAPI Fisheye_SetInImageType(HANDLE hObject, FEINIMAGETYPE InImageType);

/* Set Pan, Tilt and Zoom. (This API uses to replace obsolete options setup.) */
SCODE DLLAPI Fisheye_SetPanTiltZoom(HANDLE hObject, FEPTZPOSITIONFLAG Flag, float Pan, float Tilt, float Zoom);

/* Get Pan, Tilt and Zoom. */
SCODE DLLAPI Fisheye_GetPanTiltZoom(HANDLE hObject, float* pPan, float* pTilt, float* pZoom);

/* Get current pan and tilt boundary*/
SCODE DLLAPI Fisheye_GetCurrentPanBoundary(HANDLE hObject, float* pMinPan, float* pMaxPan);
SCODE DLLAPI Fisheye_GetCurrentTiltBoundary(HANDLE hObject, float* pMinTilt, float* pMaxTilt);

/* The following APIs are some mapping methods between fisheye source image and rectilinear dewarped image					  */
/* Get Pan/Tilt according to the fisheye source point(x,y) in InVPicture (x : 0 ~ InVPicture.Width, y: 0 ~ InVPicture.Height) */
SCODE DLLAPI Fisheye_InVPicturePointToPanTilt(HANDLE hObject, int X, int Y, float *pPan, float *pTilt);

/* Get the fisheye source point(x,y) according to Pan/Tilt (x : 0 ~ InVPicture.Width, y: 0 ~ InVPicture.Height) */
SCODE DLLAPI Fisheye_PanTiltToInVPicturePoint(HANDLE hObject, float Pan, float Tilt, int* pX, int* pY);

/* Get Pan/Tilt/Zoom according to the fisheye source polygon region(X0,Y0)~(Xn,Yn)  in InVPicture (x : 0 ~ InVPicture.Width, y: 0 ~ InVPicture.Height) */
SCODE DLLAPI Fisheye_InVPicturePolygonToPanTiltZoom(HANDLE hObject, unsigned int Count, FEPOINT* pPolygon, float *pPan, float *pTilt, float *pZoom);

/* Get the fisheye source point(x,y) according to OutRoi point(x, y)											*/
/* (Xo : 0 ~ OutRoi Width, Yo: 0 ~ OutRoi Height)																*/
/* (Xi : 0 ~ InVPicture.Width, Yi: 0 ~ InVPicture.Height)														*/
SCODE DLLAPI Fisheye_OutRoiPointToInVPicturePoint(HANDLE hObject, int Xo, int Yo, int* pXi, int* pYi);

#ifdef __cplusplus
}
#endif

#endif  // __LIBFISHEYE_H__