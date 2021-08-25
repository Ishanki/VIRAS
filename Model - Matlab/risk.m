function R = risk(Ymuc,kmuc)
    
    R = 1-exp(-Ymuc./kmuc');
    
end