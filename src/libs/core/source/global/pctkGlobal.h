/***********************************************************************************************************************
**
** Library: UTK
**
** Copyright (C) 2023 ChengXueWen. Contact: 1398831004@qq.com
**
** License: MIT License
**
** Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
** documentation files (the "Software"), to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
** and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in all copies or substantial portions
** of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
** TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
** THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
** CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
** IN THE SOFTWARE.
**
***********************************************************************************************************************/

#ifndef _PCTKGLOBAL_H_
#define _PCTKGLOBAL_H_

#include <pctkMacros.h>
#include <pctkLimits.h>
#include <pctkSystem.h>
#include <pctkCompiler.h>
#include <pctkCoreConfig.h>
#include <pctkPreprocessor.h>

/**
 * @addtogroup core
 *  pctk_core is the core library of the PCTK library and contains containers,
 *  multithreading, text, objects, event loops and platform definitions.
 *
 */


/********************************************************************************
   PCTK Compiler specific cmds for export and import code to DLL
********************************************************************************/
#ifdef PCTK_SHARED /* compiled as a dynamic lib. */
#   ifdef PCTK_BUILD_CORE_LIB    /* defined if we are building the lib */
#       define PCTK_CORE_API PCTK_DECL_EXPORT
#   else
#       define PCTK_CORE_API PCTK_DECL_IMPORT
#   endif
#   define PCTK_CORE_HIDDEN PCTK_DECL_HIDDEN
#else /* compiled as a static lib. */
#   define PCTK_CORE_API
#   define PCTK_CORE_HIDDEN
#endif

#define PCTK_CORE_NAME "PCTKCore"

#endif //_PCTKGLOBAL_H_
