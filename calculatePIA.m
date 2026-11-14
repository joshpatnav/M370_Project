
% calculatePIA.m
% M370 - Best Age to Collect Social Security
%
% Estimates the Primary Insurance Amount (PIA)
% using annual income as a proxy for historical earnings.
%
% Input:
%   annualIncome - Estimated annual earnings ($)
%
% Output:
%   PIA - Estimated monthly benefit at FRA ($)
%
% Assumptions:
%   - Uses 2026 SSA bend points
%   - Annual income / 12 approximates AIME
%   - Does not use actual 35-year earnings history
function PIA = calculatePIA(annualIncome)

%% Step 1: Validate Annual Income

validateattributes(annualIncome, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'nonnegative'});


%% Step 2: Estimate Average Indexed Monthly Earnings

AIME = annualIncome / 12;


%% Step 3: Define 2026 PIA Bend Points

bendPoint1 = 1286;
bendPoint2 = 7749;


%% Step 4: Separate Earnings into Brackets

bracket1 = min(AIME, bendPoint1);

bracket2 = max(0, ...
    min(AIME, bendPoint2) - bendPoint1);

bracket3 = max(0, AIME - bendPoint2);


%% Step 5: Calculate Primary Insurance Amount

PIA = 0.90 * bracket1 ...
    + 0.32 * bracket2 ...
    + 0.15 * bracket3;


%% Step 6: Round Down to Nearest Dime

PIA = floor(PIA * 10 + 1e-8) / 10;

end
