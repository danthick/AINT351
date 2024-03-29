% This function is used to carry out a feedforward pass of the network
% given its input data and both weight matrices.
function output = FeedForward(input, W1, W2)
    % Add bias to input matrix
    input = [input; 1];
    % Calculate output from hidden layer
    net = W1*input;
    % Sigmoid activation function
    a2 = SigmoidFunction(net);
    % Adding bias to activation from hidden layer
    a2hat = [a2; 1];
    % Calculating output from output layer
    output = W2*a2hat;
end