function hpfilter(y, w)
        t = size(y)[1]
        Q = zeros(t, t+2)
        H = zeros(t, t+2)
        for i in 1:t
                global
                Q[i, i] = 1
                Q[i, i+1] = -2
                Q[i, i+2] = 1
                H[i,i] = 1
        end
        output = (H'H + w * Q'Q)^(-1)*H'y
        output[1:t]
end
