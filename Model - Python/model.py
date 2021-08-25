#import Rates as R
import numpy as np
import math as mth

def Presence(t,Ns,tin,dur,epsilon):
    xpres = np.concatenate((np.ones([1,Ns]),np.tile(indicator_cont(t, tin, tin+dur, epsilon),[1,2])),axis=1)
    xpres=xpres.T
    return xpres
 
def indicator_cont(xic, a, b, eps):
    # Continuous indicator function of interval [a, b]. As it has a trapezoidal
    # shape beginning to rise linearly at x = a, the decreasing part part
    # starts at x = b dropping to zero at x = b + eps to ensure that the
    # integral of the function = (b-a).
    return heaviside_right(xic-a, eps)*heaviside_right(b+eps-xic, eps)

def heaviside_right(xheav, eps):
    # Approximation of the Heaviside step function defined as:
    #       |0,      t < 0
    #   h = |x/eps,  0 <= t <= eps
    #       |1,      t > eps
    # The approximation is deliberately made non-symmetrical w.r.t. 0 to enable
    # starting from zero time
    return heavisidecustom(xheav)*heavisidecustom(eps - xheav)*xheav/eps + heavisidecustom(xheav - eps)

def heavisidecustom(t):
    xc = np.zeros(np.shape(t))
    xc[t>0]  = 1
    xc[t==0] = 0.5
    return xc
 
def risk(Ymuc,kmuc):
    RoI = 1-np.exp(-Ymuc/kmuc)
    return RoI

def initcond(V0_obj,V0_air,V0m,Inf,NoInd,NoObj,Rhs,Rsh,Rhm,Rmh,fmh,Acon,fobj,Aobj,Amh,Ah,Am,CloseTime,CloseTransfer,tauh,FomitPath,ClosePath,AerosPath,InactPath,Ldropl,Rshed):
    # Initial conditions
    V0_obj = V0_obj
    
    # Mucous membrane Version 1
    # V0_mucos = 5.*params.k.*params.Inf;
    
    # Mucous membrane Version 2
    V0_mucosa = V0m*Inf
    
    # Hands Version 1
    # V0_hands = 961500*Inf
    
    # Hands Version 2
    # V0_hands = np.zeros(NoInd,1)
    
    # Hands Version 3
    tofomites = np.sum(Rhs.T*Acon.T*fobj)/Ah
    fromfomites = np.sum(Rsh.T*Acon.T*fobj*V0_obj.T/Aobj.T,0)
    tomucosa = Rhm*fmh*Amh/Ah;
    frommucosa = Rmh*fmh*Amh*V0_mucosa/Am
    closecon = np.sum(np.eye(NoInd)*CloseTime[NoObj:NoObj+NoInd,:]*CloseTransfer[NoObj:NoObj+NoInd,:]*Ldropl*Rshed,1)
    aerosol = 0
    inact = mth.log(2)/tauh
    
    # V0_hands = [Inf* (1*frommucosa + FomitPath*fromfomites + ClosePath*closecon + AerosPath*aerosol) 
    # / (1*tomucosa + FomitPath*tofomites + InactPath*inact )]
    
    # Individuals do not interact with anything apart from their own hands before entering the setting
        
    closecon = closecon
    frommucosa = frommucosa
    tomucosa = tomucosa
    inact = inact

    V0_hands = (Inf* (1*frommucosa + ClosePath*closecon)
    			/ (1*tomucosa + InactPath*inact ))
    
    # Initial conditions (shm,air,acc_fomites,acc_closecon,acc_aerosol,acc_total,risk)
    V0_air = V0_air
    
    V0 = np.concatenate((V0_obj,V0_hands,V0_mucosa,V0_air,V0_mucosa,V0_mucosa,V0_mucosa,V0_mucosa),axis=1).T

    V0 = np.squeeze(V0,1)

    return V0

def model(V0,t,NoInd,psi,I,Rcontto,Rcontfrom,Rinact,Rclean,Raerogen,Rsmall,Rlarge,Rref,Rinh):
    V0shm = np.expand_dims(V0,2)
    Iair = np.shape(I(t))
    V0air = V0shm[Iair[0],:]
    V0shm = V0shm[:Iair[0],:]

    # Model - surfaces,hands,mucosas
    dVshmdt_plus = Rcontto(V0shm,I(t)) + Rsmall(V0air) + Rlarge(I(t)*Raerogen)
    dVshmdt_minus = Rcontfrom(V0shm,I(t)) + Raerogen + Rinact[0,:-1]*V0shm + Rclean(t,V0shm)    
    dVshmdt = (dVshmdt_plus - dVshmdt_minus)*I(t)*(1-psi)
    
    # Model - air
    dVairdt_plus = np.dot(np.ones(np.shape(V0shm.T)),I(t)*Raerogen)
    dVairdt_minus = np.dot(np.ones(np.shape(V0shm.T)),Rsmall(V0air)) + Rref(V0air) + Rinact[0,-1]*V0air
    dVairdt = dVairdt_plus - dVairdt_minus;
    
    
    # Model - accumulated mechanisms
    dVshmdt_fomites_plus  = Rcontto(V0shm,I(t))*I(t)*(1-psi)
    dVshmdt_closecon_plus = (Rlarge(I(t)*Raerogen))*I(t)*(1-psi)
    dVshmdt_aerosol_plus  = (Rinh(V0air) + Rsmall(V0air))*I(t)*(1-psi)
    
    # Model - infection risk
    dVshmdt_acc = dVshmdt_fomites_plus + dVshmdt_closecon_plus + dVshmdt_aerosol_plus; # viral exposure
    
    # Output vector  
    dVdt = np.concatenate([dVshmdt,dVairdt,dVshmdt_fomites_plus[-NoInd:,:],dVshmdt_closecon_plus[-NoInd:,:],dVshmdt_aerosol_plus[-NoInd:,:],dVshmdt_acc[-NoInd:,:]],axis=0)
    dVdt = np.squeeze(dVdt,1)

    return dVdt