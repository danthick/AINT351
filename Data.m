classdef Data
    %DATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        values
        meanVal
        stdVal
    end
    
    methods        
        function M = normalize(obj)                
            for k = 1:size(obj.values)
                obj.values(k,:) = obj.values(k,:) - mean(obj.values(k,:));
                obj.values(k,:) = obj.values(k,:)./std(obj.values(k,:));
            end
            M = obj;
        end
        
        function M = reverseNormalize(obj)
            for k = 1:size(obj.values)
                obj.values(k,:) = obj.stdVal(k) .* obj.values(k,:);
                obj.values(k,:) = obj.values(k,:) + obj.meanVal(k);
            end
            M = obj;
        end
    end
end

