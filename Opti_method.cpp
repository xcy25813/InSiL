//
//  method.cpp
//  hello
//
//  Created by apple on 2019/9/17.
//

#include "method.hpp"
#include<math.h>
using namespace alglib;
float ** pic;
int dex;
float *intervals;
int size;
float th;
int mode=0;
float ** pic1;
void setpixels(float** pictures){
    pic=pictures;
}
float** getpixels(){
    return pic;
}
void setextrapixels(float** pic){
    pic1=pic;
}
float** getextrapixels(){
    return pic1;
}

void setIndex(int t){
    dex=t;
}
int getIndex(){
    return dex;
}
void setMode(int m){
    mode=m;
}
int getMode(){
    return mode;
}
void setTheta(float theta){
    th=theta;
}
int getTheta(){
    return th;
}
void setSize(int s){
    size=s;
}
int getSize(){
    return size;
}

void setInter(float * in){
    intervals=in;
}
float* getInter(){
    return intervals;
}
void hello(){
    printf("Hello!");
}
void  function1_fvec(const real_1d_array &x, real_1d_array &fi, void *ptr)
{
    //
    // this callback calculates
    // f0(x0,x1) = 100*(x0+3)^4,
    // f1(x0,x1) = (x1-3)^4
    //
    /*
    float intervals[13];
    intervals[0]=100;
    intervals[1]=1343.750000;
    intervals[2]=1328.125000;
    intervals[3]=1343.750000;
    intervals[4]=1328.125000;
    intervals[5]=5218.437500;
    intervals[6]=180.000000;
    intervals[7]=1351.562500;
    intervals[8]=1351.562500;
    intervals[9]=5208.750000;
    intervals[10]=260.000000;
    intervals[11]=1375.000000;
    intervals[12]=1375.000000;
   */
        int  count=0;
        int res_point=0;
        float res=0;
        int m0=1;
        float mall_before=13;
        int schemes[3]={5,3,3};
    
        float theta=th;
        mall_before=-1*theta*m0;
    int P=3;
    if(size==11){
        P=3;
    }
    else{
        P=2;
    }
    
    int N=0;
    //printf("%f",intervals[12]);
    
    for(int i=0;i<P;i++){
        N=N+schemes[i];
    }
    float Dic[size];
        for(int q=0;q<P;q++){
            int t=count;
            for (int r=t;r<t+schemes[q];r++){
                
                res=(m0+(mall_before-m0)*exp(-(intervals[r]/x[0])));
                
                mall_before=(1-x[1])*res;
                if(mode==0){
                if(res<0){
                    Dic[res_point]=-res;
                }else{
                    Dic[res_point]=res;
                }
                }
                else{
                    Dic[res_point]=res;
                }
                
                res_point++;
                count=count+1;
            }
            if(count<P+N-1){
                m0=(m0+(mall_before-m0)*exp(-(intervals[count])/x[0]));
                mall_before=(-1*theta)*m0;
                count=count+1;
            }
        }
    int i=getIndex();
    float* *pictures=getpixels();
    float* *pictures1=getextrapixels();
    float pixels[size];
    for (int j=0;j<size;j++){
        pixels[j]=pictures[j][i];
        //NSLog(@"pixel:%f",pixels[j]);
        int sign=1;
        if(mode==1){
        if(cos (( pictures1[j][i]-pictures1[4][i]) /4096*acos(-1))<0){
          sign=-1;
        }
        }
        pixels[j]=sign*pixels[j];
        //NSLog(@"pixelNo.%d: %f",j,pixels[j]);
    }
    
    //遍历dictionary
    
            
            //求m0;
            float sum1=0;
            float sum2=0;
            for(int x=0;x<N;x++){
                sum1=sum1+Dic[x]*pixels[x];
                
                sum2=sum2+Dic[x]*Dic[x];
            }
            
            m0=sum1/sum2;
            //NSLog(@"T1:%d",T[m]);
            //NSLog(@"c:%f",C[n]);
            //NSLog(@"optimzed m0: %f",m0);
            
            
            float cost;
            cost=0;
            for(int x=0;x<N;x++){
                //NSLog(@"predict:%f,actual:%f",Dic[m][n][x]*m0,pixels[x]);
                cost=cost+(Dic[x]*m0-pixels[x])*(Dic[x]*m0-pixels[x]);
                
            }
    
    
    fi[0] = sqrt(cost);
    //fi[1] = pow(x[1]-3,2);
}

float test()
{
    //
    // This example demonstrates minimization of F(x0,x1) = f0^2+f1^2, where
    //
    //     f0(x0,x1) = 10*(x0+3)^2
    //     f1(x0,x1) = (x1-3)^2
    //
    // using "V" mode of the Levenberg-Marquardt optimizer.
    //
    // Optimization algorithm uses:
    // * function vector f[] = {f1,f2}
    //
    // No other information (Jacobian, gradient, etc.) is needed.
    //
    real_1d_array x = "[1300,0.25]";
    real_1d_array s = "[1300,0.25]";
    real_1d_array bndl = "[200,0]";
    real_1d_array bndu = "[2000,0.5]";
    double epsx = 0.0000000001;
    ae_int_t maxits = 0;
    minlmstate state;
    
    //
    // Create optimizer, tell it to:
    // * use numerical differentiation with step equal to 1.0
    // * use unit scale for all variables (s is a unit vector)
    // * stop after short enough step (less than epsx)
    // * set box constraints
    //
    minlmcreatev(2, x, 0.0001, state);
    minlmsetbc(state, bndl, bndu);
    minlmsetcond(state, NULL,NULL,epsx, maxits);
    minlmsetscale(state, s);
    
    //
    // Optimize
    //
    alglib::minlmoptimize(state, function1_fvec);
    
    //
    // Test optimization results
    //
    // NOTE: because we use numerical differentiation, we do not
    //       verify Jacobian correctness - it is always "correct".
    //       However, if you switch to analytic gradient, consider
    //       checking it with OptGuard (see other examples).
    //
    minlmreport rep;
    minlmresults(state, x, rep);
    printf("%s\n", x.tostring(2).c_str()); // EXPECTED: [-1,+1]
    return x[0];
}
