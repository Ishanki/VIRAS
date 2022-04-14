function r = SmallDropletsRate(Vair, Rd, A, Vol_air)
    r = Rd.*A*Vair/Vol_air;
end