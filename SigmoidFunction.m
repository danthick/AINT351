% Sigmoid Function
function result = SigmoidFunction(net)
    result = 1 ./ (1+(exp(-net)));
end