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
#ifndef _FISHEYE_OPENGL_ERRORDEF_H_
#define _FISHEYE_OPENGL_ERRORDEF_H_

#include "fisheye_errordef.h"

#define FISHEYEGL_E_FIRST 0x80070000
#define FISHEYEGL_E_LAST  0x800700FF

// OpenGL Error
#define FISHEYE_E_OPENGL_NOT_SUPPORT	    MAKE_SCODE (1, 6, FISHEYEGL_E_FIRST + 1)
#define FISHEYE_E_OPENGL_FAIL	            MAKE_SCODE (1, 6, FISHEYEGL_E_FIRST + 2)
#define FISHEYE_E_OPENGL_SHADER_FAIL		MAKE_SCODE (1, 6, FISHEYEGL_E_FIRST + 3)

#endif // _FISHEYE_OPENGL_ERRORDEF_H_
