
function result = optimizeHousehold(userData)
% optimizeHousehold
% MATH 370 - Social Security Retirement Optimizer
%
% Finds the claiming strategy that maximizes
% household Net Present Value.
%
% Input:
%   userData - Household information structure
%
% Output:
%   result - Structure containing optimal claiming
%            ages, maximum NPV, and graphing data


    %% Step 1: Identify Household Scenario

    isMarried = strcmp(userData.maritalStatus, 'Married');


    %% Step 2: Determine Eligible Claiming Ages

    startAge1 = max(62, ceil(userData.currentAge));

    ages1 = startAge1:70;

    ages1 = ages1(ages1 < userData.lifespan);

    if isempty(ages1)
        error('No valid claiming ages for Person 1.');
    end


    %% Step 3: Handle Married or Single Household

    if isMarried

        startAge2 = max(62, ceil(userData.spouseAge));

        ages2 = startAge2:70;

        ages2 = ages2( ...
            ages2 < userData.spouseLifespan);

        if isempty(ages2)
            error('No valid claiming ages for spouse.');
        end

        %% Step 4A: Married Optimization

        npvMatrix = zeros(length(ages1), length(ages2));

        for i = 1:length(ages1)

            for j = 1:length(ages2)

                npvMatrix(i,j) = calculateHouseholdNPV( ...
                    userData, ages1(i), ages2(j));

            end

        end

        % Find maximum household NPV
        [maxNPV, index] = max(npvMatrix(:));

        [row, col] = ind2sub(size(npvMatrix), index);

        optimalAge1 = ages1(row);
        optimalAge2 = ages2(col);


    else

        %% Step 4B: Single Optimization

        ages2 = [];

        npvMatrix = zeros(length(ages1), 1);

        for i = 1:length(ages1)

            npvMatrix(i) = calculateHouseholdNPV( ...
                userData, ages1(i), NaN);

        end

        % Find maximum household NPV
        [maxNPV, index] = max(npvMatrix);

        optimalAge1 = ages1(index);
        optimalAge2 = NaN;

    end


    %% Step 5: Calculate Optimal Benefit Breakdown

    [~, breakdown] = calculateHouseholdNPV( ...
        userData, optimalAge1, optimalAge2);


    %% Step 6: Return Optimization Results

    result.optimalAge1 = optimalAge1;
    result.optimalAge2 = optimalAge2;

    result.maxNPV = maxNPV;

    result.ages1 = ages1;
    result.ages2 = ages2;

    result.npvMatrix = npvMatrix;

    result.breakdown = breakdown;

end
