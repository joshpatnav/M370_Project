
function payments = calculateHouseholdBenefits( ...
    userData, claimAge1, claimAge2)
% calculateHouseholdBenefits
% MATH 370 - Social Security Retirement Optimizer
%
% Calculates monthly household benefit payments.
%
% Inputs:
%   userData   - Household information structure
%   claimAge1  - First person's claiming age
%   claimAge2  - Spouse claiming age (NaN if single)
%
% Output:
%   payments - Table of monthly household benefits
%
% IMPORTANT:
% Simplified classroom model, not an SSA calculator.
% Assumes:
%   - Both workers have an FRA of 67
%   - Children are unmarried and under age 18
%   - All children have the same entered age
%   - Approximate spousal supplements
%   - Illustrative family maximum (175% of PIA)
%   - No survivor, earnings-test, or child-in-care
%     spousal benefits


    %% Step 1: Household Information

    isMarried = strcmp(userData.maritalStatus, 'Married');
    hasDependents = strcmp(userData.hasDependents, 'Yes');

    age1 = userData.currentAge;
    income1 = userData.annualIncome;
    life1 = userData.lifespan;

    age2 = NaN;
    income2 = 0;
    life2 = 0;

    if isMarried
        age2 = userData.spouseAge;
        income2 = userData.spouseIncome;
        life2 = userData.spouseLifespan;
    end

    numberChildren = 0;
    childAge = NaN;

    if hasDependents
        numberChildren = userData.numberDependents;
        childAge = userData.youngestDependentAge;
    end


    %% Step 2: Validate Inputs

    if age1 > 70 || age1 < 0 || life1 <= age1
        error('Invalid age or lifespan for Person 1.');
    end

    if ~isscalar(claimAge1) || ...
            claimAge1 < max(62, age1) || claimAge1 > 70 || ...
            claimAge1 ~= floor(claimAge1) || ...
            claimAge1 >= life1
        error('Invalid claiming age for Person 1.');
    end

    if isMarried
        if age2 > 70 || age2 < 0 || life2 <= age2
            error('Invalid age or lifespan for spouse.');
        end

        if ~isscalar(claimAge2) || ...
                claimAge2 < max(62, age2) || ...
                claimAge2 > 70 || ...
                claimAge2 ~= floor(claimAge2) || ...
                claimAge2 >= life2
            error('Invalid spouse claiming age.');
        end
    end

    if hasDependents
        if childAge < 0 || childAge >= 18 || ...
                numberChildren < 1 || ...
                numberChildren ~= floor(numberChildren)
            error('Enter a valid child age and count.');
        end
    end


    %% Step 3: Calculate Base Retirement Benefits

    PIA1 = calculatePIA(income1);

    benefit1 = calculateWorkerBenefit(PIA1, claimAge1);

    PIA2 = 0;
    benefit2 = 0;

    if isMarried
        PIA2 = calculatePIA(income2);
        benefit2 = calculateWorkerBenefit(PIA2, claimAge2);
    end


    %% Step 4: Determine Simulation Length

    % Both people are evaluated from the same date: today.
    months1 = floor(12 * (life1 - age1));

    months2 = 0;

    if isMarried
        months2 = floor(12 * (life2 - age2));
    end

    totalMonths = max(months1, months2);

    month = (0:totalMonths-1)';

    yearsFromNow = month / 12;

    ageTimeline1 = age1 + yearsFromNow;

    ageTimeline2 = NaN(totalMonths, 1);

    if isMarried
        ageTimeline2 = age2 + yearsFromNow;
    end


    %% Step 5: Initialize Monthly Payment Arrays

    worker1 = zeros(totalMonths, 1);
    worker2 = zeros(totalMonths, 1);

    spousal = zeros(totalMonths, 1);
    children = zeros(totalMonths, 1);


    %% Step 6: Calculate Potential Spousal Supplement

    % Simplified spousal excess calculation.
    % Based on half of the higher worker's PIA,
    % minus the lower worker's own PIA.

    spousalExcess = 0;
    spousalStartMonth = Inf;

    if isMarried

        if PIA1 >= PIA2

            lowerPIA = PIA2;
            higherPIA = PIA1;

            % Lower-PIA spouse is Person 2
            lowerAge = age2;
            lowerClaim = claimAge2;

            higherClaimMonth = ...
                ceil(12 * max(0, claimAge1 - age1));

        else

            lowerPIA = PIA1;
            higherPIA = PIA2;

            % Lower-PIA spouse is Person 1
            lowerAge = age1;
            lowerClaim = claimAge1;

            higherClaimMonth = ...
                ceil(12 * max(0, claimAge2 - age2));

        end

        lowerClaimMonth = ...
            ceil(12 * max(0, lowerClaim - lowerAge));

        % Simplified: both workers must be entitled.
        spousalStartMonth = max( ...
            lowerClaimMonth, higherClaimMonth);

        supplementAge = ...
            lowerAge + spousalStartMonth / 12;

        spousalExcess = max( ...
            0, 0.50 * higherPIA - lowerPIA);

        % Approximate early spousal reduction
        monthsEarly = max(0, (67 - supplementAge) * 12);

        first36 = min(monthsEarly, 36);
        extraMonths = max(0, monthsEarly - 36);

        reduction = ...
            first36 * (25/36) / 100 + ...
            extraMonths * (5/12) / 100;

        spousalExcess = spousalExcess * ...
            max(0, 1 - reduction);

    end


    %% Step 7: Calculate Each Month

    for k = 1:totalMonths

        m = month(k);

        currentAge1 = ageTimeline1(k);

        % Person 1 receiving worker benefits?
        active1 = currentAge1 >= claimAge1 && ...
                  currentAge1 < life1;

        if active1
            worker1(k) = benefit1;
        end


        %% Spouse Worker Benefits

        active2 = false;

        if isMarried

            currentAge2 = ageTimeline2(k);

            active2 = currentAge2 >= claimAge2 && ...
                      currentAge2 < life2;

            if active2
                worker2(k) = benefit2;
            end

        end


        %% Spousal Supplement

        % Only when both are receiving their own
        % worker benefits in this simplified version.

        if isMarried && active1 && active2 && ...
                m >= spousalStartMonth

            spousal(k) = spousalExcess;

        end


        %% Dependent Benefits

        if hasDependents

            currentChildAge = childAge + yearsFromNow(k);

            if currentChildAge < 18

                % Select one active worker record.
                % This is a simplified household rule.
                parentPIA = 0;

                if active1
                    parentPIA = PIA1;
                end

                if active2
                    parentPIA = max(parentPIA, PIA2);
                end

                if parentPIA > 0

                    % Approximate 50% of PIA per child
                    rawChildBenefits = ...
                        0.50 * parentPIA * numberChildren;

                    % Illustrative auxiliary benefit cap
                    auxiliaryCap = 0.75 * parentPIA;

                    children(k) = min( ...
                        rawChildBenefits, auxiliaryCap);

                end

            end

        end

    end


    %% Step 8: Return Household Payments

    totalPayment = worker1 + worker2 + ...
                   spousal + children;

    payments = table( ...
        month, ageTimeline1, ageTimeline2, ...
        worker1, worker2, spousal, children, ...
        totalPayment, ...
        'VariableNames', { ...
        'Month', 'Age1', 'Age2', ...
        'Worker1', 'Worker2', ...
        'Spousal', 'Children', ...
        'Total'});

end
