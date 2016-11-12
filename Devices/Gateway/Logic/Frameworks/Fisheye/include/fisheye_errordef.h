/*
 *******************************************************************************
 *  Copyright (c) 2010-2016 VATICS Inc. All rights reserved.
 *
 *  +-----------------------------------------------------------------+
 *  | THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED |
 *  | AND COPIED IN ACCORDANCE WITH THE TERMS AND CONDITIONS OF SUCH  |
 *  | A LICENSE AND WITH THE INCLUSION OF THE THIS COPY RIGHT NOTICE. |
 *  | THIS SOFTWARE OR ANY OTHER COPIES OF THIS SOFTWARE MAY NOT BE   |
 *  | PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY OTHER PERSON. THE   |
 *  | OWNERSHIP AND TITLE OF THIS SOFTWARE IS NOT TRANSFERRED.        |
 *  |                                                                 |
 *  | THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE WITHOUT   |
 *  | ANY PRIOR NOTICE AND SHOULD NOT BE CONSTRUED AS A COMMITMENT BY |
 *  | VATICS INC.                                                     |
 *  +-----------------------------------------------------------------+
 *
 *******************************************************************************
 */
#ifndef _FISHEYE_ERRORDEF_H_
#define _FISHEYE_ERRORDEF_H_

#include "errordef.h"

#define FISHEYE_E_FIRST 0x80060000
#define FISHEYE_E_LAST  0x800600FF

#define FISHEYE_S_OK						S_OK                

#define FISHEYE_E_FAIL					    S_FAIL              
#define FISHEYE_E_INVALID_HANDLE			ERR_INVALID_HANDLE	// 0x80000001
#define FISHEYE_E_OUT_OF_MEMORY			    ERR_OUT_OF_MEMORY	// 0x80000002
#define FISHEYE_E_INVALID_ARG				ERR_INVALID_ARG	    // 0x80000003
#define FISHEYE_E_NOT_IMPLEMENT             ERR_NOT_IMPLEMENT   // 0x80000004
#define FISHEYE_E_INVALID_VERSION			ERR_INVALID_VERSION // 0x80000005

#define FISHEYE_E_NOT_INITIALIZED_OPTION   	MAKE_SCODE (1, 6, FISHEYE_E_FIRST + 1) // 0x80060001
#define FISHEYE_E_WATERMARK_CHECK_FAIL      MAKE_SCODE (1, 6, FISHEYE_E_FIRST + 2) // 0x80060002
#define FISHEYE_E_NOT_SUPPORT_PTZ           MAKE_SCODE (1, 6, FISHEYE_E_FIRST + 3) // 0x80060003

#endif // _FISHEYE_ERRORDEF_H_
