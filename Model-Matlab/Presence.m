function x = Presence(t, Ns, tin, dur, epsilon)
    x = [ones(Ns,1);repmat(indicator_cont(t, tin, tin+dur, epsilon),2,1)];
end