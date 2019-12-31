//
//  method.hpp
//  hello
//
//  Created by apple on 2019/9/17.
//

#ifndef method_hpp
#define method_hpp

#include "stdafx.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "optimization.h"
using namespace alglib;
void  function1_fvec(const real_1d_array &x, real_1d_array &fi, void *ptr);
float test();
void setpixels(float** pictures);
void setIndex(int t);
void setSize(int s);
void setTheta(float theta);
void setInter(float * intervals);
void setextrapixels(float** pic);
void setMode(int m);
void hello();
#endif /* method_hpp */
