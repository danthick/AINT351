% Function to carry out the sigmoid acivation calculation
function result = SigmoidFunction(net)
    result = 1 ./ (1+(exp(-net)));
end