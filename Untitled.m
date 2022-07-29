%findefm
[dumm,efms_n] = size(res.efms);
for found = 1:efms_n
    if find(res.efms(4,:)) == [1 2 3 4 5 8 10 12 13 17 18 20 21 22 23 26 28]
        break;
    end
end
