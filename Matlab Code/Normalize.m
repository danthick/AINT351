function M = Normalize(M)
    M.meanVal(1) = mean(M.values(1,:));
    M.meanVal(2) = mean(M.values(2,:));
    M.stdVal(1) = std(M.values(1,:));
    M.stdVal(2) = std(M.values(2,:));
    M = M.normalize;
end