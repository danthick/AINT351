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

% YOU NEED TO DEFINE THESE VALUES
limits = [0 1; 0 1;];

% build the maze
maze = CMazeMaze10x10(limits);

% init the q-table
minVal = 0.01;
maxVal = 0.1;
maze = maze.InitQTable(minVal, maxVal);
    
% build the transition matrix
maze = maze.BuildTransitionMatrix();

% Plotting histogram
for i = 1:1000
    starting(i) = maze.RandomStartingState();
end
figure
hold on
histogram(starting, 100);

episodes = 1000;
trials = 100;

[maze, steps] = Trial(maze, episodes);
[meanVal, stdVal, coordinates] = Experiment(maze, episodes, trials);

% draw the maze
maze.DrawMaze();
line(coordinates(:,1)./10 - 0.05, coordinates(:,2)./10 - 0.05, 'Marker', 'x', 'MarkerEdgeColor', 'm','MarkerFaceColor', [1, 0, 1], 'MarkerSize', 20, 'LineWidth', 5);

% figure
% hold on
% plot(steps);

% figure
% hold on
% errorbar(meanVal, stdVal);

function [meanVal, stdVal, coordinates] = Experiment(maze, episodes, trials)
    for i = 1:trials
        [maze, stepsAcrossTrials(i, :)] = Trial(maze, episodes);
    end
    meanVal = mean(stepsAcrossTrials);
    stdVal = std(stepsAcrossTrials);
    coordinates = GetCoordinates(maze);
end

function [maze, steps] = Trial(maze, episodes)
    terminationState = 100;
    
    for i = 1:episodes
        [maze, steps(i)] = Episode(maze, terminationState);
    end
end

function [maze, steps] = Episode(maze, terminationState)
    running = 1;
    steps = 0;
    state = maze.RandomStartingState();
    
    while (running == 1)
        action = GreedyActionSelection(maze, state);
        nextState = maze.tm(state, action);
        reward = maze.RewardFunction(state, action);
        
        maze = UpdateQ(maze, state, action, nextState, reward);
        
        if(nextState == terminationState)
            running = 0;
        end
        
        steps = steps + 1;
        state = nextState; 
    end
end

function maze = UpdateQ(maze, state, action, resultingState, reward)
    a = 0.2;
    y = 0.9;
    
    maze.QValues(state, action) = maze.QValues(state, action) + a * (reward + y * max(maze.QValues(resultingState, :)) - maze.QValues(state, action));
end

function action = GreedyActionSelection(maze, state)
    % Calculating random probability
    p = rand(1);
    
    if (p > 0.9)
        % Return random action if greater than 0.9 (10%)
        a = 0;
        b = 4;
        action = ceil((b-a) * rand + a);
    else
        % Return the index of the maximum value of the current state from
        % the QValues.
        [temp, action] = max(maze.QValues(state, :));
    end
end

function cordinates = GetCoordinates(maze)
     termination = false;
     i = 1;
     states(i) = 1;
     
     while (termination == false)
         
         % Calculate action from QValues depending what state
        [temp, action] = max(maze.QValues(states(i), :));
        % Update the state given the action
        states(i + 1) = maze.tm(states(i), action);
        
        if(states(i + 1) == 100)
            termination = true;
        end
        cordinates(i, 1) = maze.stateX(states(i));
        cordinates(i, 2) = maze.stateY(states(i));
        i = i + 1;
     end
     cordinates(i, 1) = maze.stateX(states(i));
     cordinates(i, 2) = maze.stateY(states(i));
end