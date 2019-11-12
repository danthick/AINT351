classdef Data
    %DATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        values
        meanVal
        stdVal
    end
    
    methods        
        function result = normalize(obj, M)                
            for k = 1:2
                P2(k,:) = P2(k,:) - mean(P2(k,:));
                P2(k,:) = P2(k,:)./std(P2(k,:));
                %P2(k,:) = (P2(k,:) - min(P2(k,:))) ./ max(P2(k,:) - min(P2(k,:)));
            end
        end
        
        function result = ReverseNormalize(M)
            for k = 1:2
                M(k,:) = M.stdVal(k) * M(k,:);
                M(k,:) = M(k,:) + M.meanVal(k);
            end
        end
    end
end

