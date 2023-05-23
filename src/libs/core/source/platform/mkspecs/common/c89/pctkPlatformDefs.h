/*****************************************************************************************************************************
**
** Library: PCTK
**
** Copyright (C) 2022 ChengXueWen. Contact: 1398831004@qq.com
**
** License: MIT License
**
** Permission is hereby granted, free of charge, to any person obtaining
** a copy of this software and associated documentation files (the "Software"),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense,
** and/or sell copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
** SOFTWARE.
**
*************************************************************************************/

#ifndef _PCTK_C89_PLATFORM_DEFS_H
#define _PCTK_C89_PLATFORM_DEFS_H

#include <stdio.h>

#define PCTK_FPOS_T               fpos_t
#define PCTK_OFF_T                long

#define PCTK_FOPEN                ::fopen
#define PCTK_FSEEK                ::fseek
#define PCTK_FTELL                ::ftell
#define PCTK_FGETPOS              ::fgetpos
#define PCTK_FSETPOS              ::fsetpos

#endif /* _PCTK_C89_PLATFORM_DEFS_H */
