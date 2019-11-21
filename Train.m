function [W1, W2] = Train(input, target, W1, W2)
    % Calculate output from hidden layer and add bias
    input = [input; 1];
    net = W1*input;
    % Sigmoid activation function
    a2 = SigmoidFunction(net);
    % Adding bias to activation from hidden layer
    a2hat = [a2; 1];
    % Calculating output from output layer
    o = W2*a2hat;

    delta3 = -(target-o);
    W2Hat = [W2(1,1), W2(1,2), W2(1,3), W2(1,4), W2(1,5), W2(1,6), W2(1,7), W2(1,8); W2(2,1), W2(2,2), W2(2,3), W2(2,4), W2(2,5), W2(2,6), W2(2,7), W2(2,8)];
    delta2 = (W2Hat'*delta3).*a2.*(1-a2);

    errGradientW1 = delta2*input';
    errGradientW2 = delta3*a2hat';

    W1 = W1 - 0.01*errGradientW1;
    W2 = W2 - 0.01*errGradientW2;
    
end