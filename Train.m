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
    
    for i = 1:size(W2,2)-1
        W2Hat(1,i) = W2(1,i);
        W2Hat(2,i) = W2(2,i);
    end
    
    delta2 = (W2Hat'*delta3).*a2.*(1-a2);

    errGradientW1 = delta2*input';
    errGradientW2 = delta3*a2hat';

    W1 = W1 - 0.01*errGradientW1;
    W2 = W2 - 0.01*errGradientW2;
end