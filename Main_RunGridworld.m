%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all rights reserved
% Author: Dr. Ian Howard
% Associate Professor (Senior Lecturer) in Computational Neuroscience
% Centre for Robotics and Neural Systems
% Plymouth University
% A324 Portland Square
% PL4 8AA
% Plymouth, Devon, UK
% howardlab.com
% 22/09/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run maze experiments
% you need to expand this script to run the assignment
close all
clear all
clc

            % Defining variables
            armLength = [0.4;0.4];
            baseOrigin = [0, 0];
            samples = 1000;
            noOfInputs = 3;
            noOfHiddenNodes = 7;
            noOfOutputNodes = 2;

            % Generating 2 x samples data between 0 - pi
            angles = pi * rand(2,samples);
            % Calculating arm end points given angles
            [P1, P2] = RevoluteForwardKinematics2D(armLength, angles, baseOrigin);

            X = Data;
            X.values = P2;
            X = normalize(X);

            
            Network.W1 = rand(noOfHiddenNodes, noOfInputs);
            Network.W2 = rand(noOfOutputNodes, noOfHiddenNodes + 1);

%             for i = 1:1000
%                 for j = 1:samples
%                     Network.train(X.values(:,j), angles(:,j));
%                 end 
%             end

            out = Data;
            out.values = rand(2,samples);
            out.values = X.values;
            out = normalize(out);
            Xrand  = out.values;
            for i = 1:samples
                o = Network.feedForward(Xrand(:,i));
                out.values(1,i) = o(1,1);
                out.values(2,i) = o(2,1);
            end
            out = Network.reverseNormalize(out);
            X = Network.reverseNormalize(X);

            out.values(:,1)
            X.values(:,1)

            [P3, P4] = RevoluteForwardKinematics2D(armLength, out.values, baseOrigin);

            figure
            hold on
            tiledlayout(2,2)
            nexttile
            plot(X.values(1,:), X.values(2,:), 'b.');
            nexttile
            plot(angles(1,:), angles(2,:), 'b.');
            nexttile
            plot(out.values(1,:), out.values(2,:), 'r.');
            nexttile
            plot(P4(1,:), P4(2,:), 'r.', 'markersize',4);





Network.start();
output = feedForward([1 1]);

% Limit values of maze
limits = [0 1; 0 1;];

% Build the maze
maze = CMazeMaze10x10(limits);

% Intialise QValues
minVal = 0.01;
maxVal = 0.1;
maze = maze.InitQTable(minVal, maxVal);
    
% Build the transition matrix
maze = maze.BuildTransitionMatrix();

% Plotting histogram for random starting states
for i = 1:1000
    starting(i) = maze.RandomStartingState();
end
figure
hold on
histogram(starting, 100);

% Defining the number of episodes and trials
episodes = 1000;
trials = 100;

% Storing returned values
[maze, steps] = Trial(maze, episodes);
[meanVal, stdVal, coordinates] = Experiment(maze, episodes, trials);

% Drawing the maze and plotting the route to termination state
maze.DrawMaze();
line(coordinates(:,1)./10 - 0.05, coordinates(:,2)./10 - 0.05, 'Marker', 'x', 'MarkerEdgeColor', 'm','MarkerFaceColor', [1, 0, 1], 'MarkerSize', 20, 'LineWidth', 5);

% Plotting the number of steps against the trial
% figure
% hold on
% plot(steps);

% Plotting the mean and standard deviation on an error bar
% figure
% hold on
% errorbar(meanVal, stdVal);

% Calculates mean and std and runs the number of trials
function [meanVal, stdVal, coordinates] = Experiment(maze, episodes, trials)
    % Loops through number of trials
    for i = 1:trials
        [maze, stepsAcrossTrials(i, :)] = Trial(maze, episodes);
    end
    meanVal = mean(stepsAcrossTrials);
    stdVal = std(stepsAcrossTrials);
    % Gets coordinates for the final optimal route through maze
    coordinates = GetCoordinates(maze);
end

% Defines termination state and runs through the number of episodes
function [maze, steps] = Trial(maze, episodes)
    terminationState = 100;
    for i = 1:episodes
        [maze, steps(i)] = Episode(maze, terminationState);
    end
end

% Implementation of a Q-Learning episode
function [maze, steps] = Episode(maze, terminationState)
    % Defining initial values
    running = 1;
    steps = 0;
    state = maze.RandomStartingState();
    
    % Loops until termination state is reached
    while (running == 1)
        % Getting action, the next state, and the reward
        action = GreedyActionSelection(maze, state);
        nextState = maze.tm(state, action);
        reward = maze.RewardFunction(state, action);
        
        % Gets updated maze object, including the updates QValues
        maze = UpdateQ(maze, state, action, nextState, reward);
        
        % Termination condition
        if(nextState == terminationState)
            running = 0;
        end
        
        % Updating no. of steps and the current state
        steps = steps + 1;
        state = nextState; 
    end
end

% Using Q-Algorithm to update a value in the QValues using the learning and discount rate
function maze = UpdateQ(maze, state, action, resultingState, reward)
    a = 0.2;
    y = 0.9;
    maze.QValues(state, action) = maze.QValues(state, action) + a * (reward + y * max(maze.QValues(resultingState, :)) - maze.QValues(state, action));
end

% Selects the maximum value at any given state from QValues and returns the
% action 90% of the time. 10% of the time it will "explore" and return a
% random value
function action = GreedyActionSelection(maze, state)
    % Calculating random probability
    p = rand(1);
    
    if (p > 0.9)
        % Return random action if greater than 0.9 (10%)
        a = 0;
        b = 4;
        action = ceil((b-a) * rand + a);
    else
        % Return the index of the maximum value of the current state from the QValues.
        [temp, action] = max(maze.QValues(state, :));
    end
end

% Returns the coordinates of the most optimal route through the maze
function coordinates = GetCoordinates(maze)
     % Setting intial values        
     termination = false;
     i = 1;
     states(i) = 1;
     
     while (termination == false)
         % Calculate action from QValues depending what state
        [temp, action] = max(maze.QValues(states(i), :));
        % Update the state given the action
        states(i + 1) = maze.tm(states(i), action);
        
        % Termination condition
        if(states(i + 1) == 100)
            termination = true;
        end
        % Get the coordinates of the current state
        coordinates(i, 1) = maze.stateX(states(i));
        coordinates(i, 2) = maze.stateY(states(i));
        % Incrementing i
        i = i + 1;
     end
     % Get final cordinates
     coordinates(i, 1) = maze.stateX(states(i));
     coordinates(i, 2) = maze.stateY(states(i));
end