function [ fmin, xmin, it, cpuTime, evalNumbers, valuesPerIter ] = GoldsteinPrice( functionName, methodParams )
%%%%%%%%                Header              %%%%%%%%%%
%       This is Modified Newton method implemented by 
%       using numerical gradient and Hessian computations.
%       Parametar eta in Goldstein Price method determines 
%       wheater to use gradient or Newton search direction. 
%       Line search method is used for computing step 
%       size in every iteration.
%
%%%%%%%%                End                 %%%%%%%%%%
    
    % set initial values
    tic;                                    % to compute CPU time
    evalNumbers = EvaluationNumbers(0,0,0);
    maxIter = methodParams.max_iteration_no;
    valuesPerIter = PerIteration(maxIter);
    eps = methodParams.epsilon;
    eta = 0.2;                              % parametar eta initialization
    xmin = methodParams.starting_point;
    t = methodParams.startingPoint;
    it = 1;                                 % number of iteration
    
    [fCurr, grad, Hes] = feval(functionName, xmin, [1 1 1]);
    evalNumbers.incrementBy([1 1 1]);
    grNorm = double(norm(grad));
    % Added values for first iteration in graphic
    valuesPerIter.setFunctionVal(it, fCurr);
    valuesPerIter.setGradientVal(it, grNorm);
    
    workPrec = methodParams.workPrec;
    fPrev = fCurr + 1;
                
    % process
    while (grNorm > eps && it < maxIter && abs(fPrev - fCurr)/(1 + abs(fCurr)) > workPrec)
        
        % Computes dir according to the Goldstein Price rule 
        dir = -Hes\grad;                  % computes Newton direction
        if dir'*(-grad)/(norm(dir)*norm(grad)) < eta || sum(isnan(dir)) > 0
            dir = -grad;
        end
        
        fValues = valuesPerIter.functionPerIteration(1:it); % take vector of function values after first 'it' iteration
        params = LineSearchParams(methodParams, fValues, grad, dir', xmin, t, it);
        [t, xmin, lineSearchEvalNumbers ] = feval(methodParams.lineSearchMethod, functionName, params);
        evalNumbers = evalNumbers + lineSearchEvalNumbers;
        it = it + 1;
            
        fPrev = fCurr;
        % compute numerical gradient and Hessian in new point
        [fCurr , grad, Hes] = feval(functionName, xmin, [1 1 1]);   
        evalNumbers.incrementBy([1 1 1]);
        grNorm = double(norm(grad));
        
        valuesPerIter.setFunctionVal(it, fCurr);
        valuesPerIter.setGradientVal(it, grNorm);
        valuesPerIter.setStepVal(it, t);
    end;
    
    cpuTime = toc;
    valuesPerIter.trim(it);
    fmin = fCurr;
    it = it - 1;
end
