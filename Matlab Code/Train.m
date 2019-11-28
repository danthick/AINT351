% Function to train the network given input data, target data and the weight
% matrix. By calculating the error gradient and updating the weight values.
function [W1, W2, err] = Train(input, target, W1, W2)
    % Setting learning rate    
    learningRate = 0.01;
    
    % FEEDFORWARD PASS
    % Calculate output from hidden layer and add bias
    input = [input; 1];
    net = W1*input;
    % Sigmoid activation function
    a2 = SigmoidFunction(net);
    % Adding bias to activation from hidden layer
    a2hat = [a2; 1];
    % Calculating output from output layer
    o = W2*a2hat;
    
    % BACKPROPAGATION
    % Delta 3 is equal to the output error
    delta3 = -(target-o);
    
    % Removing bias from weights
    for i = 1:size(W2,2)-1
        W2Hat(1,i) = W2(1,i);
        W2Hat(2,i) = W2(2,i);
    end
    
    % Delta 2 is equal to the error from the second layer multiplied by a
    % scaling factor due to the sigmoid function
    delta2 = (W2Hat'*delta3).*a2.*(1-a2);

    % Calculating the error gradient
    errGradientW1 = delta2*input';
    errGradientW2 = delta3*a2hat';
    
    
    err = mean((target - o).^2);
    
    
    % Updating weights using the learning rate and error gradient
    W1 = W1 - learningRate*errGradientW1;
    W2 = W2 - learningRate*errGradientW2;
end