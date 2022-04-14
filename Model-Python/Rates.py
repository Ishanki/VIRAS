import numpy as np 
import math as mth

def AerosolGenRate(Ns,Np,Ra,Ldropl):
    r = np.zeros([Ns+2*Np,1])
    r[Ns+Np:Ns+2*Np+1,0] = (1-Ldropl)*Ra
    #r = r.T
    return r

def AirRefreshRate(V, Rref, Vair):
    r = Rref*V/Vair
    return r

def CleanRate(t, V, NoObj, NoInd, tsim, Tc, Tch, LRV, LRVh, Ceff, Ceffh, epsilon):
    # Disinfection settings
    CT = (tsim+1)+np.zeros([NoObj+NoInd,max(Tc.shape[1],Tch.shape[1])])
    CT[0:NoObj,0:Tc.shape[1]] = Tc
    CT[NoObj:NoObj+NoInd,0:Tch.shape[1]] = Tch
    CT = np.where(np.isnan(CT), tsim+1, CT)
   
    # Log reduction values for cleaning/hand washing:
    LRVeff = np.concatenate([Ceff*LRV,Ceffh*LRVh],axis=1).T
    
    r = np.zeros([NoObj+2*NoInd,1])
    for k in range(0,NoObj+NoInd):
        for m in range(0,CT.shape[1]):
            r[k,0] = r[k,0] + LRVeff[k,0]  *  mth.log(10)  *  V[k,0]  *  delta_triang(t-CT[k,m], epsilon[0,0])  
    return r

def delta_triang(x, eps):
    #print(np.absolute(x))
    if abs(x) <= eps:
        d = (1 - abs(x)/eps)/eps
    else:
        d = 0
    return d

def ContactFromRate(V0,I,NoObj,NoInd,Aobj,Ah,Am,Acon,Amh,Rhs,Rsh,Rhm,Rmh,fobj,fmh):
    # Vector of inverses of all surface areas: surfaces, hands, mucous membranes
    A = np.concatenate((Aobj,Ah,Am),axis=1).T

    # Form transfer matrices:
    M_hs = Rhs*fobj.T*Acon
    M_sh = Rsh.T*fobj*Acon.T
    
    M_hm = np.tile(Rhm*fmh*Amh,[NoInd,1])*np.eye(NoInd)
    M_mh = np.tile(Rmh*fmh*Amh,[NoInd,1])*np.eye(NoInd)
    
    M1 = np.concatenate([np.zeros([NoObj,NoObj]), M_sh, np.zeros([NoObj, NoInd])],axis=1)
    M2 = np.concatenate([M_hs, np.zeros([NoInd,NoInd]), M_hm],axis=1)
    M3 = np.concatenate([np.zeros([NoInd,NoObj]),  M_mh,           np.zeros([NoInd,NoInd])],axis=1)
    M  = np.concatenate([M1,M2,M3],axis=0)
    
    r = np.dot(M,I)*(V0/A)
    return r

def ContactToRate(V0,I,NoObj,NoInd,Aobj,Ah,Am,Acon,Amh,Rhs,Rsh,Rhm,Rmh,fobj,fmh):
    # Vector of inverses of all surface areas: surfaces, hands, mucous membranes
    A = np.concatenate((Aobj,Ah,Am),axis=1).T

    # Form transfer matrices:
    M_hs = Rhs*fobj.T*Acon
    M_sh = Rsh.T*fobj*Acon.T
    
    M_hm = np.tile(Rhm*fmh*Amh,[NoInd,1])*np.eye(NoInd)
    M_mh = np.tile(Rmh*fmh*Amh,[NoInd,1])*np.eye(NoInd)
    
    M1 = np.concatenate([np.zeros([NoObj,NoObj]), M_sh, np.zeros([NoObj, NoInd])],axis=1)
    M2 = np.concatenate([M_hs, np.zeros([NoInd,NoInd]), M_hm],axis=1)
    M3 = np.concatenate([np.zeros([NoInd,NoObj]),  M_mh,           np.zeros([NoInd,NoInd])],axis=1)
    M  = np.concatenate([M1,M2,M3],axis=0)

    r = np.dot(np.transpose(M),(I*V0/A))
    return r

def InhalationRate(V, Ns, Np, Rinh,Vair):
    Rinhmat = np.zeros([Ns+2*Np,1])
    Rinhmat[-Np:,0] = Rinh
    r = Rinhmat*V/Vair
    return r

def LargeDropletsRate(Rexhale, Ns, Np, CloseRate, CloseTime, Ldropl):
    MatExhale = Rexhale[-Np:,0]/(1-Ldropl) # Rexhale argument refers to small droplets (AerosolGenRate)
    PrcLarge = Ldropl*np.ones([Ns+2*Np,Np])
    r = np.dot((PrcLarge*CloseRate*CloseTime),MatExhale.T)
    return r

def SmallDropletsRate(Vair, Rd, A, Vol_air):
    r = Rd*A*Vair/Vol_air
    r = r.T
    return r

